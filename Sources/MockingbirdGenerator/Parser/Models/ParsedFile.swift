//
//  ParsedFile.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 4/22/20.
//

import Foundation
import PathKit
import SourceKittenFramework
import SwiftSyntax

struct ParsedFile {
  let file: File
  let data: Data?
  let path: Path
  let moduleName: String
  let importDeclarations: Set<ImportDeclaration>
  let compilationDirectives: [CompilationDirective]
  let structure: Structure
  let shouldMock: Bool
  
  var imports: Set<String> {
    return Set(importDeclarations.map({ $0.fullDeclaration }))
  }
  var importedModuleNames: Set<String> {
    return Set(importDeclarations.map({ $0.moduleName }))
  }
  
  init(file: File,
       path: Path,
       moduleName: String,
       importDeclarations: Set<ImportDeclaration>,
       compilationDirectives: [CompilationDirective],
       structure: Structure,
       shouldMock: Bool) {
    self.file = file
    self.data = file.contents.data(using: .utf8, allowLossyConversion: false)
    self.path = path
    self.moduleName = moduleName
    self.importDeclarations = importDeclarations
    self.compilationDirectives = compilationDirectives
    self.structure = structure
    self.shouldMock = shouldMock
  }
  
  init(from other: ParsedFile, shouldMock: Bool) {
    self.init(file: other.file,
              path: other.path,
              moduleName: other.moduleName,
              importDeclarations: other.importDeclarations,
              compilationDirectives: other.compilationDirectives,
              structure: other.structure,
              shouldMock: shouldMock)
  }
}

struct CompilationDirective: Comparable, Hashable {
  let range: Range<Int64> // Byte offset bounds of the compilation directive declaration.
  let declaration: String
  let condition: String?
  
  var negatedCondition: String? {
    guard let condition = self.condition else { return nil }
    return "!(\(condition))"
  }
  
  enum PoundKeyword: String {
    case `if` = "#if"
    case `elseif` = "#elseif"
    case `else` = "#else"
    case `warning` = "#warning"
    case `error` = "#error"
    
    var isLogical: Bool {
      switch self {
      case .if, .elseif, .else: return true
      case .warning, .error: return false
      }
    }
  }
  
  init?(from clause: IfConfigClauseSyntax,
        priorDirectives: [CompilationDirective],
        converter: SourceLocationConverter) {
    guard PoundKeyword(rawValue: clause.poundKeyword.withoutTrivia().text)?.isLogical == true
      else { return nil }
    
    self.condition = clause.condition?
      .withoutTrivia()
      .description
      .trimmingCharacters(in: .whitespacesAndNewlines)
    
    let sourceRange = clause.sourceRange(converter: converter,
                                         afterLeadingTrivia: true,
                                         afterTrailingTrivia: true)
    let directiveRange = Int64(sourceRange.start.offset)..<Int64(sourceRange.end.offset)
    
    // Account for compilation directives that are not the first clause, e.g. `#elseif` by chaining
    // the condition with previous ones logically.
    var allConditions = priorDirectives.compactMap({ $0.negatedCondition })
    if let condition = self.condition { allConditions.append(condition) }
    let conditionChain = allConditions.joined(separator: " && ")
    
    self.range = directiveRange
    self.declaration = PoundKeyword.if.rawValue + " " + conditionChain
  }
  
  static func < (lhs: CompilationDirective, rhs: CompilationDirective) -> Bool {
    return lhs.range.lowerBound < rhs.range.lowerBound
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(declaration)
    hasher.combine(condition)
  }
}

struct ImportDeclaration: Hashable {
  let moduleName: String
  let fullPath: String
  let fullDeclaration: String
  let offset: Int64
  
  init(moduleName: String, fullPath: String, fullDeclaration: String, offset: Int64) {
    self.moduleName = moduleName
    self.fullPath = fullPath
    self.fullDeclaration = fullDeclaration
    self.offset = offset
  }

  init(_ moduleName: String, testable: Bool = false) {
    self.moduleName = moduleName
    self.fullPath = moduleName
    self.fullDeclaration = (testable ? "@testable " : "") + "import " + moduleName
    self.offset = 0
  }
}
