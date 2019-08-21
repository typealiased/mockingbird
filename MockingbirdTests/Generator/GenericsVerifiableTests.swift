//
//  GenericsVerifiableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/21/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import Mockingbird
import MockingbirdTestsHost

// MARK: - Verifiable declarations

private protocol VerifiableAssociatedTypeProtocol {
  associatedtype EquatableType: Equatable
  associatedtype HashableType: Hashable
  
  func methodUsingEquatableType(equatable: @escaping @autoclosure () -> EquatableType)
    -> Mockable<Void>
  func methodUsingHashableType(hashable: @escaping @autoclosure () -> HashableType)
    -> Mockable<Void>
  func methodUsingEquatableTypeWithReturn(equatable: @escaping @autoclosure () -> EquatableType)
    -> Mockable<EquatableType>
}
extension AssociatedTypeProtocolMock: VerifiableAssociatedTypeProtocol {}

private protocol VerifiableAssociatedTypeGenericImplementer: AssociatedTypeProtocol {
  func methodUsingEquatableType(equatable: @escaping @autoclosure () -> EquatableType)
    -> Mockable<Void>
  func methodUsingHashableType(hashable: @escaping @autoclosure () -> HashableType)
    -> Mockable<Void>
  func methodUsingEquatableTypeWithReturn(equatable: @escaping @autoclosure () -> EquatableType)
    -> Mockable<EquatableType>
}
extension AssociatedTypeGenericImplementerMock: VerifiableAssociatedTypeGenericImplementer {}

private protocol VerifiableAssociatedTypeImplementerProtocol {
  func request<T: AssociatedTypeProtocol>(object: @escaping @autoclosure () -> T)
    -> Mockable<Void>
    where T.EquatableType == Int, T.HashableType == String
  
  func request<T: AssociatedTypeProtocol>(object: @escaping @autoclosure () -> T)
    -> Mockable<T.HashableType>
    where T.EquatableType == Int, T.HashableType == String
  
  func request<T: AssociatedTypeProtocol>(object: @escaping @autoclosure () -> T)
    -> Mockable<T.HashableType>
    where T.EquatableType == Bool, T.HashableType == String
}
extension AssociatedTypeImplementerProtocolMock: VerifiableAssociatedTypeImplementerProtocol {}

private protocol VerifiableAssociatedTypeImplementer {
  func request<T: AssociatedTypeProtocol>(object: @escaping @autoclosure () -> T)
    -> Mockable<Void>
    where T.EquatableType == Int, T.HashableType == String
}
extension AssociatedTypeImplementerMock: VerifiableAssociatedTypeImplementer {}
