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
    static let selfTokenIndicator = "#"
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
    let genericTypeContext: [[String]]
    
    init(moduleNames: [String],
         referencingModuleName: String?,
         containingTypeNames: ArraySlice<String>,
         containingScopes: ArraySlice<String>,
         rawTypeRepository: RawTypeRepository?,
         typealiasRepository: TypealiasRepository? = nil,
         genericTypeContext: [[String]]) {
      self.moduleNames = moduleNames
      self.referencingModuleName = referencingModuleName
      self.containingTypeNames = containingTypeNames
      self.containingScopes = containingScopes
      self.rawTypeRepository = rawTypeRepository
      self.typealiasRepository = typealiasRepository
      self.genericTypeContext = genericTypeContext
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
                typealiasRepository: typealiasRepository,
                genericTypeContext: rawType.genericTypeContext + [rawType.genericTypes])
    }
    
    convenience init(from context: Context,
                     moduleNames: [String]? = nil,
                     referencingModuleName: String? = nil,
                     containingTypeNames: ArraySlice<String>? = nil,
                     containingScopes: ArraySlice<String>? = nil,
                     rawTypeRepository: RawTypeRepository? = nil,
                     typealiasRepository: TypealiasRepository? = nil,
                     genericTypeContext: [[String]]? = nil) {
      self.init(moduleNames: moduleNames ?? context.moduleNames,
                referencingModuleName: referencingModuleName ?? context.referencingModuleName,
                containingTypeNames: containingTypeNames ?? context.containingTypeNames,
                containingScopes: containingScopes ?? context.containingScopes,
                rawTypeRepository: rawTypeRepository ?? context.rawTypeRepository,
                typealiasRepository: typealiasRepository ?? context.typealiasRepository,
                genericTypeContext: genericTypeContext ?? context.genericTypeContext)
    }
    
    convenience init() {
      self.init(moduleNames: [],
                referencingModuleName: nil,
                containingTypeNames: [],
                containingScopes: [],
                rawTypeRepository: nil,
                typealiasRepository: nil,
                genericTypeContext: [])
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
    
    guard !typeName.hasPrefix("Self.") else {
      return options.contains(.shouldTokenizeSelf)
        ? Constants.selfToken + typeName[typeName.index(typeName.startIndex, offsetBy: 4)...]
        : typeName
    }
    
    guard method != .notQualified,
      let rawTypeRepository = context.rawTypeRepository,
      let referencingModuleName = context.referencingModuleName else {
        return typeName // This is a non-qualifying serialization request.
    }
    
    if let memoized = context.memoizedTypeNames[typeName]?[method.rawValue] {
      return memoized
    }
    
    // Don't qualify generic types which could be shadowing types defined at the module level.
    guard !context.genericTypeContext.contains(where: { $0.contains(typeName) }) else {
      return typeName
    }
    
    guard let baseRawType = rawTypeRepository
      .nearestInheritedType(named: typeName,
                            trimmedName: typeName.removingGenericTyping(),
                            moduleNames: context.moduleNames,
                            referencingModuleName: context.referencingModuleName,
                            containingTypeNames: context.containingTypeNames)?
      .findBaseRawType() else { return typeName }
    
    // The base raw type could be a (nested) enum or class defined within an extension.
    var definingModuleName: String? {
      if baseRawType.definedInExtension {
        guard let extensionTypeName = baseRawType.containingTypeNames.first else { return nil }
        guard let extensionRawType = rawTypeRepository
          .nearestInheritedType(named: extensionTypeName,
                                trimmedName: extensionTypeName.removingGenericTyping(),
                                moduleNames: context.moduleNames,
                                referencingModuleName: context.referencingModuleName,
                                containingTypeNames: [])?
          .findBaseRawType() else {
            logWarning("The type `\(typeName)` was defined in an extension for `\(extensionTypeName)` whose source was missing")
            return nil
        }
        return extensionRawType.parsedFile.moduleName
      } else {
        return baseRawType.parsedFile.moduleName
      }
    }
    let qualifiedTypeNames = baseRawType
      .qualifiedModuleNames(from: typeName,
                            context: context.containingScopes,
                            definingModuleName: definingModuleName)
    context.memoizedTypeNames[typeName]?[Method.contextQualified.rawValue] =
      qualifiedTypeNames.contextQualified
    context.memoizedTypeNames[typeName]?[Method.moduleQualified.rawValue] =
      qualifiedTypeNames.moduleQualified
    switch method {
    case .contextQualified: return qualifiedTypeNames.contextQualified
    case .moduleQualified:
      // Exclude the module name if it's is shadowed by a type in one of the imported modules. This
      // will break if the shadowed module also contains type names that conflict with another
      // module. However, name conflicts are much less likely to occur than module name shadowing.
      if rawTypeRepository.isModuleNameShadowed(moduleName: baseRawType.parsedFile.moduleName,
                                                moduleNames: context.moduleNames) {
        return qualifiedTypeNames.moduleQualified
          .substringComponents(separatedBy: ".")[1...]
          .joined(separator: ".")
      } else {
        return qualifiedTypeNames.moduleQualified
      }
    case .actualTypeName:
      guard let typealiasRepository = context.typealiasRepository else { return typeName }
      let actualTypeNames = typealiasRepository
        .actualTypeNames(for: qualifiedTypeNames.moduleQualified,
                         rawTypeRepository: rawTypeRepository,
                         moduleNames: context.moduleNames,
                         referencingModuleName: referencingModuleName,
                         containingTypeNames: context.containingTypeNames)
      let flattenedTypeNames = actualTypeNames.joined(separator: " & ")
      context.memoizedTypeNames[typeName]?[Method.actualTypeName.rawValue] = flattenedTypeNames
      return flattenedTypeNames
    case .notQualified: return typeName
    }
  }
}
