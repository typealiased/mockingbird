//
//  TreeTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 9/5/19.
//

import XCTest
import Mockingbird // The Mockingbird testing DSL
@testable import MockingbirdTestsHost // The module being tested

class TreeTests: XCTestCase {
  
  var bird: BirdMock! // Concrete mocked type is `BirdMock`
  var tree: Tree! // System under test
  
  override func setUp() {
    bird = mock(Bird.self)
    tree = Tree(with: bird)
  }
  
  // MARK: - Test shaking
  
  // MARK: Bird can fly
  
  func testShakingTree_birdCanFly_birdFlies() {
    given(self.bird.getCanFly()) ~> true // Given the bird can fly
    tree.shake() // When the tree is shaken
    verify(self.bird.fly()).wasCalled() // Then the bird flies away
  }
  
  func testShakingTree_birdCanFly_birdChirps() {
    given(self.bird.getCanFly()) ~> true // Given the bird can fly
    tree.shake() // When the tree is shaken
    verify(self.bird.chirp(volume: any())).wasCalled() // Then the bird chirps at any volume
  }
  
  // MARK: Bird cannot fly
  
  func testShakingTree_givenBirdCannotFly_birdDoesNotFly() {
    given(self.bird.getCanFly()) ~> false // Given the bird _cannot_ fly
    tree.shake() // When the tree is shaken
    verify(self.bird.fly()).wasNeverCalled() // Then the bird does not fly away
  }
  
  // MARK: - Test dropping fruit
  
  func testDroppingFruit_fruitIsSmall_birdEatsFruit() {
    given(self.bird.canEat(any(Tree.Fruit.self))) ~> {
      $0.size < 10 // Given this bird can only eat fruits that are smaller than 10 units
    }
    let fruit = Tree.Fruit(size: 1)
    tree.drop(fruit) // When the tree drops a (very) small fruit
    verify(self.bird.eat(fruit)).wasCalled() // Then the bird eats it
  }
  
  func testDroppingFruit_fruitIsLarge_birdEatsFruit() {
    given(self.bird.canEat(any(Tree.Fruit.self))) ~> {
      $0.size < 10 // Given this bird can only eat fruits that are smaller than 10 units
    }
    tree.drop(Tree.Fruit(size: 99)) // When the tree drops a huge fruit
    verify(self.bird.eat(any(Tree.Fruit.self))).wasNeverCalled() // Then the bird never eats
  }
}
