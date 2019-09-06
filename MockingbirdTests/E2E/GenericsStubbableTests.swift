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
  
  func methodUsingEquatableType(equatable: @escaping @autoclosure () -> EquatableType)
    -> Stubbable<(EquatableType) -> Void, Void>
  func methodUsingHashableType(hashable: @escaping @autoclosure () -> HashableType)
    -> Stubbable<(HashableType) -> Void, Void>
  func methodUsingEquatableTypeWithReturn(equatable: @escaping @autoclosure () -> EquatableType)
    -> Stubbable<(EquatableType) -> EquatableType, EquatableType>
  
  func getEquatableTypeVariable()
    -> Stubbable<() -> EquatableType, EquatableType>
  func setEquatableTypeVariable(_ newValue: @escaping @autoclosure () -> EquatableType)
    -> Stubbable<(EquatableType) -> Void, Void>
}
extension AssociatedTypeProtocolMock: StubbableAssociatedTypeProtocol {}

private protocol StubbableAssociatedTypeGenericImplementer: AssociatedTypeProtocol {
  associatedtype S: Sequence where S.Element == EquatableType
  
  func methodUsingEquatableType(equatable: @escaping @autoclosure () -> EquatableType)
    -> Stubbable<(EquatableType) -> Void, Void>
  func methodUsingHashableType(hashable: @escaping @autoclosure () -> HashableType)
    -> Stubbable<(HashableType) -> Void, Void>
  func methodUsingEquatableTypeWithReturn(equatable: @escaping @autoclosure () -> EquatableType)
    -> Stubbable<(EquatableType) -> EquatableType, EquatableType>
  
  func getEquatableTypeVariable()
    -> Stubbable<() -> EquatableType, EquatableType>
  func setEquatableTypeVariable(_ newValue: @escaping @autoclosure () -> EquatableType)
    -> Stubbable<(EquatableType) -> Void, Void>
}
extension AssociatedTypeGenericImplementerMock: StubbableAssociatedTypeGenericImplementer {}

private protocol StubbableAssociatedTypeImplementerProtocol {
  func request<T: AssociatedTypeProtocol>(object: @escaping @autoclosure () -> T)
    -> Stubbable<(T) -> Void, Void>
    where T.EquatableType == Int, T.HashableType == String
  
  func request<T: AssociatedTypeProtocol>(object: @escaping @autoclosure () -> T)
    -> Stubbable<(T) -> T.HashableType, T.HashableType>
    where T.EquatableType == Int, T.HashableType == String
  
  func request<T: AssociatedTypeProtocol>(object: @escaping @autoclosure () -> T)
    -> Stubbable<(T) -> T.HashableType, T.HashableType>
    where T.EquatableType == Bool, T.HashableType == String
}
extension AssociatedTypeImplementerProtocolMock: StubbableAssociatedTypeImplementerProtocol {}

private protocol StubbableAssociatedTypeImplementer {
  func request<T: AssociatedTypeProtocol>(object: @escaping @autoclosure () -> T)
    -> Stubbable<(T) -> Void, Void>
    where T.EquatableType == Int, T.HashableType == String
}
extension AssociatedTypeImplementerMock: StubbableAssociatedTypeImplementer {}

private protocol StubbableAssociatedTypeGenericConstraintsProtocol: AssociatedTypeGenericConstraintsProtocol {
  func request(object: @escaping @autoclosure () -> ConstrainedType)
    -> Stubbable<(ConstrainedType) -> Bool, Bool>
}
extension AssociatedTypeGenericConstraintsProtocolMock: StubbableAssociatedTypeGenericConstraintsProtocol {}

private protocol StubbableAssociatedTypeSelfReferencingProtocol: AssociatedTypeSelfReferencingProtocol {
  func request(array: @escaping @autoclosure () -> SequenceType)
    -> Stubbable<(SequenceType) -> Void, Void>
  func request<T: Sequence>(array: @escaping @autoclosure () -> T)
    -> Stubbable<(T) -> Void, Void> where T.Element == Self
  func request(object: @escaping @autoclosure () -> Self) -> Stubbable<(Self) -> Void, Void>
}
extension AssociatedTypeSelfReferencingProtocolMock: StubbableAssociatedTypeSelfReferencingProtocol {}
