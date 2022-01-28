import Foundation
import MockingbirdCommon
import MockingbirdGenerator
import PathKit
import XcodeProj
import os.log

class Generator {
  struct Configuration: Encodable {
    let projectPath: Path
    let sourceRoot: Path
    let inputTargetNames: [String]
    let environmentProjectFilePath: Path?
    let environmentSourceRoot: Path?
    let environmentTargetName: String?
    let outputPaths: [Path]
    let outputDir: Path?
    let supportPath: Path?
    let header: [String]
    let compilationCondition: String?
    let pruningMethod: PruningMethod
    let onlyMockProtocols: Bool
    let disableSwiftlint: Bool
    let disableCache: Bool
    let disableRelaxedLinking: Bool
  }
  
  enum Error: LocalizedError {
    case mismatchedInputsAndOutputs(inputCount: Int, outputCount: Int)
    case invalidOutputPath(path: Path)
    case invalidInputTarget(name: String)
    
    var errorDescription: String? {
      switch self {
      case let .mismatchedInputsAndOutputs(inputCount, outputCount):
        return "Mismatched number of input targets (\(inputCount)) and output file paths (\(outputCount))"
      case let .invalidOutputPath(path):
        return "Invalid output file path \(path)"
      case let .invalidInputTarget(name):
        return "The target '\(name)' does not exist in the project"
      }
    }
  }
  
  enum Constants {
    static let generatedFileNameSuffix = "Mocks.generated.swift"
    static let xcodeCacheSubdirectory = "MockingbirdCache"
    static let jsonCacheSubdirectory = ".mockingbird"
  }
  
  let config: Configuration
  let configHash: String
  let cliVersion = "\(mockingbirdVersion)"
  
  let sourceTargetCacheDirectory: Path
  let testTargetCacheDirectory: Path?
  
  init(_ config: Configuration) throws {
    self.config = config
    self.configHash = try config.toSha1Hash()
    
    // Set up directories for target metadata caching.
    if config.projectPath.extension == "xcodeproj" {
      self.sourceTargetCacheDirectory = config.projectPath + Constants.xcodeCacheSubdirectory
      if let environmentProjectFilePath = config.environmentProjectFilePath {
        let cacheDirectory = environmentProjectFilePath + Constants.xcodeCacheSubdirectory
        self.testTargetCacheDirectory = cacheDirectory
      } else {
        self.testTargetCacheDirectory = nil
      }
    } else {
      self.sourceTargetCacheDirectory = config.projectPath.parent()
        + Constants.jsonCacheSubdirectory
      self.testTargetCacheDirectory = self.sourceTargetCacheDirectory
    }
  }
  
  var parsedProjects = [Path: Project]()
  func getProject(_ projectPath: Path) throws -> Project {
    if let xcodeproj = parsedProjects[projectPath] { return xcodeproj }
    var project: Project!
    try time(.parseXcodeProject) {
      if projectPath.extension == "xcodeproj" {
        project = .xcode(try XcodeProj(path: projectPath))
      } else {
        logInfo("Inferring JSON project description from extension \((projectPath.extension ?? "").singleQuoted)")
        project = .json(try JSONProject(path: projectPath))
      }
    }
    parsedProjects[projectPath] = project
    return project
  }
  
  // Parsing Xcode projects can be slow, so lazily get implicit build environments.
  func getBuildEnvironment() -> [String: Any] {
    let project = try? getProject(config.projectPath)
    switch project {
    case .xcode(let xcodeproj): return xcodeproj.implicitBuildEnvironment
    case .json, .none: return [:]
    }
  }
  
  var projectHashes: [Path: String] = [:]
  func getProjectHash(_ projectPath: Path) -> String? {
    if let projectHash = projectHashes[projectPath.absolute()] { return projectHash }
    let filePath = projectPath.extension == "xcodeproj"
      ? projectPath.glob("*.pbxproj").sorted().first
      : projectPath
    let projectHash = try? filePath?.read().hash()
    self.projectHashes[projectPath.absolute()] = projectHash
    return projectHash
  }
  
  // Get cached source target metadata.
  func getCachedSourceTarget(targetName: String) -> TargetType? {
    guard !config.disableCache,
      let projectHash = getProjectHash(config.projectPath),
      let cachedTarget = findCachedSourceTarget(for: targetName,
                                                cliVersion: cliVersion,
                                                projectHash: projectHash,
                                                configHash: configHash,
                                                cacheDirectory: sourceTargetCacheDirectory,
                                                sourceRoot: config.sourceRoot)
      else { return nil }
    return .sourceTarget(cachedTarget)
  }
  
  // Get cached test target metadata.
  func getCachedTestTarget(targetName: String) -> TargetType? {
    guard config.pruningMethod != .disable,
      let cacheDirectory = testTargetCacheDirectory,
      let testProjectPath = config.environmentProjectFilePath,
      let testSourceRoot = config.environmentSourceRoot,
      let projectHash = getProjectHash(testProjectPath),
      let cachedTarget = findCachedTestTarget(for: targetName,
                                              projectHash: projectHash,
                                              cliVersion: cliVersion,
                                              cacheDirectory: cacheDirectory,
                                              sourceRoot: testSourceRoot)
      else { return nil }
    return .testTarget(cachedTarget)
  }
  
  func generate() throws {
    if !config.outputPaths.isEmpty && config.inputTargetNames.count != config.outputPaths.count {
      throw Error.mismatchedInputsAndOutputs(inputCount: config.inputTargetNames.count,
                                             outputCount: config.outputPaths.count)
    }
    
    if config.supportPath == nil {
      logWarning("No supporting source files specified which can result in missing mocks")
    }
    
    // Resolve target names to concrete Xcode project targets.
    let targets = try config.inputTargetNames.compactMap({ targetName throws -> TargetType? in
      return try Generator.resolveTarget(targetName: targetName,
                                         projectPath: config.projectPath,
                                         getCachedTarget: getCachedSourceTarget,
                                         getProject: getProject)
    })
    
    // Resolve unspecified output paths to the default mock file output destination.
    let outputPaths: [Path] = try {
      if !config.outputPaths.isEmpty {
        return config.outputPaths
      }
      return try targets.map({ target throws -> Path in
        let outputDir = config.outputDir ?? config.sourceRoot.mocksDirectory
        try outputDir.mkpath()
        return Generator.defaultOutputPath(for: target,
                                           outputDir: outputDir,
                                           environment: getBuildEnvironment)
      })
    }()
    
    let queue = OperationQueue.createForActiveProcessors()
    
    // Create operations to find used mock types in tests.
    let pruningPipeline = config.pruningMethod == .disable ? nil :
      PruningPipeline(config: config,
                      getCachedTarget: getCachedTestTarget,
                      getProject: getProject,
                      environment: getBuildEnvironment)
    if let pruningOperations = pruningPipeline?.operations {
      queue.addOperations(pruningOperations, waitUntilFinished: false)
    }
    let findMockedTypesOperation = pruningPipeline?.findMockedTypesOperation
    
    // Create abstract generation pipelines from targets and output paths.
    var pipelines = [Pipeline]()
    for (target, outputPath) in zip(targets, outputPaths) {
      guard !outputPath.isDirectory else {
        throw Error.invalidOutputPath(path: outputPath)
      }
      try pipelines.append(Pipeline(inputTarget: target,
                                    outputPath: outputPath,
                                    config: config,
                                    findMockedTypesOperation: findMockedTypesOperation,
                                    environment: getBuildEnvironment))
    }
    pipelines.forEach({ queue.addOperations($0.operations, waitUntilFinished: false) })
    
    // Run the operations.
    let operationsCopy = queue.operations.compactMap({ $0 as? BasicOperation })
    queue.waitUntilAllOperationsAreFinished()
    operationsCopy.compactMap({ $0.error }).forEach({ logError($0) })
    
    // Write intermediary module cache info into project cache directory.
    if !config.disableCache {
      try time(.cacheMocks) {
        try cachePipelines(sourcePipelines: pipelines, pruningPipeline: pruningPipeline)
      }
    }
  }
  
  func cachePipelines(sourcePipelines: [Pipeline], pruningPipeline: PruningPipeline?) throws {
    guard let projectHash = getProjectHash(config.projectPath) else { return }
    
    // Cache source targets for generation.
    try sourceTargetCacheDirectory.mkpath()
    try sourcePipelines.forEach({
      try $0.cache(projectHash: projectHash,
                   cliVersion: cliVersion,
                   configHash: configHash,
                   sourceRoot: config.sourceRoot,
                   cacheDirectory: sourceTargetCacheDirectory,
                   environment: getBuildEnvironment)
    })
    
    // Cache test target for thunk pruning.
    if config.pruningMethod != .disable {
      if let testTargetCacheDirectory = testTargetCacheDirectory,
         let environmentSourceRoot = config.environmentSourceRoot,
         let testProjectPath = config.environmentProjectFilePath,
         let projectHash = getProjectHash(testProjectPath) {
        try testTargetCacheDirectory.mkpath()
        try pruningPipeline?.cache(projectHash: projectHash,
                                   cliVersion: cliVersion,
                                   sourceRoot: environmentSourceRoot,
                                   cacheDirectory: testTargetCacheDirectory,
                                   environment: getBuildEnvironment)
      }
    }
  }
  
  static func defaultOutputPath(for sourceTarget: TargetType,
                                testTarget: TargetType? = nil,
                                outputDir: Path,
                                environment: () -> [String: Any]) -> Path {
    let moduleName = sourceTarget.resolveProductModuleName(environment: environment)
    
    let prefix: String
    if let testTargetName = testTarget?.resolveProductModuleName(environment: environment),
      testTargetName != moduleName {
      prefix = testTargetName + "-"
    } else {
      prefix = "" // Probably installed on a source target instead of a test target.
    }
    
    return outputDir + "\(prefix)\(moduleName)\(Constants.generatedFileNameSuffix)"
  }
  
  static func resolveTarget(targetName: String,
                            projectPath: Path,
                            isValidTarget: (TargetType) -> Bool = { _ in true },
                            getCachedTarget: (String) -> TargetType?,
                            getProject: (Path) throws -> Project) throws -> TargetType {
    // Check if the target is cached in the project.
    if let cachedTarget = getCachedTarget(targetName) {
      return cachedTarget
    }
    
    // Need to parse the Xcode project for the full `PBXTarget` object.
    let project = try getProject(projectPath)
    let targets = project.targets(named: targetName).filter(isValidTarget)
    
    if targets.count > 1 {
      logWarning("Found multiple targets named \(targetName.singleQuoted), using the first one")
    }
    
    guard let target = targets.first else {
      throw Error.invalidInputTarget(name: targetName)
    }
    return target
  }
}

extension Path {
  var mocksDirectory: Path {
    return absolute() + Path("MockingbirdMocks")
  }
  
  func targetLockFilePath(for targetName: String, testBundle: String?) -> Path {
    var lockFileName: String
    if let testBundle = testBundle {
      lockFileName = "\(targetName)-\(testBundle).lock"
    } else {
      lockFileName = "\(targetName).lock"
    }
    return self + lockFileName
  }
}

extension XcodeProj {
  var implicitBuildEnvironment: [String: Any] {
    var buildEnvironment = [String: Any]()

    if let projectName = pbxproj.rootObject?.name {
      buildEnvironment["PROJECT_NAME"] = projectName
      buildEnvironment["PROJECT"] = projectName
    }
    
    return buildEnvironment
  }
}

extension PBXProductType {
  var isTestBundle: Bool {
    switch self {
    case .unitTestBundle, .uiTestBundle, .ocUnitTestBundle: return true
    default: return false
    }
  }
  
  var isSwiftUnitTestBundle: Bool {
    switch self {
    case .unitTestBundle: return true
    default: return false
    }
  }
}
