import Foundation
import MockingbirdGenerator
import PathKit

struct OptionGroupArgumentEncoding: Encoder {
  final class EncodedArguments {
    private(set) var arguments: [String] = []
    func append(_ values: [String]) {
      arguments.append(contentsOf: values)
    }
  }
  
  var codingPath: [CodingKey] = []
  var userInfo: [CodingUserInfoKey: Any] = [:]
  let data: EncodedArguments
  let pathConfig: OptionArgumentEncoding.PathConfiguration?
  
  init(arguments: EncodedArguments = EncodedArguments(),
       pathConfig: OptionArgumentEncoding.PathConfiguration? = nil) {
    self.data = arguments
    self.pathConfig = pathConfig
  }
  
  func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key: CodingKey {
    var container = OptionGroupArgumentKeyedEncoding<Key>(arguments: data, pathConfig: pathConfig)
    container.codingPath = codingPath
    return KeyedEncodingContainer<Key>(container)
  }
  
  func unkeyedContainer() -> UnkeyedEncodingContainer {
    fatalError("Unsupported encoding container type")
  }
  
  func singleValueContainer() -> SingleValueEncodingContainer {
    fatalError("Unsupported encoding container type")
  }
}

struct OptionGroupArgumentKeyedEncoding<Key: CodingKey>: KeyedEncodingContainerProtocol {
  
  var codingPath: [CodingKey] = []
  private let data: OptionGroupArgumentEncoding.EncodedArguments
  private let pathConfig: OptionArgumentEncoding.PathConfiguration?
  
  init(arguments: OptionGroupArgumentEncoding.EncodedArguments,
       pathConfig: OptionArgumentEncoding.PathConfiguration?) {
    self.data = arguments
    self.pathConfig = pathConfig
  }
  
  mutating func encodeNil(forKey key: Key) throws {}
  
  mutating func encode(_ value: Bool, forKey key: Key) throws {}
  
  mutating func encode(_ value: String, forKey key: Key) throws {}
  
  mutating func encode(_ value: Double, forKey key: Key) throws {}
  
  mutating func encode(_ value: Float, forKey key: Key) throws {}
  
  mutating func encode(_ value: Int, forKey key: Key) throws {}
  
  mutating func encode(_ value: Int8, forKey key: Key) throws {}
  
  mutating func encode(_ value: Int16, forKey key: Key) throws {}
  
  mutating func encode(_ value: Int32, forKey key: Key) throws {}
  
  mutating func encode(_ value: Int64, forKey key: Key) throws {}
  
  mutating func encode(_ value: UInt, forKey key: Key) throws {}
  
  mutating func encode(_ value: UInt8, forKey key: Key) throws {}
  
  mutating func encode(_ value: UInt16, forKey key: Key) throws {}
  
  mutating func encode(_ value: UInt32, forKey key: Key) throws {}
  
  mutating func encode(_ value: UInt64, forKey key: Key) throws {}
  
  mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
    guard let argumentsEncoder = value as? EncodableArguments else {
      fatalError("Unexpected value type in option group encoder")
    }
    
    var optionEncoding = OptionArgumentEncoding(pathConfig: pathConfig)
    optionEncoding.codingPath = codingPath + [key]
    try argumentsEncoder.encodeOptions(to: optionEncoding)
    
    var flagEncoding = FlagArgumentEncoding()
    flagEncoding.codingPath = codingPath + [key]
    try argumentsEncoder.encodeFlags(to: flagEncoding)
    
    data.append(optionEncoding.data.arguments)
    data.append(flagEncoding.data.arguments)
  }
  
  mutating func nestedContainer<NestedKey: CodingKey>(
    keyedBy keyType: NestedKey.Type,
    forKey key: Key
  ) -> KeyedEncodingContainer<NestedKey> {
    fatalError("Nested option groups are not supported")
  }
  
  mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
    fatalError("Unsupported encoding container type")
  }
  
  mutating func superEncoder() -> Encoder {
    let superKey = Key(stringValue: "super")!
    return superEncoder(forKey: superKey)
  }
  
  mutating func superEncoder(forKey key: Key) -> Encoder {
    var encoding = OptionGroupArgumentEncoding(arguments: data)
    encoding.codingPath = codingPath + [key]
    return encoding
  }
}
