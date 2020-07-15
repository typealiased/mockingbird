//
//  Bird.swift
//  iOSMockingbirdExample
//
//  Created by Andrew Chang on 9/5/19.
//

import Foundation

public protocol Bird {
  var canFly: Bool { get }
  
  func fly()
  func chirp(volume: Int)

  // MARK: Generics
  
  func canEat<T: Equatable>(_ object: T) -> Bool
  func eat<T: Equatable>(_ object: T) throws
}
