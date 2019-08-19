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
}
