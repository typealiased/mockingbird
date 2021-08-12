//
//  Generate.swift
//  MockingbirdCli
//
//  Created by typealias on 8/8/21.
//

import ArgumentParser
import Foundation
import MockingbirdGenerator
import PathKit

extension Mockingbird {
  struct Generate: ParsableCommand, EncodableArguments {
    @Option(help: "List of target names to generate mocks for.")
    var targets: [String] // TODO: This will be optional for generator v2
    
    @Option(help: "Path to a Xcode project or a JSON project description.")
    var project: XcodeProjPath?
    
    @Option(help: "The directory containing your project’s source files.")
    var srcroot: DirectoryPath?
    
    @Option(help: "List of mock output file paths for each target.",
            transform: Path.init(stringLiteral:))
    var outputs: [Path] = [] // TODO: This will be optional for generator v2
    
    @Option(help: "The directory containing supporting source files.")
    var support: SupportingSourcesPath?
    
    @Option(help: "The name of the test bundle using the mocks.")
    var testbundle: String? // TODO
    
    @Option(help: "Content to add at the beginning of each generated mock file.")
    var header: [String] = []
    
    @Option(help: "Compilation condition to wrap all generated mocks in, e.g. 'DEBUG'.")
    var condition: String?
    
    @Option(help: "List of diagnostic generator warnings to enable.")
    var diagnostics: [DiagnosticType] = []
    
    @Option(help: "The pruning method to use on unreferenced types.")
    var prune: PruningMethod = .omit
    
    // MARK: Flags
    
    @Flag(help: "Only generate mocks for protocols.")
    var onlyProtocols: Bool = false
    
    @Flag(help: "Disable all SwiftLint rules in generated mocks.")
    var disableSwiftlint: Bool = false
    
    @Flag(help: "Ignore cached mock information stored on disk.")
    var disableCache: Bool = false
    
    @Flag(help: "Only search explicitly imported modules.")
    var disableRelaxedLinking: Bool = false
    
    mutating func validate() throws {
      try validateRequiredArgument(inferArgument(&project), name: "project")
      try validateOptionalArgument(inferArgument(&support), name: "support")
      
      srcroot = srcroot ?? DirectoryPath(path: project?.path.parent())
      try validateRequiredArgument(srcroot, name: "srcroot")
    }
    
    // Will crash in Debug builds if an option or flag is missing a corresponding coding key.
    enum CodingKeys: String, CodingKey {
      // Options
      case targets
      case project
      case srcroot
      case outputs
      case support
      case testbundle
      case header
      case condition
      case diagnostics
      case prune
      
      // Flags
      case onlyProtocols
      case disableSwiftlint
      case disableCache
      case disableRelaxedLinking
    }
    
    func encode(to encoder: Encoder) throws {
      try encodeOptions(to: encoder)
      try encodeFlags(to: encoder)
    }
    
    func encodeOptions(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(targets, forKey: .targets)
      try container.encode(project, forKey: .project)
      try container.encode(srcroot, forKey: .srcroot)
      try container.encode(outputs, forKey: .outputs)
      try container.encode(support, forKey: .support)
      try container.encode(testbundle, forKey: .testbundle)
      try container.encode(header, forKey: .header)
      try container.encode(condition, forKey: .condition)
      try container.encode(diagnostics, forKey: .diagnostics)
      try container.encode(prune, forKey: .prune)
    }
    
    func encodeFlags(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(onlyProtocols, forKey: .onlyProtocols)
      try container.encode(disableSwiftlint, forKey: .disableSwiftlint)
      try container.encode(disableCache, forKey: .disableCache)
      try container.encode(disableRelaxedLinking, forKey: .disableRelaxedLinking)
    }
    
    // TODO: Hook into generator pipeline
  }
}

private extension CodingKey {
  var longArgumentName: String {
    let hyphenatedName = stringValue.unicodeScalars.reduce(into: "") { (name, character) in
      if CharacterSet.uppercaseLetters.contains(character) {
        name += "-" + String(character).localizedLowercase
      } else {
        name += String(character)
      }
    }
    return "--\(hyphenatedName)"
  }
}

protocol EncodableArguments: Encodable {
  func encodeOptions(to encoder: Encoder) throws
  func encodeFlags(to encoder: Encoder) throws
}

class ArgumentsEncoder {
  var sourceRoot: Path?
  var substitutionStyle: SubstitutionStyle = .bash
  
  func encode<T: EncodableArguments>(_ value: T) throws -> [String] {
    var pathConfig: OptionArgumentEncoding.PathConfiguration?
    if let sourceRoot = sourceRoot {
      pathConfig = OptionArgumentEncoding.PathConfiguration(
        sourceRoot: sourceRoot,
        substitutionStyle: substitutionStyle
      )
    }
    
    let optionEncoding = OptionArgumentEncoding(pathConfig: pathConfig)
    try value.encodeOptions(to: optionEncoding)
    
    let flagEncoding = FlagArgumentEncoding()
    try value.encodeFlags(to: flagEncoding)
    
    return optionEncoding.data.arguments + flagEncoding.data.arguments
  }
}

struct OptionArgumentEncoding: Encoder {
  final class EncodedArguments {
    private(set) var arguments: [String] = []
    func append(_ name: CodingKey?, _ argument: String?) {
      if let name = name?.longArgumentName {
        arguments.append(name)
      }
      if let argument = argument {
        arguments.append(argument)
      }
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
  
  init(arguments: EncodedArguments = EncodedArguments(), pathConfig: PathConfiguration? = nil) {
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
      return try container.encode(path.absolute().string)
    }
    let relativePath = path.absolute().string
      .replacingOccurrences(of: config.sourceRoot.absolute().string,
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
  
  var codingPath: [CodingKey] = []
  var count = 0
  
  let data: OptionArgumentEncoding.EncodedArguments
  let pathConfig: OptionArgumentEncoding.PathConfiguration?
  
  private mutating func appendArgument(_ argument: String) {
    data.append(codingPath.last, argument)
    count += 1
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
    var encoding = OptionArgumentEncoding(arguments: data, pathConfig: pathConfig)
    encoding.codingPath = codingPath
    try value.encode(to: encoding)
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
