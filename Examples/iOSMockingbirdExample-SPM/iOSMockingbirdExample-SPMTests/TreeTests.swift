//
//  TreeTests.swift
//  iOSMockingbirdExampleTests
//
//  Created by Andrew Chang on 9/5/19.
//

import XCTest
import Mockingbird // The Mockingbird testing DSL
@testable import iOSMockingbirdExample_SPM // The module being tested

class TreeTests: XCTestCase {
  
  var bird: BirdMock! // Concrete mock type of `Bird` is `BirdMock`
  var tree: Tree! // System under test
  
  override func setUp() {
    bird = mock(Bird.self)
    tree = Tree(with: bird)
  }
  
  // MARK: - Test shaking
  
  // MARK: Bird can fly
  
  func testShakingTree_makesBirdFlyAway() {
    given(bird.getCanFly()).willReturn(true) // Given the bird can fly
    tree.shake() // When the tree is shaken
    verify(bird.fly()).wasCalled() // Then the bird flies away
  }
  
  func testShakingTree_makesBirdChirp() {
    given(bird.getCanFly()).willReturn(true) // Given the bird can fly
    tree.shake() // When the tree is shaken
    verify(bird.chirp(volume: any())).wasCalled() // Then the bird chirps at any volume
  }
  
  // MARK: Bird cannot fly
  
  func testShakingTree_doesNothingWhenBirdCannotFly() {
    given(bird.getCanFly()).willReturn(false) // Given the bird _cannot_ fly
    tree.shake() // When the tree is shaken
    verify(bird.fly()).wasNeverCalled() // Then the bird does not fly away
  }
  
  // MARK: - Test dropping fruit
  
  func testDroppingSmallFruit_causesBirdToEatFruit() {
    given(bird.canEat(any(Tree.Fruit.self))).will {
      return $0.size < 10 // Given this bird can only eat fruits that are smaller than 10 units
    }
    let fruit = Tree.Fruit(size: 1)
    XCTAssertNoThrow(try tree.drop(fruit)) // When the tree drops a very small fruit
    verify(bird.eat(fruit)).wasCalled() // Then the bird eats the fruit
  }
  
  struct FakeBirdError: Error {}
  
  func testDroppingLargeFruit_doesNothing() {
    given(bird.canEat(any(Tree.Fruit.self))).will {
      return $0.size < 10 // Given this bird can only eat fruits that are smaller than 10 units
    }
    given(bird.eat(any(Tree.Fruit.self))).willThrow(FakeBirdError()) // and eating throws an error
    XCTAssertNoThrow(try tree.drop(Tree.Fruit(size: 99))) // When the tree drops a large fruit
    verify(bird.eat(any(Tree.Fruit.self))).wasNeverCalled() // Then the bird never eats
  }
}
