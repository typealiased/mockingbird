//
//  FlagArgumentEncoding.swift
//  MockingbirdCli
//
//  Created by typealias on 12/20/21.
//

import Foundation

struct FlagArgumentEncoding: Encoder {
  final class EncodedArguments {
    private(set) var arguments: [String] = []
    func append(_ name: CodingKey?) {
      if let name = name?.longArgumentName {
        arguments.append(name)
      }
    }
  }
  
  var codingPath: [CodingKey] = []
  var userInfo: [CodingUserInfoKey: Any] = [:]
  let data: EncodedArguments
  
  init(arguments: EncodedArguments = EncodedArguments()) {
    self.data = arguments
  }
  
  func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
    var container = FlagArgumentKeyedEncoding<Key>(arguments: data)
    container.codingPath = codingPath
    return KeyedEncodingContainer<Key>(container)
  }
  
  func unkeyedContainer() -> UnkeyedEncodingContainer {
    fatalError("Unsupported encoding container type")
  }
  
  func singleValueContainer() -> SingleValueEncodingContainer {
    var container = FlagArgumentSingleValueEncoding(arguments: data)
    container.codingPath = codingPath
    return container
  }
}

struct FlagArgumentKeyedEncoding<Key: CodingKey>: KeyedEncodingContainerProtocol {
  
  var codingPath: [CodingKey] = []
  private let data: FlagArgumentEncoding.EncodedArguments
  
  init(arguments: FlagArgumentEncoding.EncodedArguments) {
    self.data = arguments
  }
  
  mutating func encodeNil(forKey key: Key) throws {
    // No-op
  }
  
  mutating func encode(_ value: Bool, forKey key: Key) throws {
    if value {
      data.append(key)
    }
  }
  
  mutating func encode(_ value: String, forKey key: Key) throws {
    fatalError("Flag arguments must be a 'Bool' type")
  }
  
  mutating func encode(_ value: Double, forKey key: Key) throws {
    fatalError("Flag arguments must be a 'Bool' type")
  }
  
  mutating func encode(_ value: Float, forKey key: Key) throws {
    fatalError("Flag arguments must be a 'Bool' type")
  }
  
  mutating func encode(_ value: Int, forKey key: Key) throws {
    fatalError("Flag arguments must be a 'Bool' type")
  }
  
  mutating func encode(_ value: Int8, forKey key: Key) throws {
    fatalError("Flag arguments must be a 'Bool' type")
  }
  
  mutating func encode(_ value: Int16, forKey key: Key) throws {
    fatalError("Flag arguments must be a 'Bool' type")
  }
  
  mutating func encode(_ value: Int32, forKey key: Key) throws {
    fatalError("Flag arguments must be a 'Bool' type")
  }
  
  mutating func encode(_ value: Int64, forKey key: Key) throws {
    fatalError("Flag arguments must be a 'Bool' type")
  }
  
  mutating func encode(_ value: UInt, forKey key: Key) throws {
    fatalError("Flag arguments must be a 'Bool' type")
  }
  
  mutating func encode(_ value: UInt8, forKey key: Key) throws {
    fatalError("Flag arguments must be a 'Bool' type")
  }
  
  mutating func encode(_ value: UInt16, forKey key: Key) throws {
    fatalError("Flag arguments must be a 'Bool' type")
  }
  
  mutating func encode(_ value: UInt32, forKey key: Key) throws {
    fatalError("Flag arguments must be a 'Bool' type")
  }
  
  mutating func encode(_ value: UInt64, forKey key: Key) throws {
    fatalError("Flag arguments must be a 'Bool' type")
  }
  
  mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
    fatalError("Flag arguments must be a 'Bool' type")
  }
  
  mutating func nestedContainer<NestedKey: CodingKey>(
  keyedBy keyType: NestedKey.Type,
    forKey key: Key
  ) -> KeyedEncodingContainer<NestedKey> {
    fatalError("Flag arguments must be a 'Bool' type")
  }
  
  mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
    fatalError("Flag arguments must be a 'Bool' type")
  }
  
  mutating func superEncoder() -> Encoder {
    fatalError("Flag arguments must be a 'Bool' type")
  }
  
  mutating func superEncoder(forKey key: Key) -> Encoder {
    fatalError("Flag arguments must be a 'Bool' type")
  }
}

struct FlagArgumentSingleValueEncoding: SingleValueEncodingContainer {
  
  var codingPath: [CodingKey] = []
  let data: FlagArgumentEncoding.EncodedArguments
  
  init(arguments: FlagArgumentEncoding.EncodedArguments) {
    self.data = arguments
  }
  
  mutating func encodeNil() throws {
    // No-op
  }
  
  mutating func encode(_ value: Bool) throws {
    if value {
      data.append(codingPath.last)
    }
  }
  
  mutating func encode(_ value: String) throws {
    fatalError("Flag arguments must be a 'Bool' type")
  }
  
  mutating func encode(_ value: Double) throws {
    fatalError("Flag arguments must be a 'Bool' type")
  }
  
  mutating func encode(_ value: Float) throws {
    fatalError("Flag arguments must be a 'Bool' type")
  }
  
  mutating func encode(_ value: Int) throws {
    fatalError("Flag arguments must be a 'Bool' type")
  }
  
  mutating func encode(_ value: Int8) throws {
    fatalError("Flag arguments must be a 'Bool' type")
  }
  
  mutating func encode(_ value: Int16) throws {
    fatalError("Flag arguments must be a 'Bool' type")
  }
  
  mutating func encode(_ value: Int32) throws {
    fatalError("Flag arguments must be a 'Bool' type")
  }
  
  mutating func encode(_ value: Int64) throws {
    fatalError("Flag arguments must be a 'Bool' type")
  }
  
  mutating func encode(_ value: UInt) throws {
    fatalError("Flag arguments must be a 'Bool' type")
  }
  
  mutating func encode(_ value: UInt8) throws {
    fatalError("Flag arguments must be a 'Bool' type")
  }
  
  mutating func encode(_ value: UInt16) throws {
    fatalError("Flag arguments must be a 'Bool' type")
  }
  
  mutating func encode(_ value: UInt32) throws {
    fatalError("Flag arguments must be a 'Bool' type")
  }
  
  mutating func encode(_ value: UInt64) throws {
    fatalError("Flag arguments must be a 'Bool' type")
  }
  
  mutating func encode<T: Encodable>(_ value: T) throws {
    fatalError("Flag arguments must be a 'Bool' type")
  }
}
