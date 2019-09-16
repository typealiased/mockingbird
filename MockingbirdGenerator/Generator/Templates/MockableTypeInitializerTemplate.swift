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
    return initializers.joined(separator: "\n\n")
  }

  private func renderInitializer(with containingTypeNames: [String]) -> String {
    let allGenericTypes = mockableTypeTemplate.allGenericTypes
    let kind = mockableTypeTemplate.mockableType.kind
    let scopedName = mockableTypeTemplate.createScopedName(with: containingTypeNames)
    let fullyQualifiedScopedName = "\(mockableTypeTemplate.mockableType.moduleName).\(scopedName)"
    let genericMethodAttribute: String
    let metatype: String
    if allGenericTypes.count > 0
      || (mockableTypeTemplate.mockableType.hasOpaqueInheritedType && kind == .protocol) {
      let specializedGenericTypes = (["MockType: \(fullyQualifiedScopedName)"] +
        mockableTypeTemplate.allSpecializedGenericTypesList).joined(separator: ", ")
      genericMethodAttribute = "<" + specializedGenericTypes + ">"
      metatype = "MockType.Type"
    } else {
      genericMethodAttribute = ""
      let metatypeKeyword = (kind == .class ? "Type" : "Protocol")
      metatype = "\(fullyQualifiedScopedName).\(metatypeKeyword)"
    }
    
    let returnType: String
    let returnObject: String
    let returnTypeDescription: String
    let mockedScopedName = mockableTypeTemplate.createScopedName(with: containingTypeNames,
                                                                 suffix: "Mock")
    if kind == .class &&
      mockableTypeTemplate.mockableType.methods.contains(where: { $0.isInitializer }) {
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
    /// Create a source-attributed `\(mockableTypeTemplate.fullyQualifiedName)\(allGenericTypes)` \(returnTypeDescription).
    public func mock\(genericMethodAttribute)(file: StaticString = #file, line: UInt = #line, _ type: \(metatype)) -> \(returnType) {
      return \(returnObject)
    }
    """
  }
}
