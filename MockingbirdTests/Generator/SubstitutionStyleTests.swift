//
//  SubstitutionStyleTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 4/15/20.
//

import XCTest
@testable import MockingbirdGenerator

class SubstitutionStyleTests: XCTestCase {
  
  // MARK: - Wrapping
  
  func testWrappingVariable_inMakeStyle() {
    XCTAssertEqual(SubstitutionStyle.make.wrap("BIRD"), "$(BIRD)")
  }
  
  func testWrappingVariable_inBashStyle() {
    XCTAssertEqual(SubstitutionStyle.bash.wrap("BIRD"), "${BIRD}")
  }
  
  // MARK: - Unwrapping
  
  func testUnwrappingVariable_inMakeStyle() {
    let unwrapped = SubstitutionStyle.unwrap("$(BIRD)")
    XCTAssertEqual(unwrapped?.variable, "BIRD")
    XCTAssertEqual(unwrapped?.style, .make)
  }
  
  func testUnwrappingVariable_inBashStyle() {
    let unwrapped = SubstitutionStyle.unwrap("${BIRD}")
    XCTAssertEqual(unwrapped?.variable, "BIRD")
    XCTAssertEqual(unwrapped?.style, .bash)
  }
  
  func testUnwrappingVariable_inInvalidStyle() {
    XCTAssertEqual(SubstitutionStyle.unwrap("BIRD")?.variable, nil)
  }
}
