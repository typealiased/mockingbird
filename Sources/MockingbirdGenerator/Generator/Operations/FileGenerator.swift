//
//  FileGenerator.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/5/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

// swiftlint:disable leading_whitespace

import Foundation
import PathKit
import os.log

class FileGenerator {
  let mockableTypes: [MockableType]
  let mockedTypeNames: Set<String>?
  let parsedFiles: [ParsedFile]
  let config: GenerateFileConfig
  
  init(mockableTypes: [MockableType],
       mockedTypeNames: Set<String>?,
       parsedFiles: [ParsedFile],
       config: GenerateFileConfig) {
    self.mockableTypes = config.onlyMockProtocols ?
      mockableTypes.filter({ $0.kind == .protocol }) : mockableTypes
    self.mockedTypeNames = mockedTypeNames
    self.parsedFiles = parsedFiles
    self.config = config
  }
  
  var outputFilename: String {
    return config.outputPath.components.last ?? "MockingbirdMocks.generated.swift"
  }
  
  private func generateFileHeader() -> PartialFileContent {
    var headerSections = [String]()
    
    if !config.header.isEmpty {
      headerSections.append(String(lines: config.header))
    } else {
      headerSections.append("""
      //
      //  \(outputFilename)
      //  \(config.moduleName)
      //
      //  Generated by Mockingbird v\(mockingbirdVersion.shortString).
      //  DO NOT EDIT
      //
      """)
    }
    
    if config.disableSwiftlint {
      headerSections.append("// swiftlint:disable all")
    }
    
    if let condition = config.compilationCondition {
      headerSections.append("#if \(condition)")
    }
    
    let implicitImports = [
      ImportDeclaration("Foundation"),
      ImportDeclaration("Mockingbird", testable: true),
      ImportDeclaration(config.moduleName, testable: true),
    ].compactMap({ $0?.fullDeclaration })
    
    let explicitImports = parsedFiles
      .filter({ $0.shouldMock })
      .flatMap({ file in
        file.importDeclarations.map({ importDeclaration -> String in
          let compilationDirectives = file.compilationDirectives
            .filter({ $0.range.contains(importDeclaration.offset) })
          guard !compilationDirectives.isEmpty else {
            return importDeclaration.fullDeclaration
          }
          let start = String(lines: compilationDirectives.map({ $0.declaration }))
          let end = String(lines: compilationDirectives.map({ _ in "#endif" }))
          return String(lines: [
            start,
            importDeclaration.fullDeclaration,
            end,
          ])
        })
      })
    
    let allImports = Set(implicitImports + explicitImports).sorted()
    headerSections.append(String(lines: allImports))
    
    return PartialFileContent(contents: String(lines: headerSections, spacing: 2))
  }
  
  private func generateFileBody() -> PartialFileContent {
    guard !mockableTypes.isEmpty else { return PartialFileContent(contents: "") }
    let operations = mockableTypes
      .filter({ mockableType in
        switch config.pruningMethod {
        case .omit:
          guard let typeNames = mockedTypeNames else { return true }
          return mockableType.isReferenced(by: typeNames)
        case .disable, .stub: return true
        }
      })
      .sorted(by: <)
      .flatMap({ mockableType -> [RenderTemplateOperation] in
        let mockableTypeTemplate = MockableTypeTemplate(mockableType: mockableType,
                                                        mockedTypeNames: mockedTypeNames)
        let initializerTemplate = MockableTypeInitializerTemplate(
          mockableTypeTemplate: mockableTypeTemplate,
          containingTypeNames: []
        )
        
        let generateMockableTypeOperation = RenderTemplateOperation(template: mockableTypeTemplate)
        let generateInitializerOperation = RenderTemplateOperation(template: initializerTemplate)
        
        // The initializer accesses lazy vars from `mockableTypeTemplate` which is not thread-safe.
        generateInitializerOperation.addDependency(generateMockableTypeOperation)
        
        retainForever(generateMockableTypeOperation)
        retainForever(generateInitializerOperation)
        
        return [generateMockableTypeOperation, generateInitializerOperation]
      })
    let queue = OperationQueue.createForActiveProcessors()
    queue.addOperations(operations, waitUntilFinished: true)
    let substructure = [PartialFileContent(contents: genericTypesStaticMocks)]
      + operations.map({ PartialFileContent(contents: $0.result.renderedContents) })
    return PartialFileContent(substructure: substructure, delimiter: "\n\n")
  }
  
  private func generateFileFooter() -> PartialFileContent {
    guard config.compilationCondition != nil else { return .empty }
    return PartialFileContent(contents: "\n#endif")
  }
  
  func generate() -> PartialFileContent {
    return PartialFileContent(contents: nil,
                              substructure: [generateFileHeader(),
                                             generateFileBody(),
                                             generateFileFooter()].filter({ !$0.isEmpty }),
                              delimiter: "\n",
                              footer: "\n")
  }
  
  private var genericTypesStaticMocks: String {
    return "private let genericStaticMockContext = Mockingbird.GenericStaticMockContext()"
  }
}
