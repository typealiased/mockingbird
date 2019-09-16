//
//  GenericsMockableTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/20/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation
import Mockingbird
import MockingbirdTestsHost

// MARK: Mockable declarations

private protocol MockableAssociatedTypeProtocol: AssociatedTypeProtocol, Mock {}
extension AssociatedTypeProtocolMock: MockableAssociatedTypeProtocol {}

private protocol MockableAssociatedTypeGenericImplementer: AssociatedTypeProtocol, Mock {
  associatedtype S: Sequence
  
  func methodUsingEquatableType(equatable: EquatableType)
  func methodUsingHashableType(hashable: HashableType)
  func methodUsingEquatableTypeWithReturn(equatable: EquatableType) -> EquatableType
  
  var equatableTypeVariable: EquatableType { get }
}
extension AssociatedTypeGenericImplementerMock: MockableAssociatedTypeGenericImplementer {}

private protocol MockableAssociatedTypeImplementerProtocol: AssociatedTypeImplementerProtocol, Mock {}
extension AssociatedTypeImplementerProtocolMock: MockableAssociatedTypeImplementerProtocol {}

private protocol MockableAssociatedTypeImplementer {
  func request<T: AssociatedTypeProtocol>(object: T)
    where T.EquatableType == Int, T.HashableType == String
}
extension AssociatedTypeImplementerMock: MockableAssociatedTypeImplementer {}

private protocol MockableAssociatedTypeGenericConstraintsProtocol: AssociatedTypeGenericConstraintsProtocol, Mock {}
extension AssociatedTypeGenericConstraintsProtocolMock: MockableAssociatedTypeGenericConstraintsProtocol {}

private protocol MockableAssociatedTypeGenericConformingConstraintsProtocol: AssociatedTypeGenericConformingConstraintsProtocol, Mock {}
extension AssociatedTypeGenericConformingConstraintsProtocolMock: MockableAssociatedTypeGenericConformingConstraintsProtocol {}

private protocol MockableAssociatedTypeSelfReferencingProtocol: AssociatedTypeSelfReferencingProtocol, Mock {}
extension AssociatedTypeSelfReferencingProtocolMock: MockableAssociatedTypeSelfReferencingProtocol {}

private protocol MockableInheritingAssociatedTypeSelfReferencingProtocol: AssociatedTypeSelfReferencingProtocol, Mock {}
extension InheritingAssociatedTypeSelfReferencingProtocolMock: MockableInheritingAssociatedTypeSelfReferencingProtocol {}

// MARK: Non-mockable declarations

private extension AssociatedTypeImplementerMock {
  func request<T: AssociatedTypeProtocol>(object: T) -> T.EquatableType
    where T.EquatableType == Int, T.HashableType == String { return 1 }

  func request<T: AssociatedTypeProtocol>(object: T) -> T.EquatableType
    where T.EquatableType == Bool, T.HashableType == String { return true }
}
