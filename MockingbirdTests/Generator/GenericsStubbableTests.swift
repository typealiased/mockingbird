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
    -> Stubbable<Mock.Protocol, AssociatedTypeProtocolMock<EquatableType, HashableType>, (EquatableType) -> Void, Void>
  func methodUsingHashableType(hashable: @escaping @autoclosure () -> HashableType)
    -> Stubbable<Mock.Protocol, AssociatedTypeProtocolMock<EquatableType, HashableType>, (HashableType) -> Void, Void>
  func methodUsingEquatableTypeWithReturn(equatable: @escaping @autoclosure () -> EquatableType)
    -> Stubbable<Mock.Protocol, AssociatedTypeProtocolMock<EquatableType, HashableType>, (EquatableType) -> EquatableType, EquatableType>
}
extension AssociatedTypeProtocolMock: StubbableAssociatedTypeProtocol {}

private protocol StubbableAssociatedTypeGenericImplementer: AssociatedTypeProtocol {
  associatedtype S: Sequence where S.Element == EquatableType
  
  func methodUsingEquatableType(equatable: @escaping @autoclosure () -> EquatableType)
    -> Stubbable<AssociatedTypeGenericImplementer<EquatableType, S>, AssociatedTypeGenericImplementerMock<EquatableType, S>, (EquatableType) -> Void, Void>
  func methodUsingHashableType(hashable: @escaping @autoclosure () -> HashableType)
    -> Stubbable<AssociatedTypeGenericImplementer<EquatableType, S>, AssociatedTypeGenericImplementerMock<EquatableType, S>, (HashableType) -> Void, Void>
  func methodUsingEquatableTypeWithReturn(equatable: @escaping @autoclosure () -> EquatableType)
    -> Stubbable<AssociatedTypeGenericImplementer<EquatableType, S>, AssociatedTypeGenericImplementerMock<EquatableType, S>, (EquatableType) -> EquatableType, EquatableType>
}
extension AssociatedTypeGenericImplementerMock: StubbableAssociatedTypeGenericImplementer {}

private protocol StubbableAssociatedTypeImplementerProtocol {
  func request<T: AssociatedTypeProtocol>(object: @escaping @autoclosure () -> T)
    -> Stubbable<AssociatedTypeImplementerProtocol, AssociatedTypeImplementerProtocolMock, (T) -> Void, Void>
    where T.EquatableType == Int, T.HashableType == String
  
  func request<T: AssociatedTypeProtocol>(object: @escaping @autoclosure () -> T)
    -> Stubbable<AssociatedTypeImplementerProtocol, AssociatedTypeImplementerProtocolMock, (T) -> T.HashableType, T.HashableType>
    where T.EquatableType == Int, T.HashableType == String
  
  func request<T: AssociatedTypeProtocol>(object: @escaping @autoclosure () -> T)
    -> Stubbable<AssociatedTypeImplementerProtocol, AssociatedTypeImplementerProtocolMock, (T) -> T.HashableType, T.HashableType>
    where T.EquatableType == Bool, T.HashableType == String
}
extension AssociatedTypeImplementerProtocolMock: StubbableAssociatedTypeImplementerProtocol {}

private protocol StubbableAssociatedTypeImplementer {
  func request<T: AssociatedTypeProtocol>(object: @escaping @autoclosure () -> T)
    -> Stubbable<AssociatedTypeImplementer, AssociatedTypeImplementerMock, (T) -> Void, Void>
    where T.EquatableType == Int, T.HashableType == String
}
extension AssociatedTypeImplementerMock: StubbableAssociatedTypeImplementer {}

private protocol StubbableAssociatedTypeGenericConstraintsProtocol: AssociatedTypeGenericConstraintsProtocol {
  func request(object: @escaping @autoclosure () -> ConstrainedType)
    -> Stubbable<Mock.Protocol, AssociatedTypeGenericConstraintsProtocolMock<ConstrainedType>, (ConstrainedType) -> Bool, Bool>
}
extension AssociatedTypeGenericConstraintsProtocolMock: StubbableAssociatedTypeGenericConstraintsProtocol {}

private protocol StubbableAssociatedTypeSelfReferencingProtocol: AssociatedTypeSelfReferencingProtocol {
  func request(array: @escaping @autoclosure () -> SequenceType)
    -> Stubbable<Mock.Protocol, Self, (SequenceType) -> Void, Void>
  func request<T: Sequence>(array: @escaping @autoclosure () -> T)
    -> Stubbable<Mock.Protocol, Self, (T) -> Void, Void> where T.Element == Self
  func request(object: @escaping @autoclosure () -> Self)
    -> Stubbable<Mock.Protocol, Self, (Self) -> Void, Void>
}
extension AssociatedTypeSelfReferencingProtocolMock: StubbableAssociatedTypeSelfReferencingProtocol {}
