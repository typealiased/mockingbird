import Foundation

protocol Fruit {
  var size: Int { get }
}

struct Apple: Fruit {
  let size = 5
}

struct Watermelon: Fruit {
  let size = 100
}
