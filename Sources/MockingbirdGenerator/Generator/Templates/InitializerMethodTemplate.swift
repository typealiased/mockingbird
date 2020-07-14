//
//  InitializerMethodTemplate.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 4/18/20.
//

import Foundation

/// Renders initializer method declarations.
class InitializerMethodTemplate: MethodTemplate {
  /// Synthetic initializer for static/class instances.
  override var classInitializerProxy: String? {
    guard method.isInitializer,
      isClassBound || !context.containsOverridableDesignatedInitializer
      else { return nil }
    // We can't usually infer what concrete arguments to pass to the designated initializer.
    guard !method.attributes.contains(.convenience) else { return nil }
    let attributes = declarationAttributes.isEmpty ? "" : "\(declarationAttributes)\n"
    let failable = method.attributes.contains(.failable) ? "?" : ""
    let scopedName = mockableScopedName
    
    let body: String
    if context.shouldGenerateThunks {
      body = """
      {
        let mock: \(scopedName)\(failable) = \(tryInvocation)\(scopedName)(\(superCallParameters))
        mock\(failable).sourceLocation = SourceLocation(__file, __line)
        return mock
      }
      """
    } else {
      body = "{ \(MockableTypeTemplate.Constants.thunkStub) }"
    }
    
    return """
    \(attributes)public static func \(fullNameForInitializerProxy)\(returnTypeAttributesForMocking) -> \(scopedName)\(failable)\(genericConstraints) \(body)
    """
  }
  
  override var mockedDeclarations: String {
    let attributes = declarationAttributes.isEmpty ? "" : "\n  \(declarationAttributes)"
    
    // We can't usually infer what concrete arguments to pass to the designated initializer.
    guard !method.attributes.contains(.convenience) else { return "" }
    let functionDeclaration = "public \(overridableModifiers)\(uniqueDeclaration)"
    
    if isClassBound {
      // Class-defined initializer, called from an `InitializerProxy`.
      let trySuper = method.attributes.contains(.throws) ? "try " : ""
      
      let body: String
      if context.shouldGenerateThunks {
        body = """
        {
            \(trySuper)super.init(\(superCallParameters))
            Mockingbird.checkVersion(for: self)
            let invocation: Mockingbird.Invocation = Mockingbird.Invocation(selectorName: "\(uniqueDeclaration)", arguments: [\(mockArgumentMatchers)], returnType: Swift.ObjectIdentifier((\(unwrappedReturnTypeName)).self))
            \(contextPrefix)mockingContext.didInvoke(invocation)
          }
        """
      } else {
        body = "{ \(MockableTypeTemplate.Constants.thunkStub) }"
      }
      return """
        // MARK: Mocked \(fullNameForMocking)
      \(attributes)
        \(functionDeclaration)\(body)
      """
    } else if !context.containsOverridableDesignatedInitializer {
      // Pure protocol or class-only protocol with no class-defined initializers.
      let superCall = context.protocolClassConformance != nil ? "\n    super.init()" : ""
      
      let body: String
      if context.shouldGenerateThunks {
        body = """
        {\(superCall)
            Mockingbird.checkVersion(for: self)
            let invocation: Mockingbird.Invocation = Mockingbird.Invocation(selectorName: "\(uniqueDeclaration)", arguments: [\(mockArgumentMatchers)], returnType: Swift.ObjectIdentifier((\(unwrappedReturnTypeName)).self))
            \(contextPrefix)mockingContext.didInvoke(invocation)
          }
        """
      } else {
        body = "{ \(MockableTypeTemplate.Constants.thunkStub) }"
      }
      
      return """
        // MARK: Mocked \(fullNameForMocking)
      \(attributes)
        \(functionDeclaration)\(body)
      """
    } else {
      // Unavailable class-only protocol-defined initializer, should not be used directly.
      let initializerSuffix = context.protocolClassConformance != nil ? ".initialize(...)" : ""
      let errorMessage = "Please use 'mock(\(context.mockableType.name).self)\(initializerSuffix)' to initialize a concrete mock instance"
      return """
        // MARK: Mocked \(fullNameForMocking)
      \(attributes)
        @available(*, deprecated, message: "\(errorMessage)")
        \(functionDeclaration){
          fatalError("\(errorMessage)")
        }
      """
    }
  }
  
  override var frameworkDeclarations: String { return "" }
  
  lazy var fullNameForInitializerProxy: String = {
    return fullName(for: .initializerProxy)
  }()
  
  override var overridableUniqueDeclaration: String {
    return "\(fullNameForMocking)\(returnTypeAttributesForMocking)\(genericConstraints) "
  }
}
