import Foundation

struct Person {
  func release(_ bird: Bird) {
    guard bird.canFly else { return }
    bird.fly()
  }
  
  func feed(bird: Bird, fruit: Fruit) {
    guard bird.canEat(fruit) else { return }
    bird.eat(fruit)
  }
}
