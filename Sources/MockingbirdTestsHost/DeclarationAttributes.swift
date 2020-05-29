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

@objc(MKBObjectiveCProtocol) protocol ObjectiveCProtocol {
  @objc var objcVariable: Bool { get }
  @objc(isNominalObjcVariable) var nominalObjcVariable: Bool { get }
  var variable: Bool { get }
  
  @objc func objcMethod() -> Bool
  @objc(isNominalObjcMethod) func nominalObjcMethod() -> Bool
  func method() -> Bool
}

class ObjectiveCProtocolImplementer: ObjectiveCProtocol {
  var objcVariable: Bool = true
  var nominalObjcVariable: Bool = true
  var variable: Bool = true
  
  func objcMethod() -> Bool { return true }
  func nominalObjcMethod() -> Bool { return true }
  func method() -> Bool { return true }
}

@objc(MKBObjectiveCClass) class ObjectiveCClass: Foundation.NSObject {
  @objc var objcVariable = true
  @objc(isNominalObjcVariable) var nominalObjcVariable = true
  @objc var objcComputedVariable: Bool {
    @objc(getIsObjcComputedVariable) get { return true }
  }
  var variable: Bool = true
  
  @objc func objcMethod() -> Bool { return true }
  @objc(isNominalObjcMethod) func nominalObjcMethod() -> Bool { return true }
  func method() -> Bool { return true }
}
