//
//  Array+Extensions.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/19/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

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

public extension Array where Element: Hashable {
  func uniqued() -> [Element] {
    var seen = Set<Element>()
    return self.filter({ seen.insert($0).inserted })
  }
}

extension Array: Comparable where Element: Comparable {
  public static func < (lhs: Array<Element>, rhs: Array<Element>) -> Bool {
    for (lhsElement, rhsElement) in zip(lhs, rhs) {
      if lhsElement < rhsElement { return true }
      if lhsElement > rhsElement { return false }
    }
    return lhs.count < rhs.count
  }
}
