//
//  DeclarationAttributes.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 9/6/19.
//

import Foundation

protocol DeclarationAttributesProtocol {
  @available(iOSMac 10.10, *)
  var availableVariable: String { get }
  
  @available(iOSMac 10.10, *)
  func availableMethod(param: String) -> Bool
}

class DeclarationAttributesClass {
  @available(iOSMac 10.10, *)
  var availableVariable: String { return "" }
  
  @available(iOSMac 10.10, *)
  func availableMethod(param: String) -> Bool { return true }
  
  @objc @available(iOSMac 10.10, *) @inlinable
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
