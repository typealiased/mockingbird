//
//  GenericsStubbableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/21/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import Mockingbird
@testable import MockingbirdTestsHost

// MARK: - Stubbable declarations

private protocol StubbableAssociatedTypeProtocol {
  associatedtype EquatableType: Equatable
  associatedtype HashableType: Hashable
  
  func methodUsingEquatableType(equatable: @autoclosure () -> EquatableType)
    -> Mockable<FunctionDeclaration, (EquatableType) -> Void, Void>
  func methodUsingHashableType(hashable: @autoclosure () -> HashableType)
    -> Mockable<FunctionDeclaration, (HashableType) -> Void, Void>
  func methodUsingEquatableTypeWithReturn(equatable: @autoclosure () -> EquatableType)
    -> Mockable<FunctionDeclaration, (EquatableType) -> EquatableType, EquatableType>
  
  func getEquatableTypeVariable()
    -> Mockable<PropertyGetterDeclaration, () -> EquatableType, EquatableType>
}
extension AssociatedTypeProtocolMock: StubbableAssociatedTypeProtocol {}

private protocol StubbableAssociatedTypeGenericImplementer: MockingbirdTestsHost.AssociatedTypeProtocol {
  associatedtype S: Sequence where S.Element == EquatableType
  
  func methodUsingEquatableType(equatable: @autoclosure () -> EquatableType)
    -> Mockable<FunctionDeclaration, (EquatableType) -> Void, Void>
  func methodUsingHashableType(hashable: @autoclosure () -> HashableType)
    -> Mockable<FunctionDeclaration, (HashableType) -> Void, Void>
  func methodUsingEquatableTypeWithReturn(equatable: @autoclosure () -> EquatableType)
    -> Mockable<FunctionDeclaration, (EquatableType) -> EquatableType, EquatableType>
  
  func getEquatableTypeVariable()
    -> Mockable<PropertyGetterDeclaration, () -> EquatableType, EquatableType>
}
extension AssociatedTypeGenericImplementerMock: StubbableAssociatedTypeGenericImplementer {}

private protocol StubbableAssociatedTypeImplementerProtocol {
  func request<T: MockingbirdTestsHost.AssociatedTypeProtocol>(object: @autoclosure () -> T)
    -> Mockable<FunctionDeclaration, (T) -> Void, Void>
    where T.EquatableType == Int, T.HashableType == String
  
  func request<T: MockingbirdTestsHost.AssociatedTypeProtocol>(object: @autoclosure () -> T)
    -> Mockable<FunctionDeclaration, (T) -> T.HashableType, T.HashableType>
    where T.EquatableType == Int, T.HashableType == String
  
  func request<T: MockingbirdTestsHost.AssociatedTypeProtocol>(object: @autoclosure () -> T)
    -> Mockable<FunctionDeclaration, (T) -> T.HashableType, T.HashableType>
    where T.EquatableType == Bool, T.HashableType == String
}
extension AssociatedTypeImplementerProtocolMock: StubbableAssociatedTypeImplementerProtocol {}

private protocol StubbableAssociatedTypeImplementer {
  func request<T: MockingbirdTestsHost.AssociatedTypeProtocol>(object: @autoclosure () -> T)
    -> Mockable<FunctionDeclaration, (T) -> Void, Void>
    where T.EquatableType == Int, T.HashableType == String
}
extension AssociatedTypeImplementerMock: StubbableAssociatedTypeImplementer {}

private protocol StubbableAssociatedTypeGenericConstraintsProtocol: MockingbirdTestsHost.AssociatedTypeGenericConstraintsProtocol {
  func request(object: @autoclosure () -> ConstrainedType)
    -> Mockable<FunctionDeclaration, (ConstrainedType) -> Bool, Bool>
}
extension AssociatedTypeGenericConstraintsProtocolMock: StubbableAssociatedTypeGenericConstraintsProtocol {}

private protocol StubbableAssociatedTypeGenericConformingConstraintsProtocol: MockingbirdTestsHost.AssociatedTypeGenericConformingConstraintsProtocol {
  func request(object: @autoclosure () -> ConformingType)
    -> Mockable<FunctionDeclaration, (ConformingType) -> Bool, Bool>
}
extension AssociatedTypeGenericConformingConstraintsProtocolMock: StubbableAssociatedTypeGenericConformingConstraintsProtocol {}

private protocol StubbableAssociatedTypeSelfReferencingProtocol: MockingbirdTestsHost.AssociatedTypeSelfReferencingProtocol {
  func request(array: @autoclosure () -> SequenceType)
    -> Mockable<FunctionDeclaration, (SequenceType) -> Void, Void>
  func request<T: Sequence>(array: @autoclosure () -> T)
    -> Mockable<FunctionDeclaration, (T) -> Void, Void> where T.Element == Self
  func request(object: @autoclosure () -> Self) -> Mockable<FunctionDeclaration, (Self) -> Void, Void>
}
extension AssociatedTypeSelfReferencingProtocolMock: StubbableAssociatedTypeSelfReferencingProtocol {}
extension InheritingAssociatedTypeSelfReferencingProtocolMock: StubbableAssociatedTypeSelfReferencingProtocol {}

private protocol StubbableSecondLevelSelfConstrainedAssociatedTypeProtocol:
StubbableAssociatedTypeSelfReferencingProtocol {}
extension SecondLevelSelfConstrainedAssociatedTypeProtocolMock:
StubbableSecondLevelSelfConstrainedAssociatedTypeProtocol {}

private protocol StubbableTopLevelSelfConstrainedAssociatedTypeProtocol:
StubbableSecondLevelSelfConstrainedAssociatedTypeProtocol {}
extension TopLevelSelfConstrainedAssociatedTypeProtocolMock:
StubbableTopLevelSelfConstrainedAssociatedTypeProtocol {}

private protocol StubbableGenericClassReferencer {
  func getGenericClassVariable()
    -> Mockable<PropertyGetterDeclaration, () -> ReferencedGenericClass<String>, ReferencedGenericClass<String>>
  func setGenericClassVariable(_ newValue: @autoclosure () -> ReferencedGenericClass<String>)
    -> Mockable<PropertySetterDeclaration, (ReferencedGenericClass<String>) -> Void, Void>
  
  func getGenericClassWithConstraintsVariable()
    -> Mockable<PropertyGetterDeclaration, () -> ReferencedGenericClassWithConstraints<[String]>, ReferencedGenericClassWithConstraints<[String]>>
  func setGenericClassWithConstraintsVariable(_ newValue: @autoclosure () -> ReferencedGenericClassWithConstraints<[String]>)
    -> Mockable<PropertySetterDeclaration, (ReferencedGenericClassWithConstraints<[String]>) -> Void, Void>

  func genericClassMethod<Z>()
    -> Mockable<FunctionDeclaration, () -> ReferencedGenericClass<Z>, ReferencedGenericClass<Z>>
  func genericClassWithConstraintsMethod<Z>()
    -> Mockable<FunctionDeclaration, () -> ReferencedGenericClassWithConstraints<Z>, ReferencedGenericClassWithConstraints<Z>>
  
  func genericClassMethod<T, Z: ReferencedGenericClass<T>>(metatype: @autoclosure () -> Z.Type)
    -> Mockable<FunctionDeclaration, (Z.Type) -> Z.Type, Z.Type>
  func genericClassWithConstraintsMethod<T, Z: ReferencedGenericClassWithConstraints<T>>(metatype: @autoclosure () -> Z.Type)
    -> Mockable<FunctionDeclaration, (Z.Type) -> Z.Type, Z.Type>
}
extension GenericClassReferencerMock: StubbableGenericClassReferencer {}
