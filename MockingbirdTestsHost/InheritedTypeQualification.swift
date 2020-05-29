//
//  InheritedTypeQualification.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 8/31/19.
//

import Foundation

struct UnscopedType {}

protocol InheritedTypeQualificationProtocol {
  associatedtype ScopedType
  func moreQualifiedImplementation(param: ScopedType) -> ScopedType?
  func lessQualifiedImplementation(param: MockingbirdTestsHost.UnscopedType)
    -> MockingbirdTestsHost.UnscopedType?
}

class InheritedTypeQualificationProtocolImplementer: InheritedTypeQualificationProtocol {
  typealias ScopedType = String
  
  // When the implementation method declaration uses a more qualified type than the inherited.
  func moreQualifiedImplementation(param: InheritedTypeQualificationProtocolImplementer.ScopedType)
    -> InheritedTypeQualificationProtocolImplementer.ScopedType? { return nil }
  
  // When the implementation method declaration uses a less qualified type than the inherited.
  func lessQualifiedImplementation(param: UnscopedType) -> UnscopedType? { return nil }
}

class InheritedTypeQualificationProtocolGenericImplementer<T>: InheritedTypeQualificationProtocol {
  typealias ScopedType = T
  
  // When the implementation method declaration uses a more qualified type than the inherited.
  func moreQualifiedImplementation(param: InheritedTypeQualificationProtocolGenericImplementer<T>.ScopedType)
    -> InheritedTypeQualificationProtocolGenericImplementer<T>.ScopedType? { return nil }
  
  // When the implementation method declaration uses a less qualified type than the inherited.
  func lessQualifiedImplementation(param: UnscopedType) -> UnscopedType? { return nil }
}
