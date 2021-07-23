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
    
    let failable = method.attributes.contains(.failable) ? "?" : ""
    let scopedName = mockableScopedName
    let declaration = "public static func \(fullNameForInitializerProxy)\(returnTypeAttributesForMocking) -> \(scopedName)\(failable)\(genericConstraints)"
    
    let body = !context.shouldGenerateThunks ? MockableTypeTemplate.Constants.thunkStub : """
    let mock: \(scopedName)\(failable) = \(FunctionCallTemplate(
                                            name: scopedName,
                                            parameters: method.parameters,
                                            isThrowing: method.isThrowing))
    mock\(failable).mockingbirdContext.sourceLocation = SourceLocation(__file, __line)
    return mock
    """
    
    return FunctionDefinitionTemplate(attributes: method.attributes.safeDeclarations,
                                      declaration: declaration,
                                      body: body).render()
  }
  
  override var mockedDeclarations: String {
    // We can't usually infer what concrete arguments to pass to the designated initializer.
    guard !method.attributes.contains(.convenience) else { return "" }
    
    let trivia = "// MARK: Mocked \(fullNameForMocking)"
    let declaration = "public \(overridableModifiers)\(uniqueDeclaration)"
    
    if isClassBound {
      // Class-defined initializer, called from an `InitializerProxy`.
      let body = !context.shouldGenerateThunks ? MockableTypeTemplate.Constants.thunkStub :
        FunctionCallTemplate(name: "super.init",
                             parameters: method.parameters,
                             isThrowing: method.attributes.contains(.throws)).render()
      return String(lines: [
        trivia,
        FunctionDefinitionTemplate(attributes: method.attributes.safeDeclarations,
                                   declaration: declaration,
                                   body: body).render(),
      ])
    } else if !context.containsOverridableDesignatedInitializer {
      // Pure protocol or class-only protocol with no class-defined initializers.
      let body = !context.shouldGenerateThunks ? MockableTypeTemplate.Constants.thunkStub :
        (context.protocolClassConformance == nil ? "" :
          FunctionCallTemplate(name: "super.init").render())
      return String(lines: [
        trivia,
        FunctionDefinitionTemplate(attributes: method.attributes.safeDeclarations,
                                   declaration: declaration,
                                   body: body).render(),
      ])
    } else {
      // Unavailable class-only protocol-defined initializer, should not be used directly.
      let initializerSuffix = context.protocolClassConformance != nil ? ".initialize(...)" : ""
      let errorMessage = "Please use 'mock(\(context.mockableType.name).self)\(initializerSuffix)' to initialize a concrete mock instance"
      let deprecated = "@available(*, deprecated, message: \(doubleQuoted: errorMessage))"
      return String(lines: [
        trivia,
        FunctionDefinitionTemplate(attributes: method.attributes.safeDeclarations + [deprecated],
                                   declaration: declaration,
                                   body: "fatalError(\(doubleQuoted: errorMessage))").render(),
      ])
    }
  }
  
  override var synthesizedDeclarations: String { return "" }
  
  lazy var fullNameForInitializerProxy: String = {
    return fullName(for: .initializerProxy)
  }()
  
  override var overridableUniqueDeclaration: String {
    return "\(fullNameForMocking)\(returnTypeAttributesForMocking)\(genericConstraints) "
  }
}
