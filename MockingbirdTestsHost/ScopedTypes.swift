//
//  ScopedTypes.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 8/27/19.
//

import Foundation

class TopLevelType {
  class SecondLevelType {
    class ThirdLevelInheritingTopLevelType: TopLevelType {
      func thirdLevelInheritingMethod() -> Bool { return true }
    }
    class ThirdLevelInheritingThirdLevelType: ThirdLevelType {
      func thirdLevelInheritingMethod() -> Bool { return true }
    }
    class ThirdLevelType {
      func thirdLevelMethod(param1: TopLevelType, param2: SecondLevelType) -> Bool { return true }
    }
    
    func secondLevelMethod(param1: TopLevelType, param2: ThirdLevelType) -> Bool { return true }
  }
  func topLevelMethod(param1: SecondLevelType, param2: SecondLevelType.ThirdLevelType) -> Bool {
    return true
  }
}
