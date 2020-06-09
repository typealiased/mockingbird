//
//  PBXTarget+Target.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 4/15/20.
//

import Foundation
import PathKit
import XcodeProj

extension PBXTarget: Target {
  /// Get the build configuration for testing, which is almost always `debug`.
  // TODO: Allow overriding for special cases via CLI argument.
  var testingBuildConfiguration: XCBuildConfiguration? {
    guard let inferredBuildConfiguration = buildConfigurationList?.buildConfigurations
      .first(where: { $0.name.lowercased() == "debug" }) else {
        logWarning("No debug build configuration found for target \(name.singleQuoted)")
        return buildConfigurationList?.buildConfigurations.first
    }
    return inferredBuildConfiguration
  }
  
  public func resolveProductModuleName(environment: () -> [String: Any]) -> String {
    guard
      let configuration = testingBuildConfiguration,
      let moduleName = try? PBXTarget.resolve(
        BuildSetting("$(PRODUCT_MODULE_NAME:default=$(PRODUCT_NAME:default=$(TARGET_NAME)))"),
        from: getBuildEnvironment(configuration: configuration, environment: environment())
      )
    else {
      let fallbackModuleName = name.escapingForModuleName()
      logWarning("Unable to resolve product module name for target \(name.singleQuoted), falling back to \(fallbackModuleName.singleQuoted)")
      return fallbackModuleName
    }
    
    let escapedModuleName = moduleName.escapingForModuleName()
    log("Resolved product module name \(escapedModuleName.singleQuoted) for target \(name.singleQuoted)")
    return escapedModuleName
  }

  public func findSourceFilePaths(sourceRoot: Path) -> [Path] {
    guard let phase = buildPhases.first(where: { $0.buildPhase == .sources }) else { return [] }
    return phase.files?
      .compactMap({ try? $0.file?.fullPath(sourceRoot: sourceRoot) })
      .filter({ $0.extension == "swift" })
      .map({ $0.absolute() }) ?? []
  }
  
  /// Certain environment build settings are synthesized by Xcode and don't exist in the project
  /// file such as `TARGET_NAME`. Since the generator usually runs as part of a test target bundle
  /// (or even entirely outside of an Xcode build pipeline), we need to do some inference here.
  func getBuildEnvironment(configuration: XCBuildConfiguration,
                           environment: [String: Any]) -> [String: Any] {
    let keepOld: (Any, Any) -> Any = { old, _ in old }
    
    // Explicit build settings defined in the Xcode project file.
    var buildEnvironment: [String: Any] = configuration.buildSettings
    
    // Implicit settings derived from the target info.
    buildEnvironment.merge([
      "TARGET_NAME": name,
      "TARGETNAME": name,
    ], uniquingKeysWith: keepOld)
    
    // Implicit settings from external sources, e.g. `PROJECT_NAME`.
    buildEnvironment.merge(environment, uniquingKeysWith: keepOld)
    
    return buildEnvironment
  }
  
  enum ResolutionFailure: Error {
    static let cycleFlagValue = "__MKB_CYCLE_FLAG__"
    case evaluationCycle
  }
  
  /// Recursively resolves build settings.
  static func resolve(_ buildSetting: BuildSetting,
                      from environment: [String: Any]) throws -> String {
    return try buildSetting.components.map({ component -> String in
      switch component {
      case .literal(let literal):
        guard literal.value != ResolutionFailure.cycleFlagValue else {
          throw ResolutionFailure.evaluationCycle
        }
        return literal.value
      case .expression(let expression):
        // Recursive `resolve` calls pass `attributedEnvironment` to break evaluation cycles.
        var attributedEnvironment = environment
        attributedEnvironment[expression.name] = ResolutionFailure.cycleFlagValue
        
        if let buildSettingValue = environment[expression.name] as? String,
          !buildSettingValue.isEmpty {
          return try resolve(BuildSetting(buildSettingValue), from: attributedEnvironment)
        }
        
        // Empty build settings can have default values as of Xcode 11.4
        // https://developer.apple.com/documentation/xcode_release_notes/xcode_11_4_release_notes
        if let expressionOperator = expression.expressionOperator,
          expressionOperator.name == "default",
          let buildSetting = expressionOperator.value {
          return try resolve(buildSetting, from: attributedEnvironment)
        }
        
        let targetName = environment["TARGET_NAME"] as? String ?? ""
        let description = "$(\(expression))"
        logWarning("The build setting expression \(description.singleQuoted) evaluates to an empty string when resolving the product module name for \(targetName.singleQuoted)")
        return ""
      }
      }).joined()
  }
}

extension PBXTargetDependency: TargetDependency {}
