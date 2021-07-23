//
//  KeyedDecodingContainer+Array.swift
//  MockingbirdGenerator
//
//  Created by typealias on 7/22/21.
//

import Foundation

extension KeyedDecodingContainer {
  /// Decodes a value of the given array type for the given key, if present.
  ///
  /// This method returns `nil` if the container does not have a value
  /// associated with `key`, or if the value is null. The difference between
  /// these states can be distinguished with a `contains(_:)` call.
  ///
  /// - parameter type: The type of value to decode.
  /// - parameter key: The key that the decoded value is associated with.
  /// - returns: A decoded value of the requested type, or `nil` if the
  ///   `Decoder` does not have an entry associated with the given key, or if
  ///   the value is a null value.
  /// - throws: `DecodingError.typeMismatch` if the encountered encoded value
  ///   is not convertible to the requested type.
  func decodeIfPresent<T: Decodable>(
    _ type: [T].Type,
    forKey key: KeyedDecodingContainer<K>.Key
  ) throws -> [T]? {
    guard contains(key) else {
      return nil
    }
    
    do {
      var container = try nestedUnkeyedContainer(forKey: key)
      var buffer = [T]()
      buffer.reserveCapacity(container.count ?? 0)
      
      while !container.isAtEnd {
        buffer.append(try container.decode(T.self))
      }
      return buffer
    } catch DecodingError.valueNotFound {
      return nil
    }
  }
}
