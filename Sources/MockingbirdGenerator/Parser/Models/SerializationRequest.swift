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
    /// `Self` substitution using the final mock type.
    static let selfToken = "#Self#"
    
    static let syntheticSelfTokenIndicator = "%"
    /// Same as `selfToken`, but created by the generator and doesn't affect generics.
    static let syntheticSelfToken = "%Self%"
  }
  
  enum Method: String {
    /// No qualification.
    case notQualified = "notQualified"
    /// Qualified from the referencing scope.
    case contextQualified = "contextQualified"
    /// Fully qualified from the module scope.
    case moduleQualified = "moduleQualified"
    /// Fully qualified, resolved aliased type names.
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
    static let shouldSpecializeTypes = Options(rawValue: 1 << 3)
    
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
    let excludedGenericTypeNames: Set<String>
    let specializationContext: SpecializationContext?
    
    init(moduleNames: [String],
         referencingModuleName: String?,
         containingTypeNames: ArraySlice<String>,
         containingScopes: ArraySlice<String>,
         rawTypeRepository: RawTypeRepository?,
         typealiasRepository: TypealiasRepository? = nil,
         genericTypeContext: [[String]],
         excludedGenericTypeNames: Set<String> = [],
         specializationContext: SpecializationContext? = nil) {
      self.moduleNames = moduleNames
      self.referencingModuleName = referencingModuleName
      self.containingTypeNames = containingTypeNames
      self.containingScopes = containingScopes
      self.rawTypeRepository = rawTypeRepository
      self.typealiasRepository = typealiasRepository
      self.genericTypeContext = genericTypeContext
      self.excludedGenericTypeNames = excludedGenericTypeNames
      self.specializationContext = specializationContext
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
                     genericTypeContext: [[String]]? = nil,
                     excludedGenericTypeNames: Set<String>? = nil,
                     specializationContext: SpecializationContext? = nil) {
      self.init(moduleNames: moduleNames ?? context.moduleNames,
                referencingModuleName: referencingModuleName ?? context.referencingModuleName,
                containingTypeNames: containingTypeNames ?? context.containingTypeNames,
                containingScopes: containingScopes ?? context.containingScopes,
                rawTypeRepository: rawTypeRepository ?? context.rawTypeRepository,
                typealiasRepository: typealiasRepository ?? context.typealiasRepository,
                genericTypeContext: genericTypeContext ?? context.genericTypeContext,
                excludedGenericTypeNames: excludedGenericTypeNames ?? context.excludedGenericTypeNames,
                specializationContext: specializationContext ?? context.specializationContext)
    }
    
    convenience init() {
      self.init(moduleNames: [],
                referencingModuleName: nil,
                containingTypeNames: [],
                containingScopes: [],
                rawTypeRepository: nil,
                typealiasRepository: nil,
                genericTypeContext: [],
                excludedGenericTypeNames: [],
                specializationContext: nil)
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
  /// - Parameter typeName: A type name which should be stripped of whitespace.
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
    
    // Recursively specialize generic types that exist in the current specialization context.
    if options.contains(.shouldSpecializeTypes), let specialized = specialize(typeName) {
      return specialized
    }
    
    // Don't qualify generic types which could be shadowing types defined at the module level.
    guard !context.genericTypeContext.contains(where: { $0.contains(typeName) }) else {
      return serializeGenericTypes(typeName)
    }
    
    // Resolve the type name to a raw type instance.
    guard let baseRawType = rawTypeRepository
      .nearestInheritedType(named: typeName,
                            trimmedName: typeName.removingGenericTyping(),
                            moduleNames: context.moduleNames,
                            referencingModuleName: context.referencingModuleName,
                            containingTypeNames: context.containingTypeNames)?
      .findBaseRawType() else { return serializeGenericTypes(typeName) }
    
    // Get the actual module name of the definition since the base raw type could be a (nested)
    // enum or class defined within an extension.
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
            logWarning(
              "Cannot resolve module name for containing type \(extensionTypeName.singleQuoted) which is not defined in the project or in a supporting source file",
              diagnostic: .undefinedType,
              filePath: baseRawType.parsedFile.path,
              line: SourceSubstring.key
                .extractLinesNumbers(from: baseRawType.dictionary,
                                     contents: baseRawType.parsedFile.file.contents)?.start
            )
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
    case .contextQualified:
      return serializeGenericTypes(qualifiedTypeNames.contextQualified)
      
    case .moduleQualified:
      // Nested type aliases referenced from an inherited context should use Self qualification.
      // TODO: Workaround shadowed type aliases: https://bugs.swift.org/browse/TF-1279
      if baseRawType.kind == .typealias && baseRawType.isContainedType &&
        qualifiedTypeNames.contextQualified.count < qualifiedTypeNames.moduleQualified.count {
        return Constants.syntheticSelfToken + "." +
          serializeGenericTypes(qualifiedTypeNames.contextQualified)
      }
      
      // Exclude the module name if it's shadowed by a type in one of the imported modules. This
      // will break if the shadowed module also contains type names that conflict with another
      // module. However, name conflicts are much less likely to occur than module name shadowing.
      if rawTypeRepository.isModuleNameShadowed(moduleName: baseRawType.parsedFile.moduleName) {
        let partiallyQualifiedTypeName = qualifiedTypeNames.moduleQualified
          .substringComponents(separatedBy: ".")[1...]
          .joined(separator: ".")
        return serializeGenericTypes(partiallyQualifiedTypeName)
      } else {
        return serializeGenericTypes(qualifiedTypeNames.moduleQualified)
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
      return serializeGenericTypes(flattenedTypeNames)
      
    case .notQualified: return typeName
    }
  }
  
  private func specialize(_ typeName: String) -> String? {
    guard
      let specialization = context.specializationContext?.specializations[typeName],
      !context.excludedGenericTypeNames.contains(typeName)
      else {
        return nil
    }
    
    // Handle shadowed generic type parameter names by excluding types once specialized, e.g.
    // class One<T>
    // class Two<T>: One<T> { One.T => T }
    // class Three: Two<String> { Two.T => String }
    let attributedContext = SerializationRequest.Context(
      from: context,
      excludedGenericTypeNames: context.excludedGenericTypeNames.union([typeName])
    )
    let attributedRequest = SerializationRequest(method: method,
                                                 context: attributedContext,
                                                 options: options)
    let serialized = specialization.serialize(with: attributedRequest)
    return serializeGenericTypes(serialized, attributedRequest: attributedRequest)
  }
  
  private func serializeGenericTypes(_ typeName: String,
                                     attributedRequest: SerializationRequest? = nil) -> String {
    guard typeName.contains("<") else { return typeName } // Fast path.
    let request = attributedRequest ?? self
    
    let declaredType = DeclaredType(from: typeName)
    switch declaredType {
    case .tuple: break
    case .single(let single, _):
      switch single {
      case .list, .map, .function: break
      case .nominal(let components):
        return components
          .map({ component -> String in
            guard !component.genericTypes.isEmpty else { return component.typeName } // Fast path.
            let serializedGenericTypes = component.genericTypes
              .map({ $0.serialize(with: request) })
            return "\(component.typeName)<\(serializedGenericTypes.joined(separator: ", "))>"
          })
          .joined(separator: ".")
      }
    }
    
    return typeName
  }
}
