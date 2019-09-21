//
//  DeclarationAttributes.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 9/6/19.
//

import Foundation

protocol DeclarationAttributesProtocol {
  @available(iOS 10.0, *)
  var availableVariable: String { get }
  
  @available(iOS 10.0, *)
  func availableMethod(param: String) -> Bool
}

class DeclarationAttributesClass {
  @available(iOS 10.0, *)
  var availableVariable: String { return "" }
  
  @available(iOS 10.0, *)
  func availableMethod(param: String) -> Bool { return true }
  
  @objc @available(iOS 10.0, *) @inlinable
  func multipleAttributesMethod(param: String) -> Bool { return true }
}

@objc protocol ObjectiveCProtocol {
  @objc optional var objcVariable: Bool { get }
  var variable: Bool { get }
  
  @objc optional func objcMethod() -> Bool
  func method() -> Bool
}

class ObjectiveCProtocolImplementer: ObjectiveCProtocol {
  var variable: Bool = true
  func method() -> Bool { return true }
}

@objc class ObjectiveCClass: Foundation.NSObject {
  @objc var objcVariable = true
  var variable: Bool = true
  
  @objc func objcMethod() -> Bool { return true }
  func method() -> Bool { return true }
}
