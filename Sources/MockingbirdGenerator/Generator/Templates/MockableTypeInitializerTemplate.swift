//
//  MockableTypeInitializerTemplate.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 9/14/19.
//

import Foundation

struct MockableTypeInitializerTemplate: Template {
  let mockableTypeTemplate: MockableTypeTemplate
  let containingTypeNames: [String]
  
  init(mockableTypeTemplate: MockableTypeTemplate, containingTypeNames: [String]) {
    self.mockableTypeTemplate = mockableTypeTemplate
    self.containingTypeNames = containingTypeNames
  }
  
  func render() -> String {
    let nestedContainingTypeNames = containingTypeNames + [mockableTypeTemplate.mockableType.name]
    let initializers = [renderInitializer(with: containingTypeNames)] +
      mockableTypeTemplate.mockableType.containedTypes.map({ type -> String in
        let typeTemplate = MockableTypeTemplate(
          mockableType: type,
          mockedTypeNames: mockableTypeTemplate.mockedTypeNames
        )
        let initializerTemplate = MockableTypeInitializerTemplate(
          mockableTypeTemplate: typeTemplate,
          containingTypeNames: nestedContainingTypeNames
        )
        return initializerTemplate.render()
      })
    let allInitializers = String(lines: initializers, spacing: 2)
    let (directiveStart, directiveEnd) = mockableTypeTemplate.compilationDirectiveDeclaration
    guard !directiveStart.isEmpty else { return allInitializers }
    return String(lines: [directiveStart, allInitializers, directiveEnd])
  }
  
  private var isAssociatedTypeProtocol: Bool {
    let mockableType = mockableTypeTemplate.mockableType
    guard mockableType.kind == .protocol else { return false }
    return !mockableType.genericTypes.isEmpty || mockableType.hasSelfConstraint
  }
  
  private func genGenericTypes(with containingTypeNames: [String]) -> [String] {
    guard mockableTypeTemplate.mockableType.isInGenericContainingType
      else { return mockableTypeTemplate.genericTypes }
    
    let mockableType = mockableTypeTemplate.mockableType
    return mockableType.genericTypeContext.enumerated().flatMap({
      (index, genericTypeNames) -> [String] in
      guard let containingTypeName = containingTypeNames.get(index) else { return genericTypeNames }
      // Disambiguate generic types that shadow those defined by a containing type.
      return genericTypeNames.map({ containingTypeName + "_" + $0 })
    }) + mockableType.genericTypes.map({ $0.flattenedDeclaration })
  }

  private func renderInitializer(with containingTypeNames: [String]) -> String {
    let mockableType = mockableTypeTemplate.mockableType
    let kind = mockableType.kind
    let genericTypeContext = mockableType.genericTypeContext
    let genericTypes = genGenericTypes(with: containingTypeNames)
    let genericTypeConstraints = genericTypes.isEmpty ? "" : "<\(separated: genericTypes)>"
    
    let metatype: String
    let supportingTypeDeclaration: String // A concrete type for protocols with associated types.
    
    if isAssociatedTypeProtocol {
      metatype = "\(mockableType.name)\(mockableTypeTemplate.allGenericTypes).Type"
      supportingTypeDeclaration = NominalTypeDefinitionTemplate(
        declaration: "public enum \(mockableType.name)",
        genericTypes: genericTypes,
        body: "").render()
    } else {
      let scopedName = mockableTypeTemplate.createScopedName(with: containingTypeNames,
                                                             genericTypeContext: genericTypeContext,
                                                             moduleQualified: true)
      let metatypeKeyword = (kind == .class ? "Type" : "Protocol")
      metatype = "\(scopedName).\(metatypeKeyword)"
      supportingTypeDeclaration = ""
    }
    
    let returnType: String
    let returnStatement: String
    let returnTypeDescription: String
    
    let mockTypeScopedName =
      mockableTypeTemplate.createScopedName(with: containingTypeNames,
                                            genericTypeContext: genericTypeContext,
                                            suffix: "Mock")
    
    if !mockableTypeTemplate.isAvailable {
      // Unavailable mocks do not generate real initializers.
      returnType = mockTypeScopedName
      returnStatement = "fatalError()"
      returnTypeDescription = mockableTypeTemplate.unavailableMockAttribute
    } else if !mockableTypeTemplate.shouldGenerateDefaultInitializer {
      // Requires an initializer proxy to create the partial class mock.
      returnType = "\(mockTypeScopedName).InitializerProxy.Type"
      returnStatement = "return \(mockTypeScopedName).InitializerProxy.self"
      returnTypeDescription = "/// Returns an abstract mock which should be initialized using `mock(\(mockableTypeTemplate.mockableType.name).self).initialize(…)`."
    } else {
      // Does not require an initializer proxy.
      returnType = mockTypeScopedName
      returnStatement = "return \(mockTypeScopedName)(sourceLocation: Mockingbird.SourceLocation(file, line))"
      returnTypeDescription = "/// Returns a concrete mock of `\(mockableTypeTemplate.mockableType.name)`."
    }
    
    return """
    \(supportingTypeDeclaration)\(returnTypeDescription)
    public func mock\(genericTypeConstraints)(_ type: \(metatype), file: StaticString = #file, line: UInt = #line) -> \(returnType) {
      \(returnStatement)
    }
    """
  }
}
