import Foundation

protocol Bird {
  var canFly: Bool { get }
  func fly()
  
  func canEat(_ object: Fruit) -> Bool
  func eat(_ object: Fruit)
}
