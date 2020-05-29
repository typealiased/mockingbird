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
    let actual = PBXTarget(name: "a-module.name").resolveProductModuleName(environment: { [:] })
    XCTAssertEqual(actual, "a_module_name")
  }

  func testProductModuleName_handlesFirstCharacterNumeral() {
    let actual = PBXTarget(name: "123name").resolveProductModuleName(environment: { [:] })
    XCTAssertEqual(actual, "_23name")
  }
  
  // MARK: - Build setting resolving
  
  func testResolveBuildSetting_literalValue() {
    let actual = try? PBXTarget.resolve(BuildSetting("foobar"), from: [:])
    XCTAssertEqual(actual, "foobar")
  }
  
  func testResolveBuildSetting_simpleExpression() {
    let actual = try? PBXTarget.resolve(BuildSetting("$(FOO)"), from: ["FOO": "BAR"])
    XCTAssertEqual(actual, "BAR")
  }
  
  func testResolveBuildSetting_simpleExpressionBashStyle() {
    let actual = try? PBXTarget.resolve(BuildSetting("${FOO}"), from: ["FOO": "BAR"])
    XCTAssertEqual(actual, "BAR")
  }
  
  func testResolveBuildSetting_simpleExpressionWithLeadingPadding() {
    let actual = try? PBXTarget.resolve(BuildSetting("pad$(FOO)"), from: ["FOO": "BAR"])
    XCTAssertEqual(actual, "padBAR")
  }
  
  func testResolveBuildSetting_simpleExpressionWithLeadingPaddingBashStyle() {
    let actual = try? PBXTarget.resolve(BuildSetting("pad${FOO}"), from: ["FOO": "BAR"])
    XCTAssertEqual(actual, "padBAR")
  }
  
  func testResolveBuildSetting_simpleExpressionWithTrailingPadding() {
    let actual = try? PBXTarget.resolve(BuildSetting("$(FOO)dap"), from: ["FOO": "BAR"])
    XCTAssertEqual(actual, "BARdap")
  }
  
  func testResolveBuildSetting_simpleExpressionWithTrailingPaddingBashStyle() {
    let actual = try? PBXTarget.resolve(BuildSetting("${FOO}dap"), from: ["FOO": "BAR"])
    XCTAssertEqual(actual, "BARdap")
  }
  
  func testResolveBuildSetting_simpleExpressionWithLeadingTrailingPadding() {
    let actual = try? PBXTarget.resolve(BuildSetting("pad$(FOO)dap"), from: ["FOO": "BAR"])
    XCTAssertEqual(actual, "padBARdap")
  }
  
  func testResolveBuildSetting_simpleExpressionWithLeadingTrailingPaddingBashStyle() {
    let actual = try? PBXTarget.resolve(BuildSetting("pad${FOO}dap"), from: ["FOO": "BAR"])
    XCTAssertEqual(actual, "padBARdap")
  }
  
  func testResolveBuildSetting_multipleConsecutiveExpressions() {
    let actual = try? PBXTarget.resolve(BuildSetting("$(FOO)$(BAR)"),
                                        from: ["FOO": "BAR", "BAR": "BAZ"])
    XCTAssertEqual(actual, "BARBAZ")
  }
  
  func testResolveBuildSetting_multipleConsecutiveExpressionsBashStyle() {
    let actual = try? PBXTarget.resolve(BuildSetting("${FOO}${BAR}"),
                                        from: ["FOO": "BAR", "BAR": "BAZ"])
    XCTAssertEqual(actual, "BARBAZ")
  }
  
  func testResolveBuildSetting_multipleExpressionsWithPadding() {
    let actual = try? PBXTarget.resolve(BuildSetting("$(FOO)pad$(BAR)"),
                                        from: ["FOO": "BAR", "BAR": "BAZ"])
    XCTAssertEqual(actual, "BARpadBAZ")
  }
  
  func testResolveBuildSetting_multipleExpressionsWithPaddingBashStyle() {
    let actual = try? PBXTarget.resolve(BuildSetting("${FOO}pad${BAR}"),
                                        from: ["FOO": "BAR", "BAR": "BAZ"])
    XCTAssertEqual(actual, "BARpadBAZ")
  }
  
  // MARK: Chained expressions
  
  func testResolveBuildSetting_simpleChainedExpression() {
    let actual = try? PBXTarget.resolve(BuildSetting("$(FOO)"),
                                        from: ["FOO": "$(BAR)", "BAR": "BAZ"])
    XCTAssertEqual(actual, "BAZ")
  }
  
  func testResolveBuildSetting_simpleChainedExpressionBashStyle() {
    let actual = try? PBXTarget.resolve(BuildSetting("${FOO}"),
                                        from: ["FOO": "${BAR}", "BAR": "BAZ"])
    XCTAssertEqual(actual, "BAZ")
  }
  
  func testResolveBuildSetting_simpleChainedExpressionMixedStyle() {
    let actual = try? PBXTarget.resolve(BuildSetting("$(FOO)"),
                                        from: ["FOO": "${BAR}", "BAR": "BAZ"])
    XCTAssertEqual(actual, "BAZ")
  }
  
  // MARK: Default values
  
  func testResolveBuildSetting_nonEmptyExpressionWithDefaultValue() {
    let actual = try? PBXTarget.resolve(BuildSetting("$(FOO:default=a value)"),
                                        from: ["FOO": "BAR"])
    XCTAssertEqual(actual, "BAR")
  }
  
  func testResolveBuildSetting_missingExpressionWithDefaultValueLiteral() {
    let actual = try? PBXTarget.resolve(BuildSetting("$(FOO:default=a value)"), from: [:])
    XCTAssertEqual(actual, "a value")
  }
  
  func testResolveBuildSetting_multipleMissingExpressionWithDefaultValueLiteral() {
    let actual = try? PBXTarget.resolve(
      BuildSetting("$(FOO:default=a value) $(BAR:default=another value)"),
      from: [:]
    )
    XCTAssertEqual(actual, "a value another value")
  }
  
  func testResolveBuildSetting_emptyExpressionWithDefaultValueLiteral() {
    let actual = try? PBXTarget.resolve(BuildSetting("$(FOO:default=a value)"),
                                        from: ["FOO": ""])
    XCTAssertEqual(actual, "a value")
  }
  
  func testResolveBuildSetting_multipleEmptyExpressionWithDefaultValueLiteral() {
    let actual = try? PBXTarget.resolve(
      BuildSetting("$(FOO:default=a value) $(BAR:default=another value)"),
      from: ["FOO": "", "BAR": ""]
    )
    XCTAssertEqual(actual, "a value another value")
  }
  
  func testResolveBuildSetting_missingExpressionWithDefaultValueExpression() {
    let actual = try? PBXTarget.resolve(BuildSetting("$(FOO:default=$(BAR))"),
                                        from: ["BAR": "BAZ"])
    XCTAssertEqual(actual, "BAZ")
  }
  
  func testResolveBuildSetting_multipleMissingExpressionsWithDefaultValueExpression() {
    let actual = try? PBXTarget.resolve(
      BuildSetting("$(FOO:default=$(BAR)) $(HELLO:default=$(WORLD))"),
      from: ["BAR": "BAZ", "WORLD": "!!"]
    )
    XCTAssertEqual(actual, "BAZ !!")
  }
  
  func testResolveBuildSetting_missingExpressionWithDefaultValuePaddedExpression() {
    let actual = try? PBXTarget.resolve(BuildSetting("$(FOO:default=pad $(BAR) dap)"),
                                        from: ["BAR": "BAZ"])
    XCTAssertEqual(actual, "pad BAZ dap")
  }
  
  func testResolveBuildSetting_missingExpressionWithNestedDefaultValueLiteral() {
    let actual = try? PBXTarget.resolve(BuildSetting("$(FOO:default=$(BAR:default=a value))"),
                                        from: [:])
    XCTAssertEqual(actual, "a value")
  }
  
  func testResolveBuildSetting_missingExpressionWithNestedDefaultValueExpression() {
    let actual = try? PBXTarget.resolve(BuildSetting("$(FOO:default=$(BAR:default=$(BAZ)))"),
                                        from: ["BAZ": "BOO"])
    XCTAssertEqual(actual, "BOO")
  }
  
  // MARK: Circular evaluations
  
  func testResolveBuildSetting_handlesCircularEvaluatedExpressions() {
    XCTAssertThrowsError(try PBXTarget.resolve(BuildSetting("$(FOO)"),
                                               from: ["FOO": "$(BAR)",
                                                      "BAR": "$(BAZ)",
                                                      "BAZ": "$(FOO)"]))
  }
  
  func testResolveBuildSetting_handlesCircularEvaluatedExpressionsFromDefaults() {
    XCTAssertThrowsError(try PBXTarget.resolve(BuildSetting("$(FOO:default=$(BAR))"),
                                               from: ["BAR": "$(BAZ)",
                                                      "BAZ": "$(FOO)"]))
  }
  
  // MARK: Unbalanced parentheses
  
  func testResolveBuildSetting_handlesUnbalancedParenthesesClose() {
    let actual = try? PBXTarget.resolve(BuildSetting("$(FOO"), from: ["FOO": "BAR"])
    XCTAssertEqual(actual, "$(FOO")
  }
  
  func testResolveBuildSetting_handlesUnbalancedParenthesesCloseBashStyle() {
    let actual = try? PBXTarget.resolve(BuildSetting("${FOO"), from: ["FOO": "BAR"])
    XCTAssertEqual(actual, "${FOO")
  }
  
  func testResolveBuildSetting_handlesUnbalancedParenthesesOpen() {
    let actual = try? PBXTarget.resolve(BuildSetting("FOO)"), from: ["FOO": "BAR"])
    XCTAssertEqual(actual, "FOO)")
  }
  
  func testResolveBuildSetting_handlesUnbalancedParenthesesOpenBashStyle() {
    let actual = try? PBXTarget.resolve(BuildSetting("FOO}"), from: ["FOO": "BAR"])
    XCTAssertEqual(actual, "FOO}")
  }
  
  func testResolveBuildSetting_handlesUnbalancedMultipleParenthesesClose() {
    let actual = try? PBXTarget.resolve(BuildSetting("$((FOO)"), from: ["FOO": "BAR"])
    XCTAssertEqual(actual, "")
  }
  
  func testResolveBuildSetting_handlesUnbalancedMultipleParenthesesCloseBashStyle() {
    let actual = try? PBXTarget.resolve(BuildSetting("${{FOO}"), from: ["FOO": "BAR"])
    XCTAssertEqual(actual, "")
  }
  
  func testResolveBuildSetting_handlesUnbalancedMultipleParenthesesOpen() {
    let actual = try? PBXTarget.resolve(BuildSetting("$(FOO))"), from: ["FOO": "BAR"])
    XCTAssertEqual(actual, "BAR)")
  }
  
  func testResolveBuildSetting_handlesUnbalancedMultipleParenthesesOpenBashStyle() {
    let actual = try? PBXTarget.resolve(BuildSetting("${FOO}}"), from: ["FOO": "BAR"])
    XCTAssertEqual(actual, "BAR}")
  }
}
