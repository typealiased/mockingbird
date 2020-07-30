//
//  Generics.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 8/20/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import AppKit

public protocol AssociatedTypeProtocol {
  associatedtype EquatableType: Equatable
  associatedtype HashableType: Hashable

  func methodUsingEquatableType(equatable: EquatableType)
  func methodUsingHashableType(hashable: HashableType)
  func methodUsingEquatableTypeWithReturn(equatable: EquatableType) -> EquatableType

  static func methodUsingEquatableTypeWithReturn(equatable: EquatableType) -> EquatableType

  var equatableTypeVariable: EquatableType { get }
  static var equatableTypeVariable: EquatableType { get }
}

public class AssociatedTypeGenericImplementer<EquatableType: Equatable, S: Sequence>: AssociatedTypeProtocol
where S.Element == EquatableType {
  public typealias HashableType = String

  public func methodUsingEquatableType(equatable: EquatableType) {}
  public func methodUsingHashableType(hashable: HashableType) {}
  public func methodUsingEquatableTypeWithReturn(equatable: EquatableType) -> EquatableType {
    fatalError()
  }

  public class func methodUsingEquatableTypeWithReturn(equatable: EquatableType) -> EquatableType {
    fatalError()
  }

  public var equatableTypeVariable: EquatableType { fatalError() }
  public class var equatableTypeVariable: EquatableType { fatalError() }
}

public protocol AssociatedTypeImplementerProtocol {
  func request<T: AssociatedTypeProtocol>(object: T)
    where T.EquatableType == Int, T.HashableType == String

  func request<T: AssociatedTypeProtocol>(object: T) -> T.HashableType
    where T.EquatableType == Int, T.HashableType == String

  func request<T: AssociatedTypeProtocol>(object: T) -> T.HashableType
    where T.EquatableType == Bool, T.HashableType == String
}

public class AssociatedTypeImplementer {
  func request<T: AssociatedTypeProtocol>(object: T)
    where T.EquatableType == Int, T.HashableType == String {}

  func request<T: AssociatedTypeProtocol>(object: T) -> T.EquatableType
    where T.EquatableType == Int, T.HashableType == String { fatalError() }

  // Not possible to override overloaded methods where uniqueness is from generic constraints.
  // https://forums.swift.org/t/cannot-override-more-than-one-superclass-declaration/22213
  func request<T: AssociatedTypeProtocol>(object: T) -> T.EquatableType
    where T.EquatableType == Bool, T.HashableType == String { fatalError() }
}

public protocol AssociatedTypeGenericConstraintsProtocol {
  associatedtype ConstrainedType: AssociatedTypeProtocol
    where ConstrainedType.EquatableType == Int, ConstrainedType.HashableType == String

  func request(object: ConstrainedType) -> Bool
}

public protocol AssociatedTypeGenericConformingConstraintsProtocol {
  associatedtype ConformingType: AssociatedTypeProtocol where
    ConformingType.EquatableType: EquatableConformingProtocol,
    ConformingType.HashableType: HashableConformingProtocol

  func request(object: ConformingType) -> Bool
}

public protocol AssociatedTypeSelfReferencingProtocol {
  // Swift 5.1 has regressions on self-referencing where clauses in type declarations.
  // https://bugs.swift.org/browse/SR-11503
  associatedtype SequenceType: Sequence, Hashable// where SequenceType.Element == Self
  
  func request(array: SequenceType)
  func request<T: Sequence>(array: T) where T.Element == Self
  
  func request(object: Self)
}

// MARK: Inheritance

public protocol InheritingAssociatedTypeSelfReferencingProtocol:
AssociatedTypeSelfReferencingProtocol {}
public protocol IndirectlyInheritingAssociatedTypeSelfReferencingProtocol:
InheritingAssociatedTypeSelfReferencingProtocol {}

public protocol SecondLevelSelfConstrainedAssociatedTypeProtocol
where Self: AssociatedTypeSelfReferencingProtocol {}

public protocol TopLevelSelfConstrainedAssociatedTypeProtocol
where Self: SecondLevelSelfConstrainedAssociatedTypeProtocol, Self.Element: Hashable {
  associatedtype Element
}

// NOTE: Constraint syntax is sugar for `where Self: <Type>`, but SourceKit treats them differently.

public protocol ExplicitSelfConstrainedToClassProtocol where Self: NSViewController {}
public protocol InheritingExplicitSelfConstrainedToClassProtocol
where Self: ExplicitSelfConstrainedToClassProtocol {}
public protocol IndirectlyInheritingExplicitSelfConstrainedToClassProtocol
where Self: InheritingExplicitSelfConstrainedToClassProtocol {}

public protocol ConstrainedToClassProtocol: NSViewController {}
public protocol InheritingConstrainedToClassProtocol: ConstrainedToClassProtocol {}
public protocol IndirectlyInheritingConstrainedToClassProtocol:
InheritingConstrainedToClassProtocol {}

public protocol ExplicitSelfConstrainedToProtocolProtocol where Self: Hashable {}
public protocol InheritingExplicitSelfConstrainedToProtocolProtocol
where Self: ExplicitSelfConstrainedToProtocolProtocol {}
public protocol IndirectlyInheritingExplicitSelfConstrainedToProtocolProtocol
where Self: InheritingExplicitSelfConstrainedToProtocolProtocol {}

public protocol ConstrainedToProtocolProtocol: Hashable {}
public protocol InheritingConstrainedToProtocolProtocol: ConstrainedToProtocolProtocol {}
public protocol IndirectlyInheritingConstrainedToProtocolProtocol:
InheritingConstrainedToProtocolProtocol {}

public protocol AutomaticallyConformedExplicitSelfConstrainedProtocol
where Self: Foundation.NSObjectProtocol {}
public protocol InheritingAutomaticallyConformedExplicitSelfConstrainedProtocol
where Self: AutomaticallyConformedExplicitSelfConstrainedProtocol {}
public protocol IndirectlyInheritingAutomaticallyConformedExplicitSelfConstrainedProtocol
where Self: InheritingAutomaticallyConformedExplicitSelfConstrainedProtocol {}

public protocol AutomaticallyConformedConstrainedProtocol: Foundation.NSObjectProtocol {}
public protocol InheritingAutomaticallyConformedConstrainedProtocol:
AutomaticallyConformedConstrainedProtocol {}
public protocol IndirectlyInheritingAutomaticallyConformedConstrainedProtocol:
InheritingAutomaticallyConformedConstrainedProtocol {}

public class ReferencedGenericClass<T> {}
public class ReferencedGenericClassWithConstraints<S: Sequence> where S.Element: Hashable {}

public protocol GenericClassReferencer {
  var genericClassVariable: ReferencedGenericClass<String> { get set }
  var genericClassWithConstraintsVariable: ReferencedGenericClassWithConstraints<[String]> { get set }
  
  func genericClassMethod<Z>() -> ReferencedGenericClass<Z>
  func genericClassWithConstraintsMethod<Z>() -> ReferencedGenericClassWithConstraints<Z>
  
  func genericClassMethod<T, Z: ReferencedGenericClass<T>>(metatype: Z.Type) -> Z.Type
  func genericClassWithConstraintsMethod<T, Z: ReferencedGenericClassWithConstraints<T>>(metatype: Z.Type)
    -> Z.Type
}

public class UnalphabetizedGenericClass<C, B, A> {
  func genericReferencingMethod(a: A, b: B, c: C) -> (A, B, C) { fatalError() }
  func genericMethod<Z, Y, X>(x: X, y: Y, z: Z) -> (X, Y, Z) { fatalError() }
}

public class GenericBaseClass<T> {
  typealias Nominal = String
  typealias NominalSpecialized = Array<T>
  typealias MyArray<T> = Array<T>
  typealias MyDictionary<K: Hashable, V> = Dictionary<K, V>
  
  // MARK: Properties
  
  var baseProperty: T { fatalError() }
  
  var basePropertyArray: Array<T> { fatalError() }
  var basePropertyArrayShorthand: [T] { fatalError() }
  
  var basePropertyDictionary: Dictionary<String, T> { fatalError() }
  var basePropertyDictionaryShorthand: [String: T] { fatalError() }
  
  var basePropertyTuple: (T, named: T, nested: (T, named: T)) { fatalError() }
  var basePropertyClosure: (T) -> T { fatalError() }
  
  var basePropertyNominalTypealias: Nominal { fatalError() }
  var basePropertyNominalSpecializedTypealias: NominalSpecialized { fatalError() }
  var basePropertyArrayTypealias: MyArray<T> { fatalError() }
  var basePropertyDictionaryTypealias: MyDictionary<String, T> { fatalError() }
  
  // MARK: Methods
  
  func baseMethod(param: T) -> T { fatalError() }
  
  func baseMethod(array: Array<T>) -> Array<T> { fatalError() }
  func baseMethod(arrayShorthand: [T]) -> [T] { fatalError() }
  
  func baseMethod(dictionary: Dictionary<String, T>) -> Dictionary<String, T> { fatalError() }
  func baseMethod(dictionaryShorthand: [String: T]) -> [String: T] { fatalError() }
  
  func baseMethod(tuple: (T, named: T, nested: (T, named: T)))
    -> (T, named: T, nested: (T, named: T)) { fatalError() }
  func baseMethod(closure: (T) -> T) -> (T) -> T { fatalError() }
  
  func baseMethod(nominalTypealias: Nominal) -> Nominal { fatalError() }
  func baseMethod(nominalSpecializedTypealias: NominalSpecialized)
    -> NominalSpecialized { fatalError() }
  func baseMethod(arrayTypealias: MyArray<T>) -> MyArray<T> { fatalError() }
  func baseMethod(dictionaryTypealias: MyDictionary<String, T>)
    -> MyDictionary<String, T> { fatalError() }
}

// MARK: Shadowing

public struct ShadowedType {}

public class ShadowedGenericType<ShadowedType> {
  func shadowedClassScope(param: ShadowedType) -> ShadowedType { fatalError() }
  func shadowedFunctionScope<ShadowedType>(param: ShadowedType) -> ShadowedType { fatalError() }
  func shadowedFunctionScope<ShadowedType>(param: Array<ShadowedType>)
    -> Array<ShadowedType> { fatalError() }
  
  public class NestedShadowedGenericType {
    func shadowedClassScope(param: ShadowedType) -> ShadowedType { fatalError() }
    func shadowedFunctionScope<ShadowedType>(param: ShadowedType) -> ShadowedType { fatalError() }
    func shadowedFunctionScope<ShadowedType>(param: Array<ShadowedType>)
      -> Array<ShadowedType> { fatalError() }
  }
  
  public class NestedDoublyShadowedGenericType<ShadowedType> {
    func shadowedClassScope(param: ShadowedType) -> ShadowedType { fatalError() }
    func shadowedFunctionScope<ShadowedType>(param: ShadowedType) -> ShadowedType { fatalError() }
    func shadowedFunctionScope<ShadowedType>(param: Array<ShadowedType>)
      -> Array<ShadowedType> { fatalError() }
  }
}

// MARK: Specialization

class SpecializedGenericSubclass: GenericBaseClass<Bool> {}
class InheritingSpecializedGenericSubclass: SpecializedGenericSubclass {}
class IndirectlyInheritingSpecializedGenericSubclass: InheritingSpecializedGenericSubclass {}

protocol SpecializedGenericProtocol: GenericBaseClass<Bool> {}
protocol InheritingSpecializedGenericProtocol: SpecializedGenericProtocol {}
protocol IndirectlyInheritingSpecializedGenericProtocol: InheritingSpecializedGenericProtocol {}

protocol SpecializedExplicitSelfConstrainedGenericProtocol
where Self: GenericBaseClass<Bool> {}
protocol InheritingSpecializedExplicitSelfConstrainedGenericProtocol
where Self: SpecializedExplicitSelfConstrainedGenericProtocol {}
protocol IndirectlyInheritingSpecializedExplicitSelfConstrainedGenericProtocol
where Self: InheritingSpecializedExplicitSelfConstrainedGenericProtocol {}

protocol AbstractSpecializedGenericProtocol: GenericBaseClass<Bool> {
  associatedtype EquatableType: Equatable
}
protocol InheritingAbstractSpecializedGenericProtocol: AbstractSpecializedGenericProtocol {}
protocol IndirectlyInheritingAbstractSpecializedGenericProtocol:
InheritingAbstractSpecializedGenericProtocol {}

class SpecializedShadowedGenericSubclass: ShadowedGenericType<NSObject> {}
protocol SpecializedShadowedGenericProtocol: ShadowedGenericType<NSObject> {}

class UnspecializedGenericSubclass<T>: GenericBaseClass<T> {}
class InheritingUnspecializedGenericSubclass<T>: UnspecializedGenericSubclass<T> {}

class ConstrainedUnspecializedGenericSubclass<T: Equatable>: GenericBaseClass<T> {}
class InheritingConstrainedUnspecializedGenericSubclass<T: Equatable>:
ConstrainedUnspecializedGenericSubclass<T> {}

class UnspecializedMultipleGenericSubclass<T, R>: GenericBaseClass<T> {}
class InheritingUnspecializedMultipleGenericSubclass<T, R>:
UnspecializedMultipleGenericSubclass<T, R> {}

struct GenericTypeOne<NotUsed> {}
struct GenericTypeTwo<NotUsed> {}
class UnspecializedCompoundGenericSubclass<T>: GenericBaseClass<GenericTypeOne<T>> {}
class TriviallyInheritingUnspecializedCompoundGenericSubclass<T>:
UnspecializedCompoundGenericSubclass<T> {}
class CompoundInheritingUnspecializedNestedGenericSubclass<T>:
UnspecializedCompoundGenericSubclass<GenericTypeTwo<T>> {}
