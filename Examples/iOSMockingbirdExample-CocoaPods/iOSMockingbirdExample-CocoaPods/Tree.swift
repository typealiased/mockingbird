//
//  Tree.swift
//  iOSMockingbirdExample
//
//  Created by Andrew Chang on 9/5/19.
//

import Foundation

/// In this universe, trees own birds and can make them fly, chirp, and eat at will.
class Tree {
  let bird: Bird
  
  init(with bird: Bird) {
    self.bird = bird
  }
  
  func shake() {
    guard bird.canFly else { return }
    bird.fly()
    bird.chirp(volume: 42)
  }
}

// MARK: - Fruit

extension Tree {
  struct Fruit: Equatable {
    let size: Int
  }
  
  func drop(_ fruit: Fruit) throws {
    guard bird.canEat(fruit) else { return }
    try bird.eat(fruit)
  }
}
