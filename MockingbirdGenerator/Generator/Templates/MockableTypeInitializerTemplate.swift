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
        let typeNamePrefix = mockableTypeTemplate.abstractMockProtocolName
        let template = MockableTypeInitializerTemplate(
          mockableTypeTemplate: MockableTypeTemplate(mockableType: type,
                                                     abstractTypeNamePrefix: typeNamePrefix),
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
  
  private enum Constants {
    static let genericMockTypeName = "__ReturnType"
    static let anyInitializerProxyTypeName = "Mockingbird.Initializable"
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
  
  private func getAllSpecializedGenericTypes(with containingTypeNames: [String]) -> [String] {
    guard mockableTypeTemplate.mockableType.isInGenericContainingType
      else { return mockableTypeTemplate.allSpecializedGenericTypesList }
    return getAllSpecializedGenericTypesList(with: containingTypeNames)
  }

  private func renderInitializer(with containingTypeNames: [String]) -> String {
    let mockableType = mockableTypeTemplate.mockableType
    let kind = mockableType.kind
    let genericTypeContext = mockableType.genericTypeContext
    
    let genericTypeConstraints: [String]
    let metatype: String
    
    if requiresGenericInitializer {
      genericTypeConstraints = getAllSpecializedGenericTypes(with: containingTypeNames)
      let mockName = mockableTypeTemplate.createScopedName(with: containingTypeNames,
                                                           genericTypeContext: genericTypeContext,
                                                           suffix: "Mock")
      metatype = "\(mockName).Type"
    } else {
      genericTypeConstraints = []
      let scopedName = mockableTypeTemplate.createScopedName(with: containingTypeNames,
                                                             genericTypeContext: genericTypeContext)
      let metatypeKeyword = (kind == .class ? "Type" : "Protocol")
      metatype = "\(mockableType.moduleName).\(scopedName).\(metatypeKeyword)"
    }
    
    let returnType: String
    let returnExpression: String
    let returnTypeDescription: String
    let implicitReturnType: String
    let dummyReturnType: String
    let dummyReturnExpression: String
    
    let implicitMockTypeCreatorAttributes: String
    let coercedMockTypeCreatorAttributes: String
    
    let mockTypeScopedName =
      mockableTypeTemplate.createScopedName(with: containingTypeNames,
                                            genericTypeContext: genericTypeContext,
                                            suffix: "Mock")
    
    if !mockableTypeTemplate.shouldGenerateDefaultInitializer {
      // Requires an initializer proxy to create the partial class mock.
      returnType = "\(mockTypeScopedName).InitializerProxy"
      returnExpression = "\(returnType)()"
      returnTypeDescription = "an initializable class mock"
      dummyReturnType = "\(mockTypeScopedName).InitializerProxy.Dummy"
      dummyReturnExpression = "\(dummyReturnType)()"
      implicitReturnType = Constants.anyInitializerProxyTypeName
      
      let unavailableMessage = """
      Initialize this class mock using 'mock(\(mockTypeScopedName).self).initialize(...)'
      """
      coercedMockTypeCreatorAttributes = """
      @available(swift, obsoleted: 3.0, message: "\(unavailableMessage)")
      """
      implicitMockTypeCreatorAttributes = """
      @available(*, deprecated, message: "\(unavailableMessage)")
      """
    } else {
      // Does not require an initializer proxy.
      returnType = mockableTypeTemplate.abstractMockProtocolName
      returnExpression = "\(mockTypeScopedName)(sourceLocation: SourceLocation(file, line))"
      returnTypeDescription = "a " + (kind == .class ? "class" : "protocol") + " mock"
      dummyReturnType = mockTypeScopedName
      dummyReturnExpression = returnExpression
      implicitReturnType = returnType
      
      let mockedTypeScopedName =
        mockableTypeTemplate.createScopedName(with: containingTypeNames,
                                              genericTypeContext: genericTypeContext)
      coercedMockTypeCreatorAttributes = """
      @available(swift, obsoleted: 3.0, renamed: "dummy", message: "Store the mock in a variable of type '\(mockTypeScopedName)' or use 'dummy(\(mockedTypeScopedName).self)' to create a non-mockable dummy object")
      """
      implicitMockTypeCreatorAttributes = ""
    }
    
    let allGenericTypes = genericTypeConstraints.isEmpty ? "" :
      "<\(genericTypeConstraints.joined(separator: ", "))>"
    let allGenericTypesWithSpecificReturnType = "<" + (
      genericTypeConstraints + [Constants.genericMockTypeName + ": " + returnType]
    ).joined(separator: ", ") + ">"
    let allGenericTypesWithWildcardReturnType = "<" + (
      genericTypeConstraints + [Constants.genericMockTypeName]
    ).joined(separator: ", ") + ">"
    
    let abstractMockType = """
    public protocol \(mockableTypeTemplate.abstractMockProtocolName) {}
    """
    
    let creatorDocumentation = """
    /// Initialize \(returnTypeDescription) of `\(mockableTypeTemplate.fullyQualifiedName)`.
    """
    
    // Implicit mock type declarations, e.g. `let mock = mock(Bird.self)`
    let implicitMockTypeCreator = """
    \(creatorDocumentation)\(implicitMockTypeCreatorAttributes.isEmpty ? "" : "\n")\( implicitMockTypeCreatorAttributes)
    public func mock\(allGenericTypes)(_ type: \(metatype), file: StaticString = #file, line: UInt = #line) -> \(implicitReturnType) {
      return \(returnExpression)
    }
    """
    
    // Explicit mock type declarations, e.g. `let mock: BirdMock = mock(Bird.self)`
    let explicitMockTypeCreator = """
    \(creatorDocumentation)
    public func mock\(allGenericTypesWithSpecificReturnType)(_ type: \(metatype), file: StaticString = #file, line: UInt = #line) -> \(Constants.genericMockTypeName) {
      return \(returnExpression) as! \(Constants.genericMockTypeName)
    }
    """
    
    // Dummy object type declarations, e.g. `let dummy: Bird = dummy(Bird.self)`
    let dummyObjectTypeCreator = """
    /// Create a dummy object of `\(mockableTypeTemplate.fullyQualifiedName)`.
    public func dummy\(allGenericTypes)(_ type: \(metatype), file: StaticString = #file, line: UInt = #line) -> \(dummyReturnType) {
      return \(dummyReturnExpression)
    }
    """
    
    // Coerced mock type declarations, e.g. `let mock: Bird = mock(Bird.self)`
    let coercedMockTypeCreator = """
    \(creatorDocumentation)
    \(coercedMockTypeCreatorAttributes)
    public func mock\(allGenericTypesWithWildcardReturnType)(_ type: \(metatype)) -> \(Constants.genericMockTypeName) { fatalError() }
    """
    
    return [abstractMockType,
            implicitMockTypeCreator,
            explicitMockTypeCreator,
            dummyObjectTypeCreator,
            coercedMockTypeCreator].joined(separator: "\n\n")
  }
}
