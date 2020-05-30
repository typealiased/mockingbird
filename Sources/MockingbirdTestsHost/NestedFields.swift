//
//  NestedFields.swift
//  MockingbirdTestsHost
//
//  Created by Andrew Chang on 8/29/19.
//

import Foundation

protocol ServiceRepository {
  var testManager: TestManager { get }
}

protocol TestManager {
  var currentTest: Test { get }
  func stopTests() -> Bool
}

protocol Test {
  var testCase: TestCase { get }
  func add(testCase: TestCase) -> Bool
}

protocol TestCase {
  func run(description: String) -> Bool
}
