//
//  FileParser.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/8/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import PathKit
import XcodeProj
import SourceKittenFramework

struct ParsedFile {
  let file: File
  let structure: Structure
  private(set) var shouldMock: Bool
  static func clone(_ other: ParsedFile, shouldMock: Bool) -> ParsedFile {
    var clone = other
    clone.shouldMock = shouldMock
    return clone
  }
}

struct RawType {
  let dictionary: StructureDictionary
  let name: String
  let parsedFile: ParsedFile
  init(dictionary: StructureDictionary, name: String, parsedFile: ParsedFile) {
    self.dictionary = dictionary
    self.name = name
    self.parsedFile = parsedFile
  }
}

class BasicOperation: Operation {
  override var isAsynchronous: Bool { return false }
  override var isConcurrent: Bool { return true }
  
  private(set) var _isFinished: Bool = false
  override var isFinished: Bool {
    set {
      willChangeValue(forKey: "isFinished")
      _isFinished = newValue
      didChangeValue(forKey: "isFinished")
    }
    get { return _isFinished }
  }
  
  private(set) var _isExecuting: Bool = false
  override var isExecuting: Bool {
    set {
      willChangeValue(forKey: "isExecuting")
      _isExecuting = newValue
      didChangeValue(forKey: "isExecuting")
    }
    get { return _isExecuting }
  }
  
  func run() {}
  
  override func start() {
    guard !isCancelled else { return }
    isExecuting = true
    run()
    isExecuting = false
    isFinished = true
  }
}

class ExtractSourcesOperation: BasicOperation {
  let target: PBXTarget
  let sourceRoot: Path
  
  class Result {
    fileprivate(set) var targetPaths = Set<Path>()
    fileprivate(set) var dependencyPaths = Set<Path>()
  }
  
  let result = Result()
  
  init(with target: PBXTarget, sourceRoot: Path) {
    self.target = target
    self.sourceRoot = sourceRoot
  }
  
  override func run() {
    result.targetPaths = sourceFilePaths(for: target)
    result.dependencyPaths =
      Set(allTargets(for: target, includeTarget: false).flatMap({ sourceFilePaths(for: $0) }))
        .subtracting(result.targetPaths)
  }
  
  private static var memoizedSourceFilePaths = Synchronized<[PBXTarget: Set<Path>]>([:])
  private func sourceFilePaths(for target: PBXTarget) -> Set<Path> {
    if let memoized = ExtractSourcesOperation.memoizedSourceFilePaths.value[target] {
      return memoized
    }
    guard let phase = target.buildPhases.first(where: { $0.buildPhase == .sources }) else {
      ExtractSourcesOperation.memoizedSourceFilePaths.update { $0[target] = [] }
      return []
    }
    let paths = Set(phase.files?
      .compactMap({ try? $0.file?.fullPath(sourceRoot: sourceRoot) })
      .filter({ $0.extension == "swift" }) ?? [])
    ExtractSourcesOperation.memoizedSourceFilePaths.update { $0[target] = paths }
    return paths
  }
  
  // Includes dependencies
  private static var memoizedAllTargets = Synchronized<[PBXTarget: Set<PBXTarget>]>([:])
  private func allTargets(for target: PBXTarget, includeTarget: Bool = true) -> Set<PBXTarget> {
    if let memoized = ExtractSourcesOperation.memoizedAllTargets.value[target] {
      return memoized
    }
    let targets = Set([target]).union(target.dependencies
      .compactMap({ $0.target })
      .flatMap({ allTargets(for: $0) }))
    ExtractSourcesOperation.memoizedAllTargets.update { $0[target] = targets }
    return targets
  }
}

class ParseFilesOperation: BasicOperation {
  let extractSourcesResult: ExtractSourcesOperation.Result
  
  class Result {
    fileprivate(set) var parsedFiles = [ParsedFile]()
  }
  
  let result = Result()
  
  private let queue = OperationQueue()
  class SubOperation: BasicOperation {
    let path: Path
    let shouldMock: Bool
    
    class Result {
      fileprivate(set) var parsedFile: ParsedFile?
    }
    
    let result = Result()
    
    init(path: Path, shouldMock: Bool) {
      self.path = path
      self.shouldMock = shouldMock
    }
    
    private static var memoizedParsedFiles = Synchronized<[Path: ParsedFile]>([:])
    
    override func run() {
      let path = self.path
      if let memoized = ParseFilesOperation.SubOperation.memoizedParsedFiles.value[path] {
        result.parsedFile = ParsedFile.clone(memoized, shouldMock: shouldMock)
        return
      }
      
      guard let file = path.file,
        let structure = try? Structure(file: file) else { return }
      let parsedFile = ParsedFile(file: file, structure: structure, shouldMock: shouldMock)
      ParseFilesOperation.SubOperation.memoizedParsedFiles.update { $0[path] = parsedFile }
      result.parsedFile = parsedFile
    }
  }
  
  init(extractSourcesResult: ExtractSourcesOperation.Result) {
    self.extractSourcesResult = extractSourcesResult
  }
  
  override func run() {
    let operations = extractSourcesResult.targetPaths.map({
      SubOperation(path: $0, shouldMock: true)
    }) + extractSourcesResult.dependencyPaths.map({
      SubOperation(path: $0, shouldMock: false)
    })
    queue.maxConcurrentOperationCount = ProcessInfo.processInfo.activeProcessorCount * 2
    queue.addOperations(operations, waitUntilFinished: true)
    result.parsedFiles = operations.compactMap({ $0.result.parsedFile })
  }
}

class ProcessTypesOperation: BasicOperation {
  let parseFilesResult: ParseFilesOperation.Result
  
  class Result {
    fileprivate(set) var rawTypes = [String: RawType]()
    fileprivate(set) var mockableTypes = [String: MockableType]()
  }
  
  let result = Result()
  
  init(parseFilesResult: ParseFilesOperation.Result) {
    self.parseFilesResult = parseFilesResult
  }
  
  override func run() {
    parseFilesResult.parsedFiles.forEach({
      processStructureDictionary($0.structure.dictionary, in: $0)
    })
    result.rawTypes.forEach({ flattenInheritence(for: $0.value) })
  }
  
  private func processStructureDictionary(_ dictionary: StructureDictionary,
                                          in parsedFile: ParsedFile) {
    guard let substructure = dictionary[SwiftDocKey.substructure.rawValue] as? [StructureDictionary] else {
      return
    }
    substructure.forEach({ processStructureDictionary($0, in: parsedFile) })
    
    guard let rawKind = dictionary[SwiftDocKey.kind.rawValue] as? String,
      let kind = SwiftDeclarationKind(rawValue: rawKind), kind.isMockable else { return }
    
    guard let name = dictionary[SwiftDocKey.name.rawValue] as? String else { return }
    result.rawTypes[name] = RawType(dictionary: dictionary, name: name, parsedFile: parsedFile)
  }
  
  private static var memoizedMockbleTypes = Synchronized<[String: MockableType]>([:])
  private func flattenInheritence(for rawType: RawType) {
    guard result.mockableTypes[rawType.name] == nil else { return }
    if let memoized = ProcessTypesOperation.memoizedMockbleTypes.value[rawType.name] {
      result.mockableTypes[rawType.name] =
        MockableType.clone(memoized, shouldMock: rawType.parsedFile.shouldMock)
      return
    }
    defer {
//      let mockableType = time("Creating MockableType \(rawType.name)") { MockableType(from: rawType, mockableTypes: result.mockableTypes) }
      let mockableType = MockableType(from: rawType, mockableTypes: result.mockableTypes)
      result.mockableTypes[rawType.name] = mockableType
      ProcessTypesOperation.memoizedMockbleTypes.update { $0[rawType.name] = mockableType }
      
    }
    
    // Base case where the type doesn't inherit from anything.
    guard let inheritedTypes = rawType.dictionary[SwiftDocKey.inheritedtypes.rawValue] as? [StructureDictionary],
      inheritedTypes.count > 0 else { return }
    
    let rawInheritedTypes = inheritedTypes
      .compactMap({ $0[SwiftDocKey.name.rawValue] as? String }) // Get type name
      .compactMap({ result.rawTypes[$0] }) // Get stored raw type
    
    // All inherited types are flattened.
    guard rawInheritedTypes.filter({ result.mockableTypes[$0.name] == nil }).count > 0 else { return }
    rawInheritedTypes.forEach({ flattenInheritence(for: $0) }) // Flatten inherited
  }
}

class GenerateFileOperation: BasicOperation {
  private let processTypesResult: ProcessTypesOperation.Result
  private let inputTargetName: String
  private let outputPath: Path
  private let preprocessorExpression: String?
  private let shouldImportModule: Bool
  private let onlyMockProtocols: Bool
  
  private(set) var error: Error?
  
  init(processTypesResult: ProcessTypesOperation.Result,
       inputTargetName: String,
       outputPath: Path,
       preprocessorExpression: String?,
       shouldImportModule: Bool,
       onlyMockProtocols: Bool) {
    self.processTypesResult = processTypesResult
    self.inputTargetName = inputTargetName
    self.outputPath = outputPath
    self.shouldImportModule = shouldImportModule
    self.preprocessorExpression = preprocessorExpression
    self.onlyMockProtocols = onlyMockProtocols
  }

  override func run() {
    let generator = FileGenerator(processTypesResult.mockableTypes,
                                  for: inputTargetName,
                                  outputPath: outputPath,
                                  preprocessorExpression: preprocessorExpression,
                                  shouldImportModule: shouldImportModule,
                                  onlyMockProtocols: onlyMockProtocols)
    do {
      try generator.generate()
    } catch {
      self.error = error
    }
    print("Generated file to \(String(describing: outputPath.absolute()))") // TODO: logging utility
  }
}

private extension Path {
  var file: File? {
    guard isFile else { return nil }
    let url = URL(fileURLWithPath: String(describing: absolute()), isDirectory: false)
    return try? File(contents: String(contentsOf: url, encoding: .utf8))
  }
}
