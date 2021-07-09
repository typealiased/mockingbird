//
//  SourceFileAuxiliaryParser.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 4/22/20.
//

import Foundation
import SwiftSyntax

class SourceFileAuxiliaryParser: SyntaxVisitor {
  var importedPaths = Set<ImportDeclaration>()
  var directives = [CompilationDirective]()
  
  // Initializing a `SourceLocationConverter` is quite expensive.
  let lazyConverter: () -> SourceLocationConverter
  lazy var converter: SourceLocationConverter = { lazyConverter() }()

  init(with lazyConverter: @escaping () -> SourceLocationConverter) {
    self.lazyConverter = lazyConverter
  }
  
  func parse<SyntaxType: SyntaxProtocol>(_ node: SyntaxType) -> Self {
    walk(node)
    return self
  }
  
  /// Handle import declarations, e.g. `import Mockingbird`
  override func visit(_ node: ImportDeclSyntax) -> SyntaxVisitorContinueKind {
    guard let moduleName = node.path.first?.name.text else { return .skipChildren }
    let fullPath = node.path.withoutTrivia().description
    let fullDeclaration = node.withoutTrivia().description
    let sourceRange = node.sourceRange(converter: converter,
                                       afterLeadingTrivia: true,
                                       afterTrailingTrivia: true)
    importedPaths.insert(ImportDeclaration(moduleName: moduleName,
                                           fullPath: fullPath,
                                           fullDeclaration: fullDeclaration,
                                           offset: Int64(sourceRange.start.offset)))
    return .skipChildren
  }
  
  /// Handle conditional compilation blocks, parsing out compilation directives, e.g. `#if DEBUG`
  override func visit(_ node: IfConfigDeclSyntax) -> SyntaxVisitorContinueKind {
    let nodeDirectives = node.clauses.reduce(into: [CompilationDirective](), { (result, clause) in
      guard let directive = CompilationDirective(from: clause,
                                                 priorDirectives: result,
                                                 converter: converter) else { return }
      result.append(directive)
    })
    directives.append(contentsOf: nodeDirectives)
    return .visitChildren // Could contain other declarations we need, so visit children as well.
  }
  
  
  // MARK: - Optimizations
  
  override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
    return .skipChildren
  }
  
  override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
    return .skipChildren
  }
}
