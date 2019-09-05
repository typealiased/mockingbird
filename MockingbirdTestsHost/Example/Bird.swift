//
//  Bird.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 9/5/19.
//

import Foundation

public protocol Bird {
  var canFly: Bool { get }
  
  func fly()
  func chirp(volume: Int)

  // MARK: Generics
  func canEat<T>(_ object: T) -> Bool // Whether the `Bird` can successfully eat the object.
  func eat<T>(_ object: T)
}
