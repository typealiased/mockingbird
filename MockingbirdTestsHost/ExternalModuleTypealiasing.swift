//
//  ExternalModuleTypealiasing.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 9/15/19.
//

import Foundation
import MockingbirdModuleTestsHost

protocol InheritingExternalModuleScopedAssociatedTypeProtocol: ExternalModuleScopedAssociatedTypeProtocol {}
protocol InheritingExternalModuleScopedTypealiasedProtocol: ExternalModuleScopedTypealiasedProtocol {}

class ImplementingExternalModuleScopedTypealiasedProtocol: ExternalModuleScopedTypealiasedProtocol {
  func request(object: MockingbirdModuleTestsHost.NSObject)
    -> MockingbirdModuleTestsHost.NSObject { fatalError() }
  func request(object: Foundation.NSObject) -> Foundation.NSObject { fatalError() }
  func genericRequest<T: MockingbirdModuleTestsHost.NSObjectProtocol>(object: T)
    -> T where T.Element == Foundation.NSObjectProtocol,
    T.Subelement == MockingbirdModuleTestsHost.NSObject
  { fatalError() }

  // MARK: Optional overloads
  func request(object: MockingbirdModuleTestsHost.NSObject?)
    -> MockingbirdModuleTestsHost.NSObject? { fatalError() }
  func request(object: Foundation.NSObject?) -> Foundation.NSObject? { fatalError() }
  func genericRequest<T: MockingbirdModuleTestsHost.NSObjectProtocol>(object: T?)
    -> T? where T.Element == Foundation.NSObjectProtocol?,
    T.Subelement == MockingbirdModuleTestsHost.NSObject?
  { fatalError() }
  
  // MARK: Concrete context qualification
  func method(array: MyArray<String>) {}
  func method(dictionary: MyDictionary<String, Bool>) {}
}
