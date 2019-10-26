//
//  PBXTargetTests.swift
//  MockingbirdTests
//
//  Created by Sterling Hackley on 10/26/19.
//

import XCTest
import XcodeProj
@testable import MockingbirdGenerator

class PBXTargetTests: XCTestCase {

  // MARK: - productModuleName

  func testProductModuleName_handlesNonAlphaNumericCharacters() {
    let actual = PBXTarget(name: "a-module.name").productModuleName
    XCTAssertEqual(actual, "a_module_name")
  }

  func testProductModuleName_handlesFirstCharacterNumeral() {
    let actual = PBXTarget(name: "123name").productModuleName
    XCTAssertEqual(actual, "_23name")
  }
}
