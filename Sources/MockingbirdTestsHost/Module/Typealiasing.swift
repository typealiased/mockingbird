//
//  Typealiasing.swift
//  MockingbirdModuleTestsHost
//
//  Created by Andrew Chang on 9/15/19.
//

import Foundation

public typealias NSObject = TopLevelType
public typealias NSObjectProtocol = ExternalModuleScopedAssociatedTypeProtocol

public protocol ExternalModuleScopedAssociatedTypeProtocol {
  associatedtype Element
  associatedtype Subelement
  associatedtype Data: ExternalModuleScopedAssociatedTypeProtocol where Data.Element == NSObject
}

public protocol ExternalModuleScopedTypealiasedProtocol {
  func request(object: NSObject) -> NSObject
  func request(object: Foundation.NSObject) -> Foundation.NSObject
  func genericRequest<T: NSObjectProtocol>(object: T)
    -> T where T.Element == Foundation.NSObjectProtocol, T.Subelement == NSObject
  
  // MARK: Optional overloads
  func request(object: NSObject?) -> NSObject?
  func request(object: Foundation.NSObject?) -> Foundation.NSObject?
  func genericRequest<T: NSObjectProtocol>(object: T?)
    -> T? where T.Element == Foundation.NSObjectProtocol?, T.Subelement == NSObject?
  
  // MARK: Concrete context qualification
  typealias MyArray<T> = Array<T>
  typealias MyDictionary<K: Hashable, V> = Dictionary<K, V>
  func method(array: MyArray<String>)
  func method(dictionary: MyDictionary<String, Bool>)
}

