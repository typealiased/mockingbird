//
//  Extensions.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 8/21/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import AppKit

protocol ExtendableProtocol {
  func trivialBaseMethod()
  var baseVariable: Bool { get }
}
extension ExtendableProtocol {
  func trivialExtendedMethod() {}
  func parameterizedExtendedMethod(param1: Bool) {}
  func parameterizedReturningExtendedMethod(param1: Bool) -> Bool { return true }
  var extendedVariable: Bool { return true }
}
extension ExtendableProtocol {
  func anotherTrivialExtendedMethod() {}
  var anotherExtendedVariable: Bool { return true }
}

protocol InheritsExtendableProtocol: ExtendableProtocol {
  func trivialChildMethod()
  var childVariable: Bool { get }
}

class NonExtendableClass {
  func trivialBaseMethod() {}
  var baseVariable: Bool { return true }
}
extension NonExtendableClass {
  func trivialExtendedMethod() {}
  func parameterizedExtendedMethod(param1: Bool) {}
  func parameterizedReturningExtendedMethod(param1: Bool) -> Bool { return true }
  var extendedVariable: Bool { return true }
}
extension NonExtendableClass: Encodable {
  func encode(to encoder: Encoder) throws {}
}

extension NSViewController {
  enum ExtendedEnum {
    case foo
    class NestedExtendedClass {}
  }
  class ExtendedClass {
    enum NestedExtendedEnum { case bar }
  }
}
protocol ViewControllerExtensionReferencer {
  var extendedEnumVariable: NSViewController.ExtendedEnum { get set }
  var extendedNestedEnumVariable: NSViewController.ExtendedClass.NestedExtendedEnum { get set }
  var extendedClassVariable: NSViewController.ExtendedClass { get set }
  var extendedNestedClassVariable: NSViewController.ExtendedEnum.NestedExtendedClass { get set }
}
