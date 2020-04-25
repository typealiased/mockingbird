//
//  SubscriptMethodTemplate.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 4/18/20.
//

import Foundation

/// Subscripts are a special case and require synthesizing getters and setters for matching.
class SubscriptMethodTemplate: MethodTemplate {
  override var mockedDeclarations: String {
    let attributes = declarationAttributes.isEmpty ? "" : "\n  \(declarationAttributes)"
    let stubbedSetterImplementationCall =
      stubbedImplementationCall(parameterTypes: methodParameterTypesForSubscriptSetter,
                                parameterNames: methodParameterNamesForSubscriptSetterInvocation,
                                returnTypeName: "Void")
    return """
      // MARK: Mocked \(fullNameForMocking)
    \(attributes)
      public \(overridableModifiers)\(uniqueDeclaration) {
        get {
          let invocation: Mockingbird.Invocation = Mockingbird.Invocation(selectorName: "\(uniqueDeclarationForSubscriptGetter)", arguments: [\(mockArgumentMatchers)])
    \(stubbedImplementationCall().indent())
        }
        set {
          let invocation: Mockingbird.Invocation = Mockingbird.Invocation(selectorName: "\(uniqueDeclarationForSubscriptSetter)", arguments: [\(mockArgumentMatchersForSubscriptSetter)])
    \(stubbedSetterImplementationCall.indent())
        }
      }
    """
  }
  
  override var frameworkDeclarations: String {
    let attributes = declarationAttributes.isEmpty ? "" : "  \(declarationAttributes)\n"
    let getterReturnTypeName = unwrappedReturnTypeName
    let setterReturnTypeName = "Void"
    
    let getterInvocationType = "(\(methodParameterTypes)) \(returnTypeAttributesForMatching)-> \(getterReturnTypeName)"
    let setterInvocationType = "(\(methodParameterTypesForSubscriptSetter)) \(returnTypeAttributesForMatching)-> \(setterReturnTypeName)"
    
    var mockableMethods = [String]()
    
    let mockableGenericGetterTypes = [Constants.subscriptType,
                                      getterInvocationType,
                                      getterReturnTypeName].joined(separator: ", ")
    let mockableGenericSetterTypes = [Constants.subscriptType,
                                      setterInvocationType,
                                      setterReturnTypeName].joined(separator: ", ")
    
    mockableMethods.append(matchableSubscript(isGetter: true,
                                              attributes: attributes,
                                              mockableGenericTypes: mockableGenericGetterTypes))
    mockableMethods.append(matchableSubscript(isGetter: false,
                                              attributes: attributes,
                                              mockableGenericTypes: mockableGenericSetterTypes))
    
    if isVariadicMethod {
      // Allow methods with a variadic parameter to use variadics when stubbing.
      mockableMethods.append(matchableSubscript(isGetter: true,
                                                isVariadic: true,
                                                attributes: attributes,
                                                mockableGenericTypes: mockableGenericGetterTypes))
      mockableMethods.append(matchableSubscript(isGetter: false,
                                                isVariadic: true,
                                                attributes: attributes,
                                                mockableGenericTypes: mockableGenericSetterTypes))
    }
    
    return mockableMethods.joined(separator: "\n\n")
  }
  
  func matchableSubscript(isGetter: Bool,
                          isVariadic: Bool = false,
                          attributes: String,
                          mockableGenericTypes: String) -> String {
    let variant: FunctionVariant = isGetter ? .subscriptGetter : .subscriptSetter
    let fullName = self.fullName(for: .matching(useVariadics: isVariadic, variant: variant))
    let namePrefix = isGetter ? "get" : "set"
    
    let selectorName = isGetter ?
      uniqueDeclarationForSubscriptGetter : uniqueDeclarationForSubscriptSetter
    let argumentMatchers: String
    if isVariadic {
      argumentMatchers = isGetter ?
        resolvedVariadicArgumentMatchers : resolvedVariadicArgumentMatchersForSubscriptSetter
    } else {
      argumentMatchers = isGetter ?
        resolvedArgumentMatchers : resolvedArgumentMatchersForSubscriptSetter
    }
    
    return """
    \(attributes)  public \(regularModifiers)func \(namePrefix)\(fullName.capitalizedFirst) -> Mockingbird.Mockable<\(mockableGenericTypes)>\(genericConstraints) {
    \(argumentMatchers)
        let invocation: Mockingbird.Invocation = Mockingbird.Invocation(selectorName: "\(selectorName)", arguments: arguments)
        return Mockingbird.Mockable<\(mockableGenericTypes)>(mock: \(mockObject), invocation: invocation)
      }
    """
  }
  
  lazy var uniqueDeclarationForSubscriptGetter: String = {
    let fullName = self.fullName(for: .mocking(variant: .subscriptGetter))
    return "get.\(fullName)\(returnTypeAttributesForMocking) -> \(specializedReturnTypeName)\(genericConstraints)"
  }()
  
  lazy var uniqueDeclarationForSubscriptSetter: String = {
    let fullName = self.fullName(for: .mocking(variant: .subscriptSetter))
    return "set.\(fullName)\(returnTypeAttributesForMocking) -> \(specializedReturnTypeName)\(genericConstraints)"
  }()
  
  lazy var mockArgumentMatchersForSubscriptSetter: String = {
    return (mockArgumentMatchersList + ["Mockingbird.ArgumentMatcher(`newValue`)"])
      .joined(separator: ", ")
  }()
  
  lazy var methodParameterTypesForSubscriptSetter: String = {
    return (methodParameterTypesList + [unwrappedReturnTypeName]).joined(separator: ", ")
  }()
  
  lazy var methodParameterNamesForSubscriptSetterInvocation: String = {
     return (methodParameterNamesForInvocationList + ["`newValue`"]).joined(separator: ", ")
   }()
}
