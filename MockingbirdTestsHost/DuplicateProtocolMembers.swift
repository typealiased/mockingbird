//
//  DuplicateProtocolMembers.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 5/8/20.
//

import Foundation

// General de-deduplication of inherited methods and properties.
protocol DuplicateInheritedProtocolMembers: ChildProtocol {
  // MARK: Instance
  var childPrivateSetterInstanceVariable: Bool { get }
  var childInstanceVariable: Bool { get set }
  func childTrivialInstanceMethod()
  func childParameterizedInstanceMethod(param1: Bool, _ param2: Int) -> Bool
  
  // MARK: Static
  static var childPrivateSetterStaticVariable: Bool { get }
  static var childStaticVariable: Bool { get set }
  static func childTrivialStaticMethod()
  static func childParameterizedStaticMethod(param1: Bool, _ param2: Int) -> Bool
}


// Method parameter names can differ from inherited (but not the argument label).
protocol FuzzyDuplicateInheritedProtocolMembers: ChildProtocol {
  func childParameterizedInstanceMethod(param1 param1Name: Bool, _ param2Name: Int) -> Bool
  static func childParameterizedStaticMethod(param1 param1Name: Bool, _ param2Name: Int) -> Bool
}


// Same-type generic conformance is commutative and needs to be de-duped.
protocol GenericSameTypeConformance {
  func method<T: Sequence, R: Sequence>(param: T) -> R where T.Element == R.Element
}
protocol DuplicateGenericSameTypeConformance: GenericSameTypeConformance {
  func method<T: Sequence, R: Sequence>(param: T) -> R where R.Element == T.Element
}
