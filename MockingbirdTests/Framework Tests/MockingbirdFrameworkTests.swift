//
//  MockingbirdFramework.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 8/13/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import XCTest
import Mockingbird
@testable import MockingbirdTestsHost

class MockingbirdFrameworkTests: XCTestCase {
  
  var child: Child!
  
  override func setUp() {
    child = ChildMock()
  }
}
