import Foundation

extension Array {
  func get(_ index: Int, `default`: Element? = nil) -> Element? {
    guard index >= 0 && index < self.count else { return nil }
    return self[index]
  }
  
  func get(_ index: UInt, `default`: Element? = nil) -> Element? {
    return self.get(Int(index), default: `default`)
  }
}
