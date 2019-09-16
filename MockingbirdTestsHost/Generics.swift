//
//  Generics.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 8/20/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

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
    return 1 as! EquatableType
  }
  
  public static func methodUsingEquatableTypeWithReturn(equatable: EquatableType) -> EquatableType {
    return 1 as! EquatableType
  }
  
  public var equatableTypeVariable: EquatableType { return 1 as! EquatableType }
  public static var equatableTypeVariable: EquatableType { return 1 as! EquatableType }
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
    where T.EquatableType == Int, T.HashableType == String { return 1 }
  
  // Not possible to override overloaded methods where uniqueness is from generic constraints.
  // https://forums.swift.org/t/cannot-override-more-than-one-superclass-declaration/22213
  func request<T: AssociatedTypeProtocol>(object: T) -> T.EquatableType
    where T.EquatableType == Bool, T.HashableType == String { return true }
}

public protocol AssociatedTypeGenericConstraintsProtocol {
  associatedtype ConstrainedType: AssociatedTypeProtocol
    where ConstrainedType.EquatableType == Int, ConstrainedType.HashableType == String
  
  func request(object: ConstrainedType) -> Bool
}

public protocol AssociatedTypeSelfReferencingProtocol {
  associatedtype SequenceType: Sequence where SequenceType.Element == Self
  
  func request(array: SequenceType)
  func request<T: Sequence>(array: T) where T.Element == Self
  
  func request(object: Self)
}

public protocol InheritingAssociatedTypeSelfReferencingProtocol: AssociatedTypeSelfReferencingProtocol {}
