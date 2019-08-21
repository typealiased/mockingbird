//
//  GenericsMockableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/20/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import MockingbirdTestsHost

// MARK: Mockable declarations

private protocol MockableAssociatedTypeProtocol {
  associatedtype EquatableType: Equatable
  associatedtype HashableType: Hashable
  
  func methodUsingEquatableType(equatable: EquatableType)
  func methodUsingHashableType(hashable: HashableType)
  func methodUsingEquatableTypeWithReturn(equatable: EquatableType) -> EquatableType
}
extension AssociatedTypeProtocolMock: MockableAssociatedTypeProtocol {}

private protocol MockableAssociatedTypeGenericImplementer: AssociatedTypeProtocol {
  associatedtype S: Sequence
  
  func methodUsingEquatableType(equatable: EquatableType)
  func methodUsingHashableType(hashable: HashableType)
  func methodUsingEquatableTypeWithReturn(equatable: EquatableType) -> EquatableType
}
extension AssociatedTypeGenericImplementerMock: MockableAssociatedTypeGenericImplementer {}

private protocol MockableAssociatedTypeImplementerProtocol {
  func request<T: AssociatedTypeProtocol>(object: T)
    where T.EquatableType == Int, T.HashableType == String
  
  func request<T: AssociatedTypeProtocol>(object: T) -> T.HashableType
    where T.EquatableType == Int, T.HashableType == String
  
  func request<T: AssociatedTypeProtocol>(object: T) -> T.HashableType
    where T.EquatableType == Bool, T.HashableType == String
}
extension AssociatedTypeImplementerProtocolMock: MockableAssociatedTypeImplementerProtocol {}

private protocol MockableAssociatedTypeImplementer {
  func request<T: AssociatedTypeProtocol>(object: T)
    where T.EquatableType == Int, T.HashableType == String
}
extension AssociatedTypeImplementerMock: MockableAssociatedTypeImplementer {}

// MARK: Non-mockable declarations

private extension AssociatedTypeImplementerMock {
  func request<T: AssociatedTypeProtocol>(object: T) -> T.EquatableType
    where T.EquatableType == Int, T.HashableType == String { return 1 }

  func request<T: AssociatedTypeProtocol>(object: T) -> T.EquatableType
    where T.EquatableType == Bool, T.HashableType == String { return true }
}
