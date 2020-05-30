//
//  ClassScopedTypes.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 8/27/19.
//

import Foundation

class TopLevelType {
  class SecondLevelType {
    class ThirdLevelInheritingTopLevelType: TopLevelType {
      func thirdLevelInheritingMethod() -> TopLevelType { return TopLevelType() }
    }
    class ThirdLevelInheritingThirdLevelType: ThirdLevelType {
      func thirdLevelInheritingMethod() -> ThirdLevelType { return ThirdLevelType() }
    }
    class ThirdLevelInheritingPartiallyQualifiedThirdLevelType: SecondLevelType.ThirdLevelType {
      func thirdLevelInheritingMethod() -> SecondLevelType.ThirdLevelType {
        return ThirdLevelType()
      }
    }
    class ThirdLevelInheritingFullyQualifiedThirdLevelType: MockingbirdTestsHost.TopLevelType.SecondLevelType.ThirdLevelType {
      func thirdLevelInheritingMethod()
        -> MockingbirdTestsHost.TopLevelType.SecondLevelType.ThirdLevelType {
          return ThirdLevelType()
      }
    }
    class ThirdLevelType {
      func thirdLevelMethod(param1: TopLevelType, param2: SecondLevelType) -> Bool { return true }
    }
    
    func secondLevelMethod(param1: TopLevelType, param2: ThirdLevelType) -> Bool { return true }
  }
  class InitializableSecondLevelType {
    init(param: Bool) {}
  }
  func topLevelMethod(param1: SecondLevelType, param2: SecondLevelType.ThirdLevelType) -> Bool {
    return true
  }
}

class AnotherTopLevelType {
  class SecondLevelType {}
  class InitializableSecondLevelType {
    init(param: Bool) {}
  }
}
