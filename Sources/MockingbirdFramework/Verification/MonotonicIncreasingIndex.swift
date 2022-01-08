import Foundation

private let index = Synchronized<UInt>(0)

enum MonotonicIncreasingIndex {
  static func peekIndex() -> UInt {
    return index.value
  }
  
  static func getIndex() -> UInt {
    return index.update { index in
      index += 1
      return index
    }
  }
  
  static func incrementIndex() {
    index.value += 1
  }
}
