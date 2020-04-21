//
//  ValueProvider+Collections.swift
//  MockingbirdFramework
//
//  Created by Andrew Chang on 4/12/20.
//

import Foundation

public extension ValueProvider {
  class CollectionsProvider: PresetValueProvider {
    override func provideValue<T>(for type: Array<T>.Type) -> Array<T>? {
      return []
    }
    
    override func provideValue<T>(for type: Set<T>.Type) -> Set<T>? {
      return []
    }
    
    override func provideValue<K, V>(for type: Dictionary<K, V>.Type) -> Dictionary<K, V>? {
      return [:]
    }
    
    override func provideValue<K, V>(for type: NSCache<K, V>.Type) -> NSCache<K, V>? {
      return NSCache()
    }
    
    override func provideValue<K, V>(for type: NSMapTable<K, V>.Type) -> NSMapTable<K, V>? {
      return NSMapTable()
    }
    
    override func provideValue<T>(for type: NSHashTable<T>.Type) -> NSHashTable<T>? {
      return NSHashTable()
    }
  }
  
  /// Provides default-initialized collections.
  /// https://developer.apple.com/documentation/foundation/collections
  static let collectionsProvider: PresetValueProvider = CollectionsProvider(values: [
    ObjectIdentifier(NSCountedSet.self): NSCountedSet(),
    ObjectIdentifier(NSOrderedSet.self): NSOrderedSet(),
    ObjectIdentifier(NSMutableOrderedSet.self): NSMutableOrderedSet(),
    ObjectIdentifier(NSPurgeableData.self): NSPurgeableData(),
    ObjectIdentifier(NSPointerArray.self): NSPointerArray(),
  ])
}
