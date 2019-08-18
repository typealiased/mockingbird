//
//  ParentProtocol.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 8/17/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

protocol ParentProtocol: GrandparentProtocol {
  // MARK: Instance
  var parentPrivateSetterInstanceVariable: Bool { get }
  var parentInstanceVariable: Bool { get set }
  func parentTrivialInstanceMethod()
  func parentParameterizedInstanceMethod(param1: Bool, _ param2: Int) -> Bool
  
  // MARK: Static
  static var parentPrivateSetterStaticVariable: Bool { get }
  static var parentStaticVariable: Bool { get set }
  static func parentTrivialStaticMethod()
  static func parentParameterizedStaticMethod(param1: Bool, _ param2: Int) -> Bool
}
