//
//  Specializable.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 3/26/20.
//

import Foundation

/// Stores type specializations, e.g. `Dictionary<String, Int>`, mapping each generic type parameter
/// from the original type declaration, e.g. `Dictionary<K, V>` => `{ K: String, V: Int }`.
struct SpecializationContext {
  init?(typeName: String, baseRawType: RawType) {
    let declaredType = DeclaredType(from: typeName)
    var parsedGenericTypes: [DeclaredType]? {
      switch declaredType {
      case .single(let single, _): return single.genericTypes
      case .tuple: return nil
      }
    }
    guard let remappedGenericTypes = parsedGenericTypes else { return nil }
    
    var specializations = [String: DeclaredType]()
    var typeList = [DeclaredType]()
    for (i, genericType) in baseRawType.genericTypes.enumerated() {
      guard let remappedGenericType = remappedGenericTypes.get(i) else { break }
      specializations[genericType] = remappedGenericType
      typeList.append(remappedGenericType)
    }
    
    self.specializations = specializations
    self.typeList = typeList
  }
  
  /// Mapping from generic type name to a serializable `DeclaredType`
  let specializations: [String: DeclaredType]
  
  /// Ordered list of the remapped generic types.
  let typeList: [DeclaredType]
}

protocol Specializable {
  /// Perform class-level specialization on all referenced types.
  /// - Parameter context: Context for specializing generic type names.
  /// - Parameter moduleNames: Module names referenced from this context.
  /// - Parameter genericTypeContext: Additional generic type context from referencing type.
  /// - Parameter excludedGenericTypeNames: Generic type names that should not be specialized.
  /// - Parameter rawTypeRepository: Raw types used for resolving nominal type specializations.
  /// - Parameter typealiasRepository: Type aliases used for resolving nominal type specializations.
  func specialize(using context: SpecializationContext,
                  moduleNames: [String],
                  genericTypeContext: [[String]],
                  excludedGenericTypeNames: Set<String>,
                  rawTypeRepository: RawTypeRepository,
                  typealiasRepository: TypealiasRepository) -> Self
}
