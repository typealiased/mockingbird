//
//  ParseFilesOperation.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/17/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import PathKit
import SourceKittenFramework
import os.log

struct ParsedFile {
  let file: File
  let data: Data?
  let path: Path
  let moduleName: String
  let imports: Set<String>
  let importedModuleNames: Set<String>
  let compilationDirectives: [CompilationDirective]
  let structure: Structure
  let shouldMock: Bool
  
  init(file: File,
       path: Path,
       moduleName: String,
       imports: Set<String>,
       compilationDirectives: [CompilationDirective],
       structure: Structure,
       shouldMock: Bool) {
    self.file = file
    self.data = file.contents.data(using: .utf8, allowLossyConversion: false)
    self.path = path
    self.moduleName = moduleName
    self.imports = imports
    self.importedModuleNames = Set(imports.compactMap({
      guard let importKeywordIndex = $0.range(of: #"\bimport\b"#, options: .regularExpression)
        else { return nil }
      let importDeclaration = $0[$0.index(after: importKeywordIndex.upperBound)...]
      guard let moduleMemberIndex = importDeclaration.firstIndex(of: ".") else {
        return String(importDeclaration).trimmingCharacters(in: .whitespacesAndNewlines)
      }
      return String(importDeclaration[..<moduleMemberIndex])
        .trimmingCharacters(in: .whitespacesAndNewlines)
    }))
    self.compilationDirectives = compilationDirectives
    self.structure = structure
    self.shouldMock = shouldMock
  }
  
  func clone(shouldMock: Bool) -> ParsedFile {
    return ParsedFile(file: file,
                      path: path,
                      moduleName: moduleName,
                      imports: imports,
                      compilationDirectives: compilationDirectives,
                      structure: structure,
                      shouldMock: shouldMock)
  }
}

struct CompilationDirective: Comparable {
  let range: Range<Int64> // Byte offset bounds of the compilation directive declaration.
  let declaration: String
  var condition: String {
    return declaration[declaration.index(declaration.startIndex, offsetBy: 3)...]
      .trimmingCharacters(in: .whitespaces)
  }
  
  static func < (lhs: CompilationDirective, rhs: CompilationDirective) -> Bool {
    return lhs.range.lowerBound < rhs.range.lowerBound
  }
}

public class ParseFilesOperation: BasicOperation {
  let extractSourcesResult: ExtractSourcesOperationResult
  let checkCacheResult: CheckCacheOperation.Result?
  
  public class Result {
    fileprivate(set) var parsedFiles = [ParsedFile]()
    fileprivate(set) var imports = Set<String>()
    fileprivate(set) var moduleDependencies = [String: Set<String>]()
  }
  
  public let result = Result()
  
  class SubOperation: BasicOperation {
    let sourcePath: SourcePath
    let shouldMock: Bool
    
    class Result {
      fileprivate(set) var parsedFile: ParsedFile?
    }
    
    let result = Result()
    
    init(sourcePath: SourcePath, shouldMock: Bool) {
      self.sourcePath = sourcePath
      self.shouldMock = shouldMock
    }
    
    private static var memoizedParsedFiles = Synchronized<[SourcePath: ParsedFile]>([:])
    
    override func run() throws {
      let sourcePath = self.sourcePath
      if let memoized = ParseFilesOperation.SubOperation.memoizedParsedFiles.value[sourcePath] {
        result.parsedFile = memoized.clone(shouldMock: shouldMock)
        return
      }
      
      let file = try sourcePath.path.getFile()
      
      let structure = try Structure(file: file)
      let (imports, compilationDirectives) = shouldMock ? file.parse() : ([], [])
      let parsedFile = ParsedFile(file: file,
                                  path: sourcePath.path,
                                  moduleName: sourcePath.moduleName,
                                  imports: imports,
                                  compilationDirectives: compilationDirectives,
                                  structure: structure,
                                  shouldMock: shouldMock)
      ParseFilesOperation.SubOperation.memoizedParsedFiles.update { $0[sourcePath] = parsedFile }
      result.parsedFile = parsedFile
      if shouldMock {
        log("Parsed \(imports.count) import declaration\(imports.count != 1 ? "s" : "") in source file at \(sourcePath.path)")
        log("Parsed source structure for module `\(sourcePath.moduleName)` at \(sourcePath.path)")
      } else {
        log("Parsed dependency source structure for module `\(sourcePath.moduleName)` at \(sourcePath.path)")
      }
    }
  }
  
  public init(extractSourcesResult: ExtractSourcesOperationResult,
              checkCacheResult: CheckCacheOperation.Result?) {
    self.extractSourcesResult = extractSourcesResult
    self.checkCacheResult = checkCacheResult
  }
  
  override func run() {
    guard checkCacheResult?.isCached != true else { return }
    time(.parseFiles) {
      let operations = extractSourcesResult.targetPaths.map({
        SubOperation(sourcePath: $0, shouldMock: true)
      }) + extractSourcesResult.dependencyPaths.map({
        SubOperation(sourcePath: $0, shouldMock: false)
      })
      let queue = OperationQueue.createForActiveProcessors()
      queue.addOperations(operations, waitUntilFinished: true)
      result.parsedFiles = operations.compactMap({ $0.result.parsedFile })
    }
    result.imports = Set(result.parsedFiles.flatMap({ $0.imports }))
    result.moduleDependencies = extractSourcesResult.moduleDependencies
  }
}

private extension Path {
  func getFile() throws -> File {
    let url = URL(fileURLWithPath: String(describing: absolute()), isDirectory: false)
    return try File(contents: String(contentsOf: url, encoding: .utf8))
  }
}

private extension File {
  /// Parses a file line-by-line looking for valid import and compilation directive declarations.
  func parse() -> (imports: Set<String>, compilationDirective: [CompilationDirective]) {
    // All Swift files implicitly import the Swift stdlib core.
    var imports: Set<String> = ["import Swift"]
    var compilationDirectives = [CompilationDirective]()
    var provisionalCompilationDirectives = [CompilationDirective]()

    var currentOffset: Int64 = 0 // TODO: Defer offset calculation until a macro is actually found.
    
    contents
      .substringComponents(separatedBy: "\n")
      .forEach({ line in
        let lineOffset = Int64(line.utf8.count) + (currentOffset > 0 ? 1 : 0)
        defer { currentOffset += lineOffset }
        
        let lineContents = line.trimmingCharacters(in: .whitespaces)
        guard !lineContents.isEmpty else { return }
        
        imports.formUnion(parseImports(from: lineContents))
        
        let lineRange = currentOffset..<currentOffset+lineOffset
        let (preprocessorMacro, provisionalMacro) =
          parseCompilationDirective(from: lineContents,
                                 range: lineRange,
                                 provisionalDirective: provisionalCompilationDirectives.last)
        if let preprocessorMacro = preprocessorMacro {
          compilationDirectives.append(preprocessorMacro)
          provisionalCompilationDirectives.removeLast()
        }
        if let provisionalMacro = provisionalMacro {
          provisionalCompilationDirectives.append(provisionalMacro)
        }
      })
    
    return (imports, compilationDirectives.sorted())
  }
  
  // MARK: Line processors
  
  private func parseImports(from lineContents: String) -> [String] {
    guard lineContents.hasPrefix("import ") ||
      lineContents.hasPrefix("@testable import ") ||
      lineContents.hasPrefix(";")
      else { return [] }
    
    return lineContents.substringComponents(separatedBy: ";")
      .map({ $0.trimmingCharacters(in: .whitespacesAndNewlines) })
      .filter({ $0.hasPrefix("import ") || $0.hasPrefix("@testable import ") })
      .map({String($0
        .substringComponents(separatedBy: "/").first!
        .trimmingCharacters(in: .whitespacesAndNewlines)) })
  }
  
  private func parseCompilationDirective(from lineContents: String,
                                         range: Range<Int64>,
                                         provisionalDirective: CompilationDirective?)
    -> (directive: CompilationDirective?, provisionalDirective: CompilationDirective?) {
      guard lineContents.hasPrefix("#") else { return (nil, nil) }
      
      if lineContents.hasPrefix("#if") {
        return (nil, CompilationDirective(range: range, declaration: lineContents))
      } else if lineContents.hasPrefix("#else") {
        guard let provisionalDirective = provisionalDirective else {
          logWarning("Unmatched compilation directive `#else` declaration")
          return (nil, nil)
        }
        let directiveRange = provisionalDirective.range.lowerBound..<range.lowerBound
        let directive = CompilationDirective(range: directiveRange,
                                             declaration: provisionalDirective.declaration)
        let provisional = CompilationDirective(range: range,
                                               declaration: "#if !(\(provisionalDirective.condition))")
        return (directive, provisional)
      } else if lineContents.hasPrefix("#endif") {
        guard let provisionalDirective = provisionalDirective else {
          logWarning("Unmatched compilation directive `#endif` declaration")
          return (nil, nil)
        }
        let directiveRange = provisionalDirective.range.lowerBound..<range.lowerBound
        let directive = CompilationDirective(range: directiveRange,
                                             declaration: provisionalDirective.declaration)
        return (directive, nil)
      } else {
        logWarning("Invalid compilation directive `\(lineContents)`")
        return (nil, nil)
      }
  }
}
