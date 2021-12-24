//
//  OptionArgumentEncoding.swift
//  MockingbirdCli
//
//  Created by typealias on 12/20/21.
//

import Foundation
import MockingbirdGenerator
import PathKit

/// Encodes key-value options, normalizing values based on the configuration.
struct OptionArgumentEncoding: Encoder {
  class EncodedArguments {
    private(set) var arguments: [String] = []
    
    func append(_ argument: String?) {
      if let argument = argument {
        arguments.append(argument)
      }
    }
    
    func append(_ name: CodingKey?, _ argument: String?) {
      append(name?.longArgumentName)
      append(argument)
    }
  }
  
  struct PathConfiguration {
    let sourceRoot: Path
    let substitutionStyle: SubstitutionStyle
  }
  
  var codingPath: [CodingKey] = []
  var userInfo: [CodingUserInfoKey: Any] = [:]
  let data: EncodedArguments
  let pathConfig: PathConfiguration?
  
  init(arguments: EncodedArguments = EncodedArguments(),
       pathConfig: PathConfiguration? = nil) {
    self.data = arguments
    self.pathConfig = pathConfig
    self.userInfo[Self.pathConfigUserInfoKey] = pathConfig
  }
  
  static var pathConfigUserInfoKey: CodingUserInfoKey {
    CodingUserInfoKey(rawValue: "pathConfig")!
  }
  static func encode(_ path: Path, with encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    guard let config = encoder.userInfo[Self.pathConfigUserInfoKey] as? PathConfiguration else {
      return try container.encode(path.abbreviated())
    }
    let relativePath = path.abbreviated()
      .replacingOccurrences(of: config.sourceRoot.abbreviated(),
                            with: config.substitutionStyle.wrap("SRCROOT"))
    try container.encode(relativePath)
  }
  
  func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
    var container = OptionArgumentKeyedEncoding<Key>(arguments: data, pathConfig: pathConfig)
    container.codingPath = codingPath
    return KeyedEncodingContainer<Key>(container)
  }
  
  func unkeyedContainer() -> UnkeyedEncodingContainer {
    var container = OptionArgumentUnkeyedEncoding(arguments: data, pathConfig: pathConfig)
    container.codingPath = codingPath
    return container
  }
  
  func singleValueContainer() -> SingleValueEncodingContainer {
    var container = OptionArgumentSingleValueEncoding(arguments: data, pathConfig: pathConfig)
    container.codingPath = codingPath
    return container
  }
}

struct OptionArgumentKeyedEncoding<Key: CodingKey>: KeyedEncodingContainerProtocol {
  
  var codingPath: [CodingKey] = []
  private let data: OptionArgumentEncoding.EncodedArguments
  private let pathConfig: OptionArgumentEncoding.PathConfiguration?
  
  init(arguments: OptionArgumentEncoding.EncodedArguments,
       pathConfig: OptionArgumentEncoding.PathConfiguration?) {
    self.data = arguments
    self.pathConfig = pathConfig
  }
  
  mutating func encodeNil(forKey key: Key) throws {
    // No-op
  }
  
  mutating func encode(_ value: Bool, forKey key: Key) throws {
    data.append(key, value ? "1" : "0")
  }
  
  mutating func encode(_ value: String, forKey key: Key) throws {
    data.append(key, value.doubleQuoted)
  }
  
  mutating func encode(_ value: Double, forKey key: Key) throws {
    data.append(key, String(describing: value))
  }
  
  mutating func encode(_ value: Float, forKey key: Key) throws {
    data.append(key, String(describing: value))
  }
  
  mutating func encode(_ value: Int, forKey key: Key) throws {
    data.append(key, String(describing: value))
  }
  
  mutating func encode(_ value: Int8, forKey key: Key) throws {
    data.append(key, String(describing: value))
  }
  
  mutating func encode(_ value: Int16, forKey key: Key) throws {
    data.append(key, String(describing: value))
  }
  
  mutating func encode(_ value: Int32, forKey key: Key) throws {
    data.append(key, String(describing: value))
  }
  
  mutating func encode(_ value: Int64, forKey key: Key) throws {
    data.append(key, String(describing: value))
  }
  
  mutating func encode(_ value: UInt, forKey key: Key) throws {
    data.append(key, String(describing: value))
  }
  
  mutating func encode(_ value: UInt8, forKey key: Key) throws {
    data.append(key, String(describing: value))
  }
  
  mutating func encode(_ value: UInt16, forKey key: Key) throws {
    data.append(key, String(describing: value))
  }
  
  mutating func encode(_ value: UInt32, forKey key: Key) throws {
    data.append(key, String(describing: value))
  }
  
  mutating func encode(_ value: UInt64, forKey key: Key) throws {
    data.append(key, String(describing: value))
  }
  
  mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
    var encoding = OptionArgumentEncoding(arguments: data, pathConfig: pathConfig)
    encoding.codingPath = codingPath + [key]
    try value.encode(to: encoding)
  }
  
  mutating func nestedContainer<NestedKey: CodingKey>(
    keyedBy keyType: NestedKey.Type,
    forKey key: Key
  ) -> KeyedEncodingContainer<NestedKey> {
    var container = OptionArgumentKeyedEncoding<NestedKey>(arguments: data, pathConfig: pathConfig)
    container.codingPath = codingPath + [key]
    return KeyedEncodingContainer(container)
  }
  
  mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
    var container = OptionArgumentUnkeyedEncoding(arguments: data, pathConfig: pathConfig)
    container.codingPath = codingPath + [key]
    return container
  }
  
  mutating func superEncoder() -> Encoder {
    let superKey = Key(stringValue: "super")!
    return superEncoder(forKey: superKey)
  }
  
  mutating func superEncoder(forKey key: Key) -> Encoder {
    var encoding = OptionArgumentEncoding(arguments: data, pathConfig: pathConfig)
    encoding.codingPath = codingPath + [key]
    return encoding
  }
}

struct OptionArgumentUnkeyedEncoding: UnkeyedEncodingContainer {
  class UnkeyedEncodedArguments: OptionArgumentEncoding.EncodedArguments {
    override func append(_ name: CodingKey?, _ argument: String?) {
      append(argument)
    }
  }
  
  var codingPath: [CodingKey] = []
  var count = 0
  
  let data: OptionArgumentEncoding.EncodedArguments
  let pathConfig: OptionArgumentEncoding.PathConfiguration?
  
  private mutating func appendArgument(_ argument: String) {
    count += 1
    // Handle the current argument parsing strategy for arrays: `--option item1 item2 item3`.
    data.append(count == 1 ? codingPath.last : nil, argument)
  }
  
  init(arguments: OptionArgumentEncoding.EncodedArguments,
       pathConfig: OptionArgumentEncoding.PathConfiguration?) {
    self.data = arguments
    self.pathConfig = pathConfig
  }
  
  mutating func encodeNil() throws {
    // No-op
  }
  
  mutating func encode(_ value: Bool) throws {
    appendArgument(value ? "1" : "0")
  }
  
  mutating func encode(_ value: String) throws {
    appendArgument(value.doubleQuoted)
  }
  
  mutating func encode(_ value: Double) throws {
    appendArgument(String(describing: value))
  }
  
  mutating func encode(_ value: Float) throws {
    appendArgument(String(describing: value))
  }
  
  mutating func encode(_ value: Int) throws {
    appendArgument(String(describing: value))
  }
  
  mutating func encode(_ value: Int8) throws {
    appendArgument(String(describing: value))
  }
  
  mutating func encode(_ value: Int16) throws {
    appendArgument(String(describing: value))
  }
  
  mutating func encode(_ value: Int32) throws {
    appendArgument(String(describing: value))
  }
  
  mutating func encode(_ value: Int64) throws {
    appendArgument(String(describing: value))
  }
  
  mutating func encode(_ value: UInt) throws {
    appendArgument(String(describing: value))
  }
  
  mutating func encode(_ value: UInt8) throws {
    appendArgument(String(describing: value))
  }
  
  mutating func encode(_ value: UInt16) throws {
    appendArgument(String(describing: value))
  }
  
  mutating func encode(_ value: UInt32) throws {
    appendArgument(String(describing: value))
  }
  
  mutating func encode(_ value: UInt64) throws {
    appendArgument(String(describing: value))
  }
  
  mutating func encode<T: Encodable>(_ value: T) throws {
    let subdata = UnkeyedEncodedArguments()
    var encoding = OptionArgumentEncoding(arguments: subdata, pathConfig: pathConfig)
    encoding.codingPath = codingPath
    try value.encode(to: encoding)
    subdata.arguments.forEach({ appendArgument($0) })
  }
  
  mutating func nestedContainer<NestedKey: CodingKey>(
    keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> {
    var container = OptionArgumentKeyedEncoding<NestedKey>(arguments: data, pathConfig: pathConfig)
    container.codingPath = codingPath
    return KeyedEncodingContainer(container)
  }
  
  mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
    var container = OptionArgumentUnkeyedEncoding(arguments: data, pathConfig: pathConfig)
    container.codingPath = codingPath
    return container
  }
  
  mutating func superEncoder() -> Encoder {
    var encoding = OptionArgumentEncoding(arguments: data, pathConfig: pathConfig)
    encoding.codingPath = codingPath
    return encoding
  }
}

struct OptionArgumentSingleValueEncoding: SingleValueEncodingContainer {
  
  var codingPath: [CodingKey] = []
  let data: OptionArgumentEncoding.EncodedArguments
  let pathConfig: OptionArgumentEncoding.PathConfiguration?
  
  init(arguments: OptionArgumentEncoding.EncodedArguments,
       pathConfig: OptionArgumentEncoding.PathConfiguration?) {
    self.data = arguments
    self.pathConfig = pathConfig
  }
  
  mutating func encodeNil() throws {
    // No-op
  }
  
  mutating func encode(_ value: Bool) throws {
    data.append(codingPath.last, value ? "1" : "0")
  }
  
  mutating func encode(_ value: String) throws {
    data.append(codingPath.last, value.doubleQuoted)
  }
  
  mutating func encode(_ value: Double) throws {
    data.append(codingPath.last, String(describing: value))
  }
  
  mutating func encode(_ value: Float) throws {
    data.append(codingPath.last, String(describing: value))
  }
  
  mutating func encode(_ value: Int) throws {
    data.append(codingPath.last, String(describing: value))
  }
  
  mutating func encode(_ value: Int8) throws {
    data.append(codingPath.last, String(describing: value))
  }
  
  mutating func encode(_ value: Int16) throws {
    data.append(codingPath.last, String(describing: value))
  }
  
  mutating func encode(_ value: Int32) throws {
    data.append(codingPath.last, String(describing: value))
  }
  
  mutating func encode(_ value: Int64) throws {
    data.append(codingPath.last, String(describing: value))
  }
  
  mutating func encode(_ value: UInt) throws {
    data.append(codingPath.last, String(describing: value))
  }
  
  mutating func encode(_ value: UInt8) throws {
    data.append(codingPath.last, String(describing: value))
  }
  
  mutating func encode(_ value: UInt16) throws {
    data.append(codingPath.last, String(describing: value))
  }
  
  mutating func encode(_ value: UInt32) throws {
    data.append(codingPath.last, String(describing: value))
  }
  
  mutating func encode(_ value: UInt64) throws {
    data.append(codingPath.last, String(describing: value))
  }
  
  mutating func encode<T: Encodable>(_ value: T) throws {
    var encoding = OptionArgumentEncoding(arguments: data, pathConfig: pathConfig)
    encoding.codingPath = codingPath
    try value.encode(to: encoding)
  }
}
