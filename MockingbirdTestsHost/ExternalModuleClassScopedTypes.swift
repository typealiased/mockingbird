//
//  ExternalModuleClassScopedTypes.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 9/15/19.
//

import Foundation
import MockingbirdModuleTestsHost

class SubclassingExternalTopLevelType: MockingbirdModuleTestsHost.TopLevelType {
  // Contextually qualified as `MockingbirdModuleTestsHost.TopLevelType.SecondLevelType`
  var secondLevelType: SecondLevelType
  public override init() {
    self.secondLevelType = MockingbirdModuleTestsHost.TopLevelType.SecondLevelType()
  }
}

class ImplementingExternalModuleScoping: ExternalModuleScoping {
  var topLevelType: MockingbirdModuleTestsHost.TopLevelType
  var secondLevelType: MockingbirdModuleTestsHost.TopLevelType.SecondLevelType
  var thirdLevelType: MockingbirdModuleTestsHost.TopLevelType.SecondLevelType.ThirdLevelType
  
  init() {
    self.topLevelType = MockingbirdModuleTestsHost.TopLevelType()
    self.secondLevelType = MockingbirdModuleTestsHost.TopLevelType.SecondLevelType()
    self.thirdLevelType = MockingbirdModuleTestsHost.TopLevelType.SecondLevelType.ThirdLevelType()
  }
}
