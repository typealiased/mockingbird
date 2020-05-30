//
//  ClassScopedTypes.swift
//  MockingbirdModuleTestsHost
//
//  Created by Andrew Chang on 9/15/19.
//

import Foundation

open class TopLevelType {
  open class SecondLevelType {
    open class ThirdLevelInheritingTopLevelType: TopLevelType {
      func thirdLevelInheritingMethod() -> TopLevelType { return TopLevelType() }
    }
    open class ThirdLevelInheritingThirdLevelType: ThirdLevelType {
      func thirdLevelInheritingMethod() -> ThirdLevelType { return ThirdLevelType() }
    }
    open class ThirdLevelInheritingPartiallyQualifiedThirdLevelType: SecondLevelType.ThirdLevelType {
      func thirdLevelInheritingMethod() -> SecondLevelType.ThirdLevelType {
        return ThirdLevelType()
      }
    }
    open class ThirdLevelInheritingFullyQualifiedThirdLevelType: MockingbirdModuleTestsHost.TopLevelType.SecondLevelType.ThirdLevelType {
      func thirdLevelInheritingMethod()
        -> MockingbirdModuleTestsHost.TopLevelType.SecondLevelType.ThirdLevelType {
          return ThirdLevelType()
      }
    }
    open class ThirdLevelType {
      func thirdLevelMethod(param1: TopLevelType, param2: SecondLevelType) -> Bool { return true }
      public init() {}
    }
    
    func secondLevelMethod(param1: TopLevelType, param2: ThirdLevelType) -> Bool { return true }
    public init() {}
  }
  func topLevelMethod(param1: SecondLevelType, param2: SecondLevelType.ThirdLevelType) -> Bool {
    return true
  }
  public init() {}
}

public protocol ExternalModuleScoping {
  var topLevelType: TopLevelType { get }
  var secondLevelType: TopLevelType.SecondLevelType { get }
  var thirdLevelType: TopLevelType.SecondLevelType.ThirdLevelType { get }
}
