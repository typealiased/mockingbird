//
//  SerializationRequest.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 9/7/19.
//

import Foundation

/// Fully qualifies tokenized `DeclaredType` objects given a declaration context.
struct SerializationRequest {
  enum Constants {
    static let selfToken = "<#Self#>"
  }
  
  enum Method: String {
    case notQualified = "notQualified"
    case contextQualified = "contextQualified"
    case moduleQualified = "moduleQualified"
    case actualTypeName = "actualTypeName"
  }
  
  struct Options: OptionSet, Hashable {
    let rawValue: Int
    init(rawValue: Int) {
      self.rawValue = rawValue
    }
    
    static let shouldTokenizeSelf = Options(rawValue: 1 << 0)
    static let shouldExcludeArgumentLabels = Options(rawValue: 1 << 1)
    static let shouldExcludeImplicitlyUnwrappedOptionals = Options(rawValue: 1 << 2)
    
    static let standard: Options = [.shouldTokenizeSelf, .shouldExcludeArgumentLabels]
  }
  
  class Context {
    let moduleNames: [String]
    let referencingModuleName: String? // The module referencing the type in some declaration.
    let containingTypeNames: ArraySlice<String>
    let containingScopes: ArraySlice<String>
    let rawTypeRepository: RawTypeRepository?
    let typealiasRepository: TypealiasRepository?
    init(moduleNames: [String],
         referencingModuleName: String?,
         containingTypeNames: ArraySlice<String>,
         containingScopes: ArraySlice<String>,
         rawTypeRepository: RawTypeRepository?,
         typealiasRepository: TypealiasRepository? = nil) {
      self.moduleNames = moduleNames
      self.referencingModuleName = referencingModuleName
      self.containingTypeNames = containingTypeNames
      self.containingScopes = containingScopes
      self.rawTypeRepository = rawTypeRepository
      self.typealiasRepository = typealiasRepository
    }
    
    convenience init(moduleNames: [String],
                     rawType: RawType,
                     rawTypeRepository: RawTypeRepository,
                     typealiasRepository: TypealiasRepository? = nil) {
      self.init(moduleNames: moduleNames,
                referencingModuleName: rawType.parsedFile.moduleName,
                containingTypeNames: rawType.containingTypeNames[...] + [rawType.name],
                containingScopes: rawType.containingScopes[...] + [rawType.name],
                rawTypeRepository: rawTypeRepository,
                typealiasRepository: typealiasRepository)
    }
    
    convenience init() {
      self.init(moduleNames: [],
                referencingModuleName: nil,
                containingTypeNames: [],
                containingScopes: [],
                rawTypeRepository: nil,
                typealiasRepository: nil)
    }
    
    /// typeName => method => serialized
    fileprivate var memoizedTypeNames = [String: [String: String]]()
  }
  
  let method: Method
  let context: Context
  let options: Options
}

protocol SerializableType {
  func serialize(with request: SerializationRequest) -> String
}

extension SerializationRequest {
  /// Given a `typeName`, serialize it based on the current request context and method.
  func serialize(_ typeName: String) -> String {
    guard typeName != "Self" else { // `Self` can never be typealiased away.
      return (options.contains(.shouldTokenizeSelf) ? Constants.selfToken : typeName)
    }
    
    guard method != .notQualified,
      let rawTypeRepository = context.rawTypeRepository,
      let referencingModuleName = context.referencingModuleName else {
        return typeName // This is a non-qualifying serialization request.
    }
    
    if let memoized = context.memoizedTypeNames[typeName]?[method.rawValue] {
      return memoized
    }
    
    guard let qualifiedTypeNames = rawTypeRepository
      .nearestInheritedType(named: typeName,
                            trimmedName: typeName.removingGenericTyping(),
                            moduleNames: context.moduleNames,
                            referencingModuleName: context.referencingModuleName,
                            containingTypeNames: context.containingTypeNames)?
      .findBaseRawType()?
      .qualifiedModuleNames(from: typeName, context: context.containingScopes)
      else { return typeName }
    context.memoizedTypeNames[typeName]?[Method.contextQualified.rawValue] =
      qualifiedTypeNames.contextQualified
    context.memoizedTypeNames[typeName]?[Method.moduleQualified.rawValue] =
      qualifiedTypeNames.moduleQualified
    switch method {
    case .contextQualified: return qualifiedTypeNames.contextQualified
    case .moduleQualified: return qualifiedTypeNames.moduleQualified
    case .actualTypeName:
      guard let typealiasRepository = context.typealiasRepository else { return typeName }
      let actualTypeName = typealiasRepository
        .actualTypeName(for: qualifiedTypeNames.moduleQualified,
                        rawTypeRepository: rawTypeRepository,
                        moduleNames: context.moduleNames,
                        referencingModuleName: referencingModuleName,
                        containingTypeNames: context.containingTypeNames)
      context.memoizedTypeNames[typeName]?[Method.actualTypeName.rawValue] = actualTypeName
      return actualTypeName
    case .notQualified: return typeName
    }
  }
}
