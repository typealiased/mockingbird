//
//  FlattenInheritanceOperation.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 9/15/19.
//

import Foundation
import SourceKittenFramework

/// Given a set of `RawType` partials for a single type, creates a `MockableType` object by going to
/// the top of the type inheritance tree and walking downwards. Each step flattens the tree and
/// memoizes a `MockableType` object. Once the process reaches the bottom original type, all
/// inherited dependency types exist and can be merged. See the `MockableType` initializer for the
/// merging strategy.
class FlattenInheritanceOperation: BasicOperation {
  let rawType: [RawType]
  let moduleDependencies: [String: Set<String>]
  let rawTypeRepository: RawTypeRepository
  let typealiasRepository: TypealiasRepository
  let useRelaxedLinking: Bool
  
  class Result {
    fileprivate(set) var mockableType: MockableType?
  }
  
  let result = Result()
  
  override var description: String { "Flatten Inheritance" }
  
  init(rawType: [RawType],
       moduleDependencies: [String: Set<String>],
       rawTypeRepository: RawTypeRepository,
       typealiasRepository: TypealiasRepository,
       useRelaxedLinking: Bool) {
    precondition(!rawType.isEmpty)
    self.rawType = rawType
    self.moduleDependencies = moduleDependencies
    self.rawTypeRepository = rawTypeRepository
    self.typealiasRepository = typealiasRepository
    self.useRelaxedLinking = useRelaxedLinking
  }
  
  override func run() throws {
    result.mockableType = flattenInheritance(for: rawType)
  }
  
  private enum ReferencedType {
    case inheritance(typeName: String)
    case conformance(typeName: String)
    case typeAliased(typeName: String)
    
    var typeName: String {
      switch self {
      case .inheritance(let typeName),
           .conformance(let typeName),
           .typeAliased(let typeName): return typeName
      }
    }
    
    var useAutomaticInheritance: Bool {
      switch self {
      case .inheritance, .conformance: return true
      case .typeAliased: return false
      }
    }
  }
  
  /// Recursively traverse the inheritance graph from bottom up (children to parents). Note that
  /// `rawType` is actually an unmerged set of all `RawType` declarations found eg in extensions.
  private static var memoizedMockbleTypes = Synchronized<[String: MockableType]>([:])

  private func flattenInheritance(for rawType: [RawType]) -> MockableType? {
    // All module names that were explicitly referenced from an import declaration.
    let importedModuleNames = Set(rawType.flatMap({
      $0.parsedFile.importedModuleNames.flatMap({ moduleDependencies[$0] ?? [$0] })
        + [$0.parsedFile.moduleName]
    }))
    // Module names are put into an array and sorted so that looking up types is deterministic.
    let moduleNames: [String]
    if useRelaxedLinking {
      // Relaxed linking aims to fix mixed source (ObjC + Swift) targets that implicitly import
      // modules using the bridging header. The type system checks explicitly imported modules
      // first, then falls back to any modules listed as a direct dependency for each raw type
      // partial.
      let implicitModuleNames = Set(rawType.flatMap({
        Array(moduleDependencies[$0.parsedFile.moduleName] ?? [])
      }))
      moduleNames = Array(importedModuleNames).sorted()
        + Array(implicitModuleNames.subtracting(importedModuleNames)).sorted()
    } else {
      moduleNames = Array(importedModuleNames).sorted()
    }

    // Create a copy of `memoizedMockableTypes` to reduce lock contention.
    let memoizedMockableTypes = FlattenInheritanceOperation.memoizedMockbleTypes
      .read({ $0.mapValues({ $0 }) })
    guard let baseRawType = rawType.findBaseRawType() else { return nil }
    
    let fullyQualifiedName = baseRawType.fullyQualifiedModuleName
    if let memoized = memoizedMockableTypes[fullyQualifiedName] { return memoized }
    
    let referencedTypes: [ReferencedType] = rawType
      .compactMap({ $0.dictionary[SwiftDocKey.inheritedtypes.rawValue] as? [StructureDictionary] })
      .flatMap({ $0 })
      .compactMap({ $0[SwiftDocKey.name.rawValue] as? String })
      .map({ ReferencedType.inheritance(typeName: $0) })
      + baseRawType.selfConformanceTypeNames.map({ ReferencedType.conformance(typeName: $0) })
      + baseRawType.aliasedTypeNames.map({ ReferencedType.typeAliased(typeName: $0) })
    
    // Check the base case where the type doesn't inherit from anything.
    guard !referencedTypes.isEmpty else {
      return createMockableType(for: rawType,
                                moduleNames: moduleNames,
                                specializationContexts: [:],
                                opaqueInheritedTypeNames: [])
    }
    
    var opaqueInheritedTypeNames = Set<String>()
    let (rawInheritedTypes, specializationContexts) = referencedTypes
      .reduce(into: ([[RawType]](), [String: SpecializationContext]()), { (result, type) in
        let typeName = type.typeName
        
        // Check if this is a closure instead of a raw type.
        guard !typeName.contains("->", excluding: .allGroups) else { return }
        
        let resolveRawType: (Bool) -> [RawType]? = { useAutomaticInheritance in
          guard let nearestRawType = self.rawTypeRepository
            .nearestInheritedType(named: typeName,
                                  moduleNames: moduleNames,
                                  referencingModuleName: baseRawType.parsedFile.moduleName,
                                  containingTypeNames: baseRawType.containingTypeNames[...])
            else {
              logWarning(
                "\(typeName.singleQuoted) is not defined in the project or in a supporting source file",
                diagnostic: .undefinedType,
                filePath: baseRawType.parsedFile.path,
                line: SourceSubstring.key
                  .extractLinesNumbers(from: baseRawType.dictionary,
                                       contents: baseRawType.parsedFile.file.contents)?.start
              )
              opaqueInheritedTypeNames.insert(typeName)
              return nil
          }
          
          // MockableType maps unmockable inherited raw types to mockable raw types during creation.
          if useAutomaticInheritance,
            let rawType = nearestRawType.findBaseRawType(),
            let mappedType = MockableType.Constants.automaticInheritanceMap[
              rawType.fullyQualifiedModuleName
            ],
            let mappedRawType = self.rawTypeRepository.rawType(named: mappedType.typeName,
                                                               in: mappedType.moduleName) {
            return mappedRawType
          }
          
          return nearestRawType
        }
        
        // Get stored raw type and specialization contexts.
        let useAutomaticInheritance = type.useAutomaticInheritance && baseRawType.kind == .protocol
        guard let rawType = resolveRawType(useAutomaticInheritance) else { return }
        
        result.0.append(rawType)
        
        // Handle specialization of inherited type.
        guard let baseInheritedRawType = rawType.findBaseRawType(),
          !baseInheritedRawType.genericTypes.isEmpty else { return }
        
        result.1[baseInheritedRawType.fullyQualifiedModuleName] =
          SpecializationContext(typeName: typeName, baseRawType: baseInheritedRawType)
      })
    
    // If there are inherited types that aren't processed, flatten them first.
    rawInheritedTypes
      .filter({
        guard let baseRawInheritedType = $0.findBaseRawType() ?? $0.first else { return false }
        return memoizedMockableTypes[baseRawInheritedType.fullyQualifiedModuleName] == nil
      })
      .forEach({
        guard let rawInheritedType = $0.first else { return }
        log("Flattening inherited type \(rawInheritedType.name.singleQuoted) for \(baseRawType.name.singleQuoted)")
        _ = flattenInheritance(for: $0)
      })
    
    return createMockableType(for: rawType,
                              moduleNames: moduleNames,
                              specializationContexts: specializationContexts,
                              opaqueInheritedTypeNames: opaqueInheritedTypeNames)
  }
  
  private func createMockableType(
    for rawType: [RawType],
    moduleNames: [String],
    specializationContexts: [String: SpecializationContext],
    opaqueInheritedTypeNames: Set<String>
  ) -> MockableType? {
    guard let baseRawType = rawType.findBaseRawType() else { return nil }
    let fullyQualifiedName = baseRawType.fullyQualifiedModuleName
    
    // Flattening inherited types could have updated `memoizedMockableTypes`.
    var memoizedMockableTypes = FlattenInheritanceOperation.memoizedMockbleTypes.value
    let mockableType = MockableType(from: rawType,
                                    mockableTypes: memoizedMockableTypes,
                                    moduleNames: moduleNames,
                                    specializationContexts: specializationContexts,
                                    opaqueInheritedTypeNames: opaqueInheritedTypeNames,
                                    rawTypeRepository: self.rawTypeRepository,
                                    typealiasRepository: self.typealiasRepository)
    // Contained types can inherit from their containing types, so store store this potentially
    // preliminary result first.
    FlattenInheritanceOperation.memoizedMockbleTypes.update {
      $0[fullyQualifiedName] = mockableType
    }
    
    if let mockableType = mockableType {
      log("Created mockable type \(mockableType.name.singleQuoted)")
    } else {
      log("Raw type \(baseRawType.name.singleQuoted) is not mockable")
    }
    
    let containedTypes = rawType.flatMap({ $0.containedTypes })
    guard !containedTypes.isEmpty else { return mockableType } // No contained types, early out.
    
    // For each contained type, flatten it before adding it to `mockableType`.
    memoizedMockableTypes[fullyQualifiedName] = mockableType
    mockableType?.containedTypes = containedTypes.compactMap({
      self.flattenInheritance(for: [$0])
    })
    FlattenInheritanceOperation.memoizedMockbleTypes.update {
      $0[fullyQualifiedName] = mockableType
    }
    retainForever(mockableType)
    return mockableType
  }
}
