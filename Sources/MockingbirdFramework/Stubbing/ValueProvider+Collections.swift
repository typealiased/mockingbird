//
//  ValueProvider+Collections.swift
//  MockingbirdFramework
//
//  Created by Andrew Chang on 4/12/20.
//

import Foundation

extension Array: Providable {
  public static func createInstance() -> Self? { Array() }
}

extension Set: Providable {
  public static func createInstance() -> Self? { Set() }
}

extension Dictionary: Providable {
  public static func createInstance() -> Self? { Dictionary() }
}

public extension ValueProvider {  
  /// A value provider with default-initialized collections.
  ///
  /// https://developer.apple.com/documentation/foundation/collections
  static let collectionsProvider = ValueProvider(values: [
    ObjectIdentifier(NSCountedSet.self): NSCountedSet(),
    ObjectIdentifier(NSOrderedSet.self): NSOrderedSet(),
    ObjectIdentifier(NSMutableOrderedSet.self): NSMutableOrderedSet(),
    ObjectIdentifier(NSPurgeableData.self): NSPurgeableData(),
    ObjectIdentifier(NSPointerArray.self): NSPointerArray(),
  ], identifiers: [
    Array<Any>.providableIdentifier,
    Set<AnyHashable>.providableIdentifier,
    Dictionary<AnyHashable, Any>.providableIdentifier,
  ])
}
