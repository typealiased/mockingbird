#if canImport(Foundation)
import Foundation
#endif

extension Array: Providable {
  public static func createInstance() -> Self? { Array() }
}

extension Set: Providable {
  public static func createInstance() -> Self? { Set() }
}

extension Dictionary: Providable {
  public static func createInstance() -> Self? { Dictionary() }
}

#if canImport(ObjectiveC)
private let collectionsProviderNSValues = [
  ObjectIdentifier(NSCountedSet.self): NSCountedSet(),
  ObjectIdentifier(NSOrderedSet.self): NSOrderedSet(),
  ObjectIdentifier(NSMutableOrderedSet.self): NSMutableOrderedSet(),
  ObjectIdentifier(NSPurgeableData.self): NSPurgeableData(),
  ObjectIdentifier(NSPointerArray.self): NSPointerArray(),
] as [ObjectIdentifier: Any]
#else
private let collectionsProviderValues = []
#endif
public extension ValueProvider {  
  /// A value provider with default-initialized collections.
  ///
  /// https://developer.apple.com/documentation/foundation/collections
  static let collectionsProvider = ValueProvider(
    values: collectionsProviderNSValues,
    identifiers: [
      Array<Any>.providableIdentifier,
      Set<AnyHashable>.providableIdentifier,
      Dictionary<AnyHashable, Any>.providableIdentifier,
    ])
}
