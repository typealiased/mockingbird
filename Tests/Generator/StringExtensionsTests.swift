//
//  StringExtensionsTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 9/2/19.
//

import XCTest
@testable import MockingbirdGenerator

class StringExtensionsTests: XCTestCase {
  
  // MARK: - Capitalized first
  
  func testStringExtensions_capitalizedFirst_capitalizesFirstLowercaseCharacter() {
    XCTAssertEqual("hello world!".capitalizedFirst, "Hello world!")
  }
  
  func testStringExtensions_capitalizedFirst_handlesFirstUppercaseCharacter() {
    XCTAssertEqual("Hello world!".capitalizedFirst, "Hello world!")
  }

  // MARK: Backtick Wrapped

  func testStringExtensions_backtickWrapped_wrapsStringWithBackticks() {
    XCTAssertEqual("test string".backtickWrapped, "`test string`")
  }
  
  // MARK: - Substring components
  
  func testStringExtensions_substringComponents_separatesByDelimiterCharacter() {
    let expected: [Substring] = ["a", "b", "c", "d"]
    XCTAssertEqual("a.b.c.d".substringComponents(separatedBy: "."), expected)
  }
  
  func testStringExtensions_substringComponents_separatesStringsWithNoDelimiters() {
    let expected: [Substring] = ["abcd"]
    XCTAssertEqual("abcd".substringComponents(separatedBy: "."), expected)
  }
  
  func testStringExtensions_substringComponents_separatesEmptyStrings() {
    let expected: [Substring] = [""]
    XCTAssertEqual("".substringComponents(separatedBy: "."), expected)
  }
  
  func testStringExtensions_substringComponents_handlesLeadingDelimiter() {
    let expected: [Substring] = ["", "a"]
    XCTAssertEqual(".a".substringComponents(separatedBy: "."), expected)
  }
  
  func testStringExtensions_substringComponents_handlesTrailingDelimiter() {
    let expected: [Substring] = ["a", ""]
    XCTAssertEqual("a.".substringComponents(separatedBy: "."), expected)
  }
  
  // MARK: - Indent
  
  func testStringExtensions_indent_addsIndentationToSingleLineString() {
    XCTAssertEqual("foo-bar".indent(by: 2), "    foo-bar")
  }
  
  func testStringExtensions_indent_addsIndentationToMultiLineString() {
    let actual = """
    line1
      line2
        line3
    """.indent(by: 2)
    let expected = """
        line1
          line2
            line3
    """
    XCTAssertEqual(actual, expected)
  }
  
  func testStringExtensions_indent_doesNotChangeEmptyStrings() {
    XCTAssertEqual("".indent(by: 2), "")
  }
  
  func testStringExtensions_indent_ignoresEmptyLines() {
    let actual = """
    line1
    
    line2

    line3
    """.indent(by: 2)
    let expected = """
        line1
    
        line2

        line3
    """
    XCTAssertEqual(actual, expected)
  }
  
  // MARK: - Removing parameter attributes
  
  func testStringExtensions_removingParameterAttributes_removesFunctionAttributes() {
    let actual = "@escaping @autoclosure (Int, Bool) -> String".removingParameterAttributes()
    XCTAssertEqual(actual, "(Int, Bool) -> String")
  }
  
  func testStringExtensions_removingParameterAttributes_removesInoutAttribute() {
    let actual = "inout String".removingParameterAttributes()
    XCTAssertEqual(actual, "String")
  }
  
  func testStringExtensions_removingParameterAttributes_removesTopLevelInoutAttribute() {
    let actual = "inout (inout Int, inout Bool) -> String".removingParameterAttributes()
    XCTAssertEqual(actual, "(inout Int, inout Bool) -> String")
  }
  
  func testStringExtensions_removingParameterAttributes_removesVariadicAttribute() {
    let actual = "String...".removingParameterAttributes()
    XCTAssertEqual(actual, "String")
  }
  
  func testStringExtensions_removingParameterAttributes_removesSpacedVariadicAttribute() {
    let actual = "String \n\t ...".removingParameterAttributes()
    XCTAssertEqual(actual, "String")
  }
  
  func testStringExtensions_removingParameterAttributes_removesTopLevelVariadicAttribute() {
    let actual = "(Int..., Bool ...) -> String".removingParameterAttributes()
    XCTAssertEqual(actual, "(Int..., Bool...) -> String")
  }
  
  // MARK: - Removing generic typing
  
  func testStringExtensions_removingGenericTyping_removesAllGenericTypes() {
    let actual = "Type1<A, B, C>.Type2.Type3<D, E, F>.Type4".removingGenericTyping()
    XCTAssertEqual(actual, "Type1.Type2.Type3.Type4")
  }
  
  func testStringExtensions_removingGenericTyping_ignoresNestedGenerics() {
    let actual = "Type1<A<Int>, B<String>, C<Bool>>.Type2".removingGenericTyping()
    XCTAssertEqual(actual, "Type1.Type2")
  }
  
  // MARK: - Contains needle
  
  func testStringExtensions_containsNeedle_excludesCharacterGroups() {
    let actual = "abc (d123ef) <gh123i>".contains("123", excluding: ["(": ")", "<": ">"])
    XCTAssertFalse(actual)
  }
  
  func testStringExtensions_containsNeedle_excludesDefinedCharacterGroupsOnly() {
    let actual = "abc (d123ef) <gh123i> [jkl123]".contains("123", excluding: ["(": ")", "<": ">"])
    XCTAssertTrue(actual)
  }
  
  func testStringExtensions_containsNeedle_handlesNeedlesDefinedAsGroupStartCharacter() {
    let actual = "abc <(def)> [ghi] (jkl)".contains("(", excluding: ["(": ")", "<": ">"])
    XCTAssertTrue(actual)
  }
  
  // MARK: - First index of needle
  
  func testStringExtensions_firstIndexOfNeedle_excludesCharacterGroups() {
    let actual = "abc (d123ef) <gh123i>".firstIndex(of: "123", excluding: ["(": ")", "<": ">"])
    XCTAssertNil(actual)
  }
  
  func testStringExtensions_firstIndexOfNeedle_excludesDefinedCharacterGroupsOnly() {
    let string = "abc (d123ef) <gh123i> [jkl123]"
    let actual = string.firstIndex(of: "123", excluding: ["(": ")", "<": ">"])
    XCTAssertEqual(actual, string.index(string.startIndex, offsetBy: 26))
  }
  
  func testStringExtensions_firstIndexOfNeedle_handlesNeedlesDefinedAsGroupStartCharacter() {
    let string = "abc <(def)> [ghi] (jkl)"
    let actual = string.firstIndex(of: "(", excluding: ["(": ")", "<": ">"])
    XCTAssertEqual(actual, string.index(string.startIndex, offsetBy: 18))
  }
  
  // MARK: - Components separated by
  
  func testStringExtensions_componentsSeparatedBySingleDelimiter_excludesCharacterGroups() {
    let actual = "abc.(de.f).<g.hi>".components(separatedBy: ".", excluding: ["(": ")", "<": ">"])
    XCTAssertEqual(actual, ["abc", "(de.f)", "<g.hi>"])
  }
  
  func testStringExtensions_componentsSeparatedByMultipleDelimiters_excludesCharacterGroups() {
    let actual = "abc.(d,e.f),<g.h,i>".components(separatedBy: [".", ","],
                                                  excluding: ["(": ")", "<": ">"])
    XCTAssertEqual(actual, ["abc", "(d,e.f)", "<g.h,i>"])
  }
}
