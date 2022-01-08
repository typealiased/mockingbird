import Foundation
import MockingbirdCommon
import MockingbirdGenerator
import PathKit
import XcodeProj

struct Installer {
  struct Configuration {
    let projectPath: Path
    let sourceProjectPath: Path
    let testTargetName: String
    let cliPath: Path
    let sourceRoot: Path
    let sourceTargetNames: [String]
    let outputPaths: [Path]
    let generatorOptions: [String]
    let overwrite: Bool
  }
  
  enum Failure: LocalizedError {
    case validationError(_ message: String)
    case invalidProjectConfiguration(_ message: String)
    case invalidTargetConfiguration(_ message: String)
    case unableToModifyProject(_ message: String)
    
    var errorDescription: String? {
      switch self {
      case .validationError(let message),
           .invalidProjectConfiguration(let message),
           .invalidTargetConfiguration(let message),
           .unableToModifyProject(let message):
        return message
      }
    }
  }
  
  enum Constants {
    /// Name of the primary build phase for generating mocks.
    static let buildPhaseName = "Generate Mockingbird Mocks"
    /// Name of the legacy build phase for working around Xcode build caching.
    static let cleanMocksBuildPhaseName = "Clean Mockingbird Mocks"
    /// Name of the Xcode project group containing generated files.
    static let sourceGroupName = "Generated Mocks"
  }
  
  let config: Configuration
  
  init(config: Configuration) throws {
    self.config = config
  }
  
  // MARK: - Install
  
  func install() throws {
    let testProject = try XcodeProj(path: config.projectPath)
    let sourceProject: XcodeProj = try {
      guard config.sourceProjectPath != config.projectPath else { return testProject }
      return try XcodeProj(path: config.sourceProjectPath)
    }()
    
    guard let rootGroup = try testProject.pbxproj.rootGroup() else {
      throw Failure.invalidProjectConfiguration(
        "Missing root group in Xcode project at \(config.projectPath.abbreviate())")
    }
    
    let testTarget = try findTarget(name: config.testTargetName,
                                    project: testProject,
                                    testTarget: true)
    let sourceTargets = try config.sourceTargetNames.map({ targetName in
      try findTarget(name: targetName, project: sourceProject, testTarget: false)
    })
    
    if config.overwrite {
      try uninstall(from: testProject, target: testTarget, rootGroup: rootGroup)
    }
    
    let sourceGroup = try createSourceGroup(name: Constants.sourceGroupName, rootGroup: rootGroup)
    
    guard let sourcesBuildPhase = try testTarget.sourcesBuildPhase(),
          let buildPhaseIndex = testTarget.buildPhases.firstIndex(of: sourcesBuildPhase) else {
      throw Failure.invalidTargetConfiguration(
        "Target \(singleQuoted: config.testTargetName) has no Compile Sources build phase")
    }
    
    // TODO: Migrate to a single output file with generator v2.
    let outputPaths = !config.outputPaths.isEmpty ? config.outputPaths :
      sourceTargets.map({ sourceTarget in
        Generator.defaultOutputPath(for: .pbxTarget(sourceTarget),
                                    testTarget: .pbxTarget(testTarget),
                                    outputDir: config.sourceRoot.mocksDirectory,
                                    environment: { testProject.implicitBuildEnvironment })
      })
    guard outputPaths.count == sourceTargets.count else {
      throw Failure.validationError(
        "The number of output paths does not equal the number of targets")
    }
    
    // Add build phase to target and project.
    let buildPhase = try createBuildPhase(outputPaths: outputPaths)
    testTarget.buildPhases.insert(buildPhase, at: buildPhaseIndex)
    testProject.pbxproj.add(object: buildPhase)
    
    // Track the generated mock files.
    for outputPath in outputPaths {
      try addSourceFilePath(outputPath,
                            target: testTarget,
                            sourceGroup: sourceGroup,
                            xcodeproj: testProject)
    }
    
    try testProject.writePBXProj(path: config.projectPath, outputSettings: PBXOutputSettings())
  }
  
  /// Checks if a path is located in the same derived data directory as the test project. If so,
  /// rewrites that path to use Bash substitution in the form `${DERIVED_DATA}/<subpath>`
  private func rewriteDerivedDataPath(_ path: Path) throws -> String? {
    // It's possible to use a custom derived data path (in addition to a custom build products
    // location), but this is very uncommon so we won't try to handle it.
    let derivedDataRootPath = Path("~/Library/Developer/Xcode/DerivedData/").absolute().string
    guard path.absolute().string.starts(with: derivedDataRootPath) else {
      return nil
    }
    log("Attempting to rewrite the derived data path \(path.abbreviate())")
    
    guard let derivedDataPath = try resolveDerivedDataPath()?.abbreviated() else {
      return nil
    }
    
    let pathString = path.abbreviated()
    guard pathString.starts(with: derivedDataPath) else {
      // Falls back to the abbreviated (home-relative) path, which is only portable between users on
      // the same machine.
      logWarning("The path \(pathString) is outside of the project’s derived data location ")
      return nil
    }
    
    return SubstitutionStyle.bash.wrap("DERIVED_DATA") + pathString.dropFirst(derivedDataPath.count)
  }
  
  private func resolveDerivedDataPath() throws -> Path? {
    let xcodebuild = Process()
    xcodebuild.launchPath = "/usr/bin/env"
    xcodebuild.arguments = ["xcodebuild", "-showBuildSettings"]
    xcodebuild.currentDirectoryURL = config.projectPath.parent().url
    xcodebuild.qualityOfService = .userInitiated
    
    let stdout = Pipe()
    xcodebuild.standardOutput = stdout

    try xcodebuild.run()
    xcodebuild.waitUntilExit()
    
    let stdoutData = stdout.fileHandleForReading.readDataToEndOfFile()
    guard let buildSettings = String(data: stdoutData, encoding: .utf8) else {
      logWarning("Unable to read the build settings from xcodebuild")
      return nil
    }
    
    let components = buildSettings.components(matching: #"BUILD_ROOT = (.*)/Build"#)
    guard let component = components.first, component.count == 2 else {
      logWarning("Unable to parse the build settings from xcodebuild")
      return nil
    }
    
    let derivedData = Path(String(component[1]))
    log("Resolved the derived data directory to \(derivedData.abbreviate())")
    return derivedData
  }
  
  private func findTarget(name: String,
                          project: XcodeProj,
                          testTarget: Bool) throws -> PBXTarget {
    let targets = project.pbxproj.targets(named: name)
    if targets.count > 1 {
      logWarning("Found multiple targets named \(singleQuoted: config.testTargetName)")
    }
    
    let validTargets = {
      project.pbxproj.nativeTargets.compactMap({ target -> String? in
        guard let productType = target.productType,
              testTarget ? productType.isSwiftUnitTestBundle : !productType.isTestBundle
        else { return nil }
        return target.name
      })
    }
    
    guard let target = targets.first else {
      let targetType = testTarget ? "test target" : "target"
      throw Failure.validationError(
        "Cannot find the \(targetType) \(singleQuoted: name). " +
        "Valid targets: \(separated: validTargets())")
    }
    
    guard let productType = target.productType else {
      throw Failure.invalidTargetConfiguration(
        "Target \(singleQuoted: name) has an unknown product type. " +
        "Valid targets: \(separated: validTargets())")
    }
    
    if testTarget && !productType.isSwiftUnitTestBundle {
      throw Failure.validationError(
        "Expected a test target but \(singleQuoted: name) is not a unit test bundle. " +
        "Valid targets: \(separated: validTargets())")
    }
    
    if !testTarget && productType.isTestBundle {
      throw Failure.validationError(
        "Expected a source target but \(singleQuoted: name) is a unit test bundle. " +
        "Valid targets: \(separated: validTargets())")
    }
    
    return target
  }
  
  private func createSourceGroup(name: String, rootGroup: PBXGroup) throws -> PBXGroup {
    if let previousGroup = rootGroup.group(named: name) {
      return previousGroup
    }
    
    if let newGroup = try rootGroup.addGroup(named: Constants.sourceGroupName,
                                             options: [.withoutFolder]).first {
      return newGroup
    }
    
    throw Failure.unableToModifyProject(
      "Cannot create \(singleQuoted: Constants.sourceGroupName) Xcode project group")
  }
  
  private func addSourceFilePath(_ outputPath: Path,
                                 target: PBXTarget,
                                 sourceGroup: PBXGroup,
                                 xcodeproj: XcodeProj) throws {
    guard try target.sourcesBuildPhase()?.files?.contains(where: { buildFile in
      try buildFile.file?.fullPath(sourceRoot: config.sourceRoot) == outputPath
    }) != true else {
      log("Target \(singleQuoted: target.name) already compiles \(outputPath.absolute())")
      return
    }
    
    let fileReference: PBXFileReference = try {
      // Need to check if the file already exists, or XcodeProj will throw an invalidGroupPath error
      // when re-running the installer.
      if let existingReference = sourceGroup.file(named: outputPath.lastComponent),
         (try? existingReference.fullPath(sourceRoot: config.sourceRoot)) == outputPath {
        log("Using existing output mock file reference at \(outputPath)")
        return existingReference
      }
      
      log("Creating a new output mock file reference at \(outputPath)")
      return try sourceGroup.addFile(at: outputPath,
                                     sourceRoot: config.sourceRoot,
                                     override: false,
                                     validatePresence: false)
    }()

    _ = try target.sourcesBuildPhase()?.add(file: fileReference)
    xcodeproj.pbxproj.add(object: fileReference)
  }
  
  private func createBuildPhase(outputPaths: [Path]) throws -> PBXShellScriptBuildPhase {
    var scriptSections: [String] = [
      "set -eu",
      
      """
      # Prevent Xcode 13 from running this script while indexing.
      [[ "${ACTION}" == "indexbuild" ]] && exit 0
      """,
    ]
    
    let cliPath: String
    if let derivedDataCliPath = try rewriteDerivedDataPath(config.cliPath) {
      cliPath = derivedDataCliPath
      scriptSections.append(#"""
      # Infer the derived data location from the build environment.
      [[ -z "${DERIVED_DATA+x}" ]] && DERIVED_DATA="$(echo "${BUILD_ROOT}" | sed -n 's|\(.*\)/Build/.*|\1|p')"
      """#)
    } else {
      cliPath = config.cliPath.abbreviated(root: config.sourceRoot, variable: "SRCROOT")
    }
    
    var options = config.generatorOptions
    // TODO: Remove this for generator v2. Only needed for backwards compatibility.
    if config.outputPaths.isEmpty {
      options += ["--outputs"] + outputPaths.map({ path in
        path.abbreviated(root: config.sourceRoot, variable: "SRCROOT").doubleQuoted
      })
    }
    scriptSections.append("\(doubleQuoted: cliPath) generate \(options.joined(separator: " "))")
    
    return PBXShellScriptBuildPhase(
      name: Constants.buildPhaseName,
      outputPaths: outputPaths.map({ path in
        path.abbreviated(root: config.sourceRoot, variable: "SRCROOT", style: .make)
      }),
      shellScript: scriptSections.joined(separator: "\n\n"),
      alwaysOutOfDate: true)
  }
  
  // MARK: - Uninstall
  
  private func uninstall(from xcodeproj: XcodeProj, target: PBXTarget, rootGroup: PBXGroup) throws {
    let sourceGroup = rootGroup.group(named: Constants.sourceGroupName)
    
    for buildPhase in target.buildPhases {
      guard let shellScriptBuildPhase = buildPhase as? PBXShellScriptBuildPhase else {
        continue
      }
      
      guard let name = buildPhase.name(),
            name == Constants.buildPhaseName ||
            name == Constants.cleanMocksBuildPhaseName else {
        continue
      }
      
      log("Removing \(singleQuoted: name) build phase from \(singleQuoted: target.name)")
      
      // Build phase must be removed from both the target and the project.
      xcodeproj.pbxproj.delete(object: buildPhase)
      target.buildPhases.removeAll(where: { $0 === buildPhase })
      
      // Remove generated output files from the Compile Sources build phase and the project.
      let generatedFilePaths = Set(shellScriptBuildPhase.outputPaths.map({ path in
        path.replacingOccurrences(of: SubstitutionStyle.make.wrap("SRCROOT"),
                                  with: config.sourceRoot.absolute().string)
      }))
      
      try target.sourcesBuildPhase()?.files?.removeAll(where: { buildFile in
        guard let fullPath = try buildFile.file?.fullPath(sourceRoot: config.sourceRoot) else {
          return false
        }
        return generatedFilePaths.contains(fullPath.string)
      })
      
      try sourceGroup?.children.removeAll(where: { child in
        guard let fullPath = try child.fullPath(sourceRoot: config.sourceRoot) else {
          return false
        }
        return generatedFilePaths.contains(fullPath.string)
      })
    }
  }
}
