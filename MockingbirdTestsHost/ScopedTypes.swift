//
//  ScopedTypes.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 8/27/19.
//

import Foundation

class TopLevelType {
  class SecondLevelType {
    class ThirdLevelType {
      func thirdLevelMethod() -> Bool { return true }
    }
    func secondLevelMethod(param: ThirdLevelType) -> Bool { return true }
  }
  func topLevelMethod(param1: SecondLevelType, param2: SecondLevelType.ThirdLevelType) -> Bool {
    return true
  }
}
