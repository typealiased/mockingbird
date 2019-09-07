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
