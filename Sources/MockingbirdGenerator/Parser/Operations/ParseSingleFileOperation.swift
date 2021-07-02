//
//  ParseSingleFileOperation.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 4/22/20.
//

import Foundation
import PathKit
import SourceKittenFramework
import SwiftSyntax

class ParseSingleFileOperation: BasicOperation {
  class Result {
    fileprivate(set) var parsedFile: ParsedFile?
  }
  
  let result = Result()
  override var description: String { "Single File" }
  
  let sourcePath: SourcePath
  let shouldMock: Bool
  let sourceKitResult: ParseSourceKitOperation.Result
  let swiftSyntaxResult: ParseSwiftSyntaxOperation.Result
  
  init(sourcePath: SourcePath,
       shouldMock: Bool,
       sourceKitResult: ParseSourceKitOperation.Result,
       swiftSyntaxResult: ParseSwiftSyntaxOperation.Result) {
    self.sourcePath = sourcePath
    self.shouldMock = shouldMock
    self.sourceKitResult = sourceKitResult
    self.swiftSyntaxResult = swiftSyntaxResult
  }
  
  private static var memoizedParsedFiles = Synchronized<[SourcePath: ParsedFile]>([:])
  
  override func run() throws {
    let sourcePath = self.sourcePath
    if let memoized = ParseSingleFileOperation.memoizedParsedFiles.read({ $0[sourcePath] }) {
      result.parsedFile = ParsedFile(from: memoized, shouldMock: shouldMock)
      return
    }
    guard let file = sourceKitResult.file, let structure = sourceKitResult.structure else {
      return // SourceKit parsing failed earlier.
    }
    
    let parsedFile = ParsedFile(file: file,
                                path: sourcePath.path,
                                moduleName: sourcePath.moduleName,
                                importDeclarations: swiftSyntaxResult.importDeclarations,
                                compilationDirectives: swiftSyntaxResult.compilationDirectives,
                                structure: structure,
                                shouldMock: shouldMock)
    ParseSingleFileOperation.memoizedParsedFiles.update { $0[sourcePath] = parsedFile }
    result.parsedFile = parsedFile
    
    let totalImportDeclarations = swiftSyntaxResult.importDeclarations.count
    let totalCompilationDirectives = swiftSyntaxResult.compilationDirectives.count
    log("Parsed \(totalImportDeclarations) import declaration\(totalImportDeclarations != 1 ? "s" : "") and \(totalCompilationDirectives) compiler directive\(totalCompilationDirectives != 1 ? "s" : "") in source file at \(sourcePath.path)")
    if shouldMock {
      log("Parsed source structure for module \(sourcePath.moduleName.singleQuoted) at \(sourcePath.path)")
    } else {
      log("Parsed dependency source structure for module \(sourcePath.moduleName.singleQuoted) at \(sourcePath.path)")
    }
  }
}

class ParseSourceKitOperation: BasicOperation {
  class Result {
    fileprivate(set) var structure: Structure?
    fileprivate(set) var file: File?
  }
  
  let result = Result()
  override var description: String { "Parse SourceKit" }
  let sourcePath: SourcePath
  
  init(sourcePath: SourcePath) {
    self.sourcePath = sourcePath
  }
  
  override func run() throws {
    let file = try sourcePath.path.getFile()
    result.file = file
    result.structure = try Structure(file: file)
  }
}

class ParseSwiftSyntaxOperation: BasicOperation {
  class Result {
    fileprivate(set) var importDeclarations = Set<ImportDeclaration>()
    fileprivate(set) var compilationDirectives = [CompilationDirective]()
  }
  
  let result = Result()
  override var description: String { "Parse SwiftSyntax" }
  let sourcePath: SourcePath
  
  init(sourcePath: SourcePath) {
    self.sourcePath = sourcePath
  }
  
  override func run() throws {
    // File reading is not shared with the parse SourceKit operation, but parsing >> reading.
    let file = try sourcePath.path.getFile()
    let sourceFile = try SyntaxParser.parse(source: file.contents)
    let parser = SourceFileAuxiliaryParser(with: {
      SourceLocationConverter(file: "\(self.sourcePath.path)", tree: sourceFile)
    }).parse(sourceFile)
    retainForever(parser)
    
    // All Swift files implicitly import the Swift standard library.
    result.importDeclarations = parser.importedPaths.union([ImportDeclaration("Swift")])
    result.compilationDirectives = parser.directives.sorted()
  }
}

extension Path {
  func getFile() throws -> File {
    let url = URL(fileURLWithPath: String(describing: absolute()), isDirectory: false)
    return try File(contents: String(contentsOf: url, encoding: .utf8))
  }
}
