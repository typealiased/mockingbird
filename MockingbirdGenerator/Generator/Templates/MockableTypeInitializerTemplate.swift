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
        let template = MockableTypeInitializerTemplate(
          mockableTypeTemplate: MockableTypeTemplate(mockableType: type),
          containingTypeNames: nestedContainingTypeNames
        )
        return template.render()
      })
    let allInitializers = initializers.joined(separator: "\n\n")
    let (preprocessorStart, preprocessorEnd) = mockableTypeTemplate.compilationDirectiveDeclaration
    guard !preprocessorStart.isEmpty else { return allInitializers }
    return [preprocessorStart,
            allInitializers,
            preprocessorEnd]
      .joined(separator: "\n\n")
  }
  
  private var requiresGenericInitializer: Bool {
    let mockableType = mockableTypeTemplate.mockableType
    let isSelfConstrainedProtocol = mockableType.kind == .protocol && mockableType.hasSelfConstraint
    return !mockableType.genericTypes.isEmpty
      || mockableType.isInGenericContainingType
      || isSelfConstrainedProtocol
  }
  
  private func getAllSpecializedGenericTypesList(with containingTypeNames: [String]) -> [String] {
    let mockableType = mockableTypeTemplate.mockableType
    return mockableType.genericTypeContext.enumerated().flatMap({
      (index, genericTypeNames) -> [String] in
      guard let containingTypeName = containingTypeNames.get(index) else { return genericTypeNames }
      // Disambiguate generic types that shadow those defined by a containing type.
      return genericTypeNames.map({ containingTypeName + "_" + $0 })
    }) + mockableType.genericTypes.map({ $0.flattenedDeclaration })
  }
  
  private func getAllSpecializedGenericTypes(with containingTypeNames: [String]) -> String {
    guard mockableTypeTemplate.mockableType.isInGenericContainingType
      else { return mockableTypeTemplate.allSpecializedGenericTypes }
    let allSpecializedGenericTypesList =
      getAllSpecializedGenericTypesList(with: containingTypeNames).joined(separator: ", ")
    return "<" + allSpecializedGenericTypesList + ">"
  }

  private func renderInitializer(with containingTypeNames: [String]) -> String {
    let mockableType = mockableTypeTemplate.mockableType
    let kind = mockableType.kind
    let genericTypeContext = mockableType.genericTypeContext
    
    let genericMethodAttribute: String
    let metatype: String
    
    if requiresGenericInitializer {
      genericMethodAttribute = getAllSpecializedGenericTypes(with: containingTypeNames)
      let mockName = mockableTypeTemplate.createScopedName(with: containingTypeNames,
                                                           genericTypeContext: genericTypeContext,
                                                           suffix: "Mock")
      metatype = "\(mockName).Type"
    } else {
      genericMethodAttribute = ""
      let scopedName = mockableTypeTemplate.createScopedName(with: containingTypeNames,
                                                             genericTypeContext: genericTypeContext)
      let metatypeKeyword = (kind == .class ? "Type" : "Protocol")
      metatype = "\(mockableType.moduleName).\(scopedName).\(metatypeKeyword)"
    }
    
    let returnType: String
    let returnObject: String
    let returnTypeDescription: String
    let mockedScopedName =
      mockableTypeTemplate.createScopedName(with: containingTypeNames,
                                            genericTypeContext: genericTypeContext,
                                            suffix: "Mock")
    
    if !mockableTypeTemplate.shouldGenerateDefaultInitializer {
      // Requires an initializer proxy to create the partial class mock.
      returnType = "\(mockedScopedName).InitializerProxy.Type"
      returnObject = "\(mockedScopedName).InitializerProxy.self"
      returnTypeDescription = "class mock metatype"
    } else if kind == .class { // Does not require an initializer proxy.
      returnType = "\(mockedScopedName)"
      returnObject = "\(mockedScopedName)(sourceLocation: SourceLocation(file, line))"
      returnTypeDescription = "concrete class mock instance"
    } else {
      returnType = "\(mockedScopedName)"
      returnObject = "\(mockedScopedName)(sourceLocation: SourceLocation(file, line))"
      returnTypeDescription = "concrete protocol mock instance"
    }
    
    return """
    /// Create a source-attributed `\(mockableTypeTemplate.fullyQualifiedName)` \(returnTypeDescription).
    public func mock\(genericMethodAttribute)(file: StaticString = #file, line: UInt = #line, _ type: \(metatype)) -> \(returnType) {
      return \(returnObject)
    }
    """
  }
}
