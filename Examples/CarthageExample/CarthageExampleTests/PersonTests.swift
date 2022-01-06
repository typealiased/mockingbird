import XCTest
import Mockingbird
@testable import CarthageExample

class PersonTests: XCTestCase {
  
  var bird: BirdMock!  // Build the test target (⇧⌘U) to generate this mock
  
  override func setUp() {
    bird = mock(Bird.self)
  }
  
  // MARK: - Flying
  
  func testReleaseBird() {
    given(bird.canFly).willReturn(true)  // Given a bird that can fly
    Person().release(bird)               // When a person releases the bird
    verify(bird.fly()).wasCalled()       // Then the bird flies away
  }
  
  func testReleaseNonFlyingBird() {
    given(bird.canFly).willReturn(false)  // Given a bird that _cannot_ fly
    Person().release(bird)                // When a person releases the bird
    verify(bird.fly()).wasNeverCalled()   // Then the bird doesn't fly
  }
  
  // MARK: - Eating
  
  func testFeedBird() {
    given(bird.canEat(any())).willReturn(true)      // Given a bird that eats anything
    Person().feed(bird: bird, fruit: Apple())       // When feeding the bird an apple
    Person().feed(bird: bird, fruit: Watermelon())  //   and a watermelon
    verify(bird.eat(any())).wasCalled(twice)        // Then the bird eats twice
  }
  
  func testFeedPickyBird() {
    given(bird.canEat(any(where: {                  // Given a bird that only eats small fruits
      $0.size < 42
    }))).willReturn(true)
    bird.useDefaultValues(from: .standardProvider)  //   (return `false` by default)
    Person().feed(bird: bird, fruit: Apple())       // When feeding the bird an apple
    Person().feed(bird: bird, fruit: Watermelon())  //   and a watermelon
    verify(bird.eat(any())).wasCalled(once)         // Then the bird only eats once
  }
}
