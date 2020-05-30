//
//  ChildProtocol.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 8/17/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

protocol ChildProtocol: ParentProtocol {
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
