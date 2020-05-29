//
//  MockableTypes.swift
//  Mockingbird
//
//  Created by Andrew Chang on 9/15/19.
//

import Foundation

protocol InternalExternalProtocol {
  var variable: Bool { get }
  func method()
}

public protocol PublicExternalProtocol {
  var variable: Bool { get }
  func method()
}

open class ExternalClass {
  var internalVariable = true
  public var publicVariable = true
  open var openVariable = true
  
  func internalMethod() {}
  public func publicMethod() {}
  open func openMethod() {}
}

open class ExternalClassWithInitializer {
  var internalVariable = true
  public var publicVariable = true
  open var openVariable = true
  
  func internalMethod() {}
  public func publicMethod() {}
  open func openMethod() {}
  
  public init() {}
}


// MARK: - Inheritance

open class ExternalBaseClass {
  var baseInternalVariable = true
  public var basePublicVariable = true
  open var baseOpenVariable = true
  
  func baseInternalMethod() {}
  public func basePublicMethod() {}
  open func baseOpenMethod() {}
}

open class ExternalSubclassWithInitializer: ExternalBaseClass {
  var internalVariable = true
  public var publicVariable = true
  open var openVariable = true
  
  func internalMethod() {}
  public func publicMethod() {}
  open func openMethod() {}
  
  public override init() {}
}
