//
//  PBXTarget+TargetConformance.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 4/15/20.
//

import Foundation
import PathKit
import XcodeProj

extension PBXTarget: AbstractTarget {}

extension PBXTarget: Target {
  /// Get the build configuration for testing, which is almost always `debug`.
  // TODO: Allow overriding for special cases via CLI argument.
  var testingBuildConfiguration: XCBuildConfiguration? {
    guard let inferredBuildConfiguration = buildConfigurationList?.buildConfigurations
      .first(where: { $0.name.lowercased() == "debug" }) else {
        logWarning("No debug build configuration found for target `\(name)`")
        return buildConfigurationList?.buildConfigurations.first
    }
    return inferredBuildConfiguration
  }
  
  public var productModuleName: String {
    guard
      let buildConfiguration = testingBuildConfiguration,
      let buildSetting =
        buildConfiguration.buildSettings["PRODUCT_MODULE_NAME"] as? String ??
        buildConfiguration.buildSettings["PRODUCT_NAME"] as? String,
      let moduleName = buildConfiguration.resolve(buildSetting, for: self)
    else {
      let fallbackModuleName = name.escapingForModuleName()
      log("No explicit module name set for target `\(name)`, falling back to `\(fallbackModuleName)`")
      return fallbackModuleName
    }
    let escapedModuleName = moduleName.escapingForModuleName()
    log("Resolved product module name `\(escapedModuleName)` for target `\(name)`")
    return escapedModuleName
  }

  public func findSourceFilePaths(sourceRoot: Path) -> [Path] {
    guard let phase = buildPhases.first(where: { $0.buildPhase == .sources }) else { return [] }
    return phase.files?
      .compactMap({ try? $0.file?.fullPath(sourceRoot: sourceRoot) })
      .filter({ $0.extension == "swift" }) ?? []
  }
}

extension XCBuildConfiguration {
  /// Certain build settings are implicitly applied, such as `TARGET_NAME`.
  func getBuildSetting(named key: String, for target: PBXTarget) -> String? {
    let implicitBuildSettings: [String: String] = [
      "TARGET_NAME": target.name
    ]
    return buildSettings[key] as? String ?? implicitBuildSettings[key]
  }
  
  /// Recursively resolves build settings.
  func resolve(_ buildSetting: String?, for target: PBXTarget) -> String? {
    guard let buildSetting = buildSetting else { return nil }
    
    let trimmedBuildSetting = buildSetting.trimmingCharacters(in: .whitespacesAndNewlines)
    guard let unwrappedBuildSetting = SubstitutionStyle.unwrap(trimmedBuildSetting)?.variable
      else { return buildSetting }
    
    let buildSettingName: String
    if let endIndex = unwrappedBuildSetting.firstIndex(of: ":") { // `TARGET_NAME:c99exidentifier`
      buildSettingName = String(unwrappedBuildSetting[..<endIndex])
    } else { // `TARGET_NAME`
      buildSettingName = unwrappedBuildSetting
    }
    
    return resolve(getBuildSetting(named: buildSettingName, for: target), for: target)
  }
}

extension PBXTargetDependency: TargetDependency {}
