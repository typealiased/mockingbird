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
  
  class Result {
    fileprivate(set) var mockableType: MockableType?
  }
  
  let result = Result()
  
  init(rawType: [RawType],
       moduleDependencies: [String: Set<String>],
       rawTypeRepository: RawTypeRepository,
       typealiasRepository: TypealiasRepository) {
    precondition(!rawType.isEmpty)
    self.rawType = rawType
    self.moduleDependencies = moduleDependencies
    self.rawTypeRepository = rawTypeRepository
    self.typealiasRepository = typealiasRepository
  }
  
  override func run() throws {
    // Module names are put into an array and sorted so that looking up types is deterministic.
    let moduleNames = Array(Set(rawType.flatMap({
      $0.parsedFile.importedModuleNames.flatMap({ moduleDependencies[$0] ?? [$0] })
        + [$0.parsedFile.moduleName]
    }))).sorted()
    result.mockableType = flattenInheritance(for: rawType, moduleNames: moduleNames)
  }
  
  /// Recursively traverse the inheritance graph from bottom up (children to parents). Note that
  /// `rawType` is actually an unmerged set of all `RawType` declarations found eg in extensions.
  private static var memoizedMockbleTypes = Synchronized<[String: MockableType]>([:])
  private func flattenInheritance(for rawType: [RawType], moduleNames: [String]) -> MockableType? {
    // Create a copy of `memoizedMockableTypes` to reduce lock contention.
    let memoizedMockableTypes = FlattenInheritanceOperation.memoizedMockbleTypes.value
    guard let baseRawType = rawType.findBaseRawType() else { return nil }
    
    let fullyQualifiedName = baseRawType.fullyQualifiedModuleName
    if let memoized = memoizedMockableTypes[fullyQualifiedName] { return memoized }
    
    let rawTypeRepository = self.rawTypeRepository
    let typealiasRepository = self.typealiasRepository
    let createMockableType: (Bool) -> MockableType? = { hasOpaqueInheritedType in
      // Flattening inherited types could have updated `memoizedMockableTypes`.
      var memoizedMockableTypes = FlattenInheritanceOperation.memoizedMockbleTypes.value
      let mockableType = MockableType(from: rawType,
                                      mockableTypes: memoizedMockableTypes,
                                      hasOpaqueInheritedType: hasOpaqueInheritedType,
                                      moduleNames: moduleNames,
                                      rawTypeRepository: rawTypeRepository,
                                      typealiasRepository: typealiasRepository)
      // Contained types can inherit from their containing types, so store store this potentially
      // preliminary result first.
      FlattenInheritanceOperation.memoizedMockbleTypes.update {
        $0[fullyQualifiedName] = mockableType
      }
      
      if let mockableType = mockableType {
        log("Created mockable type `\(mockableType.name)`")
      } else {
        log("Raw type `\(baseRawType.name)` is not mockable")
      }
      
      let containedTypes = rawType.flatMap({ $0.containedTypes })
      guard !containedTypes.isEmpty else { return mockableType } // No contained types, early out.
      
      // For each contained type, flatten it before adding it to `mockableType`.
      memoizedMockableTypes[fullyQualifiedName] = mockableType
      mockableType?.containedTypes = containedTypes.compactMap({
        self.flattenInheritance(for: [$0], moduleNames: moduleNames)
      })
      FlattenInheritanceOperation.memoizedMockbleTypes.update {
        $0[fullyQualifiedName] = mockableType
      }
      return mockableType
    }
    
    let inheritedTypeNames = rawType
      .compactMap({ $0.dictionary[SwiftDocKey.inheritedtypes.rawValue] as? [StructureDictionary] })
      .flatMap({ $0 })
      .compactMap({ $0[SwiftDocKey.name.rawValue] as? String })
      + baseRawType.selfConformanceTypes
    
    // Check the base case where the type doesn't inherit from anything.
    guard !inheritedTypeNames.isEmpty else { return createMockableType(false) }
    
    var hasOpaqueInheritedType = false
    let rawInheritedTypes = inheritedTypeNames
      .compactMap({ typeName -> [RawType]? in // Get stored raw type.
        let nearest = rawTypeRepository
          .nearestInheritedType(named: typeName,
                                moduleNames: moduleNames,
                                referencingModuleName: baseRawType.parsedFile.moduleName,
                                containingTypeNames: baseRawType.containingTypeNames[...])
        if nearest == nil {
          logWarning("Missing source for referenced type `\(typeName)` in \(baseRawType.parsedFile.path.absolute())")
          hasOpaqueInheritedType = true
        }
        return nearest
      })
      .flatMap({ $0 })
    
    // If there are inherited types that aren't processed, flatten them first.
    if rawInheritedTypes.filter({ memoizedMockableTypes[$0.fullyQualifiedModuleName] == nil }).count > 0 {
      rawInheritedTypes.forEach({
        log("Flattening inherited type `\($0.name)` for `\(baseRawType.name)`")
        _ = flattenInheritance(for: [$0], moduleNames: moduleNames)
      })
    }
    
    return createMockableType(hasOpaqueInheritedType)
  }
}
