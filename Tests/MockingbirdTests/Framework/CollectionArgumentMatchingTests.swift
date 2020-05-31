//
//  CollectionArgumentMatchingTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 9/6/19.
//

import XCTest
import Mockingbird
@testable import MockingbirdTestsHost

class CollectionArgumentMatchingTests: XCTestCase {
  
  var array: ArrayCollectionMock!
  var dictionary: DictionaryCollectionMock!
  
  override func setUp() {
    array = mock(ArrayCollection.self)
    dictionary = mock(DictionaryCollection.self)
  }
  
  // MARK: - Array
  
  func callArray(_ array: ArrayCollection, objects: [String]) -> Bool {
    return array.method(objects: objects)
  }
  
  func testArrayMatching_anyContainingValues_matchesIncludedElements() {
    given(array.method(objects: any())) ~> false
    given(array.method(objects: any(containing: "a", "b", "c"))) ~> true
    XCTAssertTrue(callArray(array, objects: ["a", "b", "c"]))
    verify(array.method(objects: any(containing: "a", "b", "c"))).wasCalled()
  }
  
  func testArrayMatching_anyContainingValues_requiresAllElements() {
    given(array.method(objects: any())) ~> false
    given(array.method(objects: any(containing: "a", "b", "c"))) ~> true
    XCTAssertFalse(callArray(array, objects: ["a", "b"]))
    verify(array.method(objects: any(containing: "a", "b", "c"))).wasNeverCalled()
  }
  
  func testArrayMatching_anyContainingValues_ignoresNonIncludedElements() {
    given(array.method(objects: any())) ~> false
    given(array.method(objects: any(containing: "a", "b", "c"))) ~> true
    XCTAssertFalse(callArray(array, objects: ["d"]))
    verify(array.method(objects: any(containing: "a", "b", "c"))).wasNeverCalled()
  }
  
  func testArrayMatching_anyCount_matchesCountMatcher() {
    given(array.method(objects: any())) ~> false
    given(array.method(objects: any(count: atMost(4)))) ~> true
    XCTAssertTrue(callArray(array, objects: ["the", "quick", "brown", "fox"]))
    verify(array.method(objects: any(count: atMost(4)))).wasCalled()
  }
  
  func testArrayMatching_anyCount_ignoresCountMatcher() {
    given(array.method(objects: any())) ~> false
    given(array.method(objects: any(count: atLeast(10)))) ~> true
    XCTAssertFalse(callArray(array, objects: ["the", "quick", "brown", "fox"]))
    verify(array.method(objects: any(count: atLeast(10)))).wasNeverCalled()
  }
  
  func testArrayMatching_notEmpty_matchesCountMatcher() {
    given(array.method(objects: any())) ~> false
    given(array.method(objects: notEmpty())) ~> true
    XCTAssertTrue(callArray(array, objects: ["the", "quick", "brown", "fox"]))
    verify(array.method(objects: notEmpty())).wasCalled()
  }
  
  func testArrayMatching_notEmpty_ignoresCountMatcher() {
    given(array.method(objects: any())) ~> false
    given(array.method(objects: notEmpty())) ~> true
    XCTAssertFalse(callArray(array, objects: []))
    verify(array.method(objects: notEmpty())).wasNeverCalled()
  }
  
  // MARK: - Dictionary
  
  func callDictionary(_ dictionary: DictionaryCollection, objects: [String: String]) -> Bool {
    return dictionary.method(objects: objects)
  }
  
  // MARK: Values
  
  func testDictionaryMatching_anyContainingValues_matchesIncludedElements() {
    given(dictionary.method(objects: any())) ~> false
    given(dictionary.method(objects: any(containing: "A", "B"))) ~> true
    XCTAssertTrue(callDictionary(dictionary, objects: ["a": "A", "b": "B"]))
    verify(dictionary.method(objects: any(containing: "A", "B"))).wasCalled()
  }
  
  func testDictionaryMatching_anyContainingValues_requiresAllElements() {
    given(dictionary.method(objects: any())) ~> false
    given(dictionary.method(objects: any(containing: "A", "B"))) ~> true
    XCTAssertFalse(callDictionary(dictionary, objects: ["a": "A"]))
    verify(dictionary.method(objects: any(containing: "A", "B"))).wasNeverCalled()
  }
  
  func testDictionaryMatching_anyContainingValues_ignoresNonIncludedElements() {
    given(dictionary.method(objects: any())) ~> false
    given(dictionary.method(objects: any(containing: "A", "B"))) ~> true
    XCTAssertFalse(callDictionary(dictionary, objects: ["c": "C"]))
    verify(dictionary.method(objects: any(containing: "A", "B"))).wasNeverCalled()
  }
  
  // MARK: Keys
  
  func testDictionaryMatching_anyKeys_matchesIncludedElements() {
    given(dictionary.method(objects: any())) ~> false
    given(dictionary.method(objects: any(keys: "a", "b"))) ~> true
    XCTAssertTrue(callDictionary(dictionary, objects: ["a": "A", "b": "B"]))
    verify(dictionary.method(objects: any(keys: "a", "b"))).wasCalled()
  }
  
  func testDictionaryMatching_anyKeys_requiresAllElements() {
    given(dictionary.method(objects: any())) ~> false
    given(dictionary.method(objects: any(keys: "a", "b"))) ~> true
    XCTAssertFalse(callDictionary(dictionary, objects: ["a": "A"]))
    verify(dictionary.method(objects: any(keys: "a", "b"))).wasNeverCalled()
  }
  
  func testDictionaryMatching_anyKeys_ignoresNonIncludedElements() {
    given(dictionary.method(objects: any())) ~> false
    given(dictionary.method(objects: any(keys: "a", "b"))) ~> true
    XCTAssertFalse(callDictionary(dictionary, objects: ["c": "C"]))
    verify(dictionary.method(objects: any(keys: "a", "b"))).wasNeverCalled()
  }
  
  func testDictionaryMatching_anyCount_matchesCountMatcher() {
    given(dictionary.method(objects: any())) ~> false
    given(dictionary.method(objects: any(count: atMost(2)))) ~> true
    XCTAssertTrue(callDictionary(dictionary, objects: ["the": "THE", "brown": "BROWN"]))
    verify(dictionary.method(objects: any(count: atMost(2)))).wasCalled()
  }
  
  func testDictionaryMatching_anyCount_ignoresCountMatcher() {
    given(dictionary.method(objects: any())) ~> false
    given(dictionary.method(objects: any(count: atLeast(10)))) ~> true
    XCTAssertFalse(callDictionary(dictionary, objects: ["the": "THE", "brown": "BROWN"]))
    verify(dictionary.method(objects: any(count: atLeast(10)))).wasNeverCalled()
  }
  
  func testDictionaryMatching_notEmpty_matchesCountMatcher() {
    given(dictionary.method(objects: any())) ~> false
    given(dictionary.method(objects: notEmpty())) ~> true
    XCTAssertTrue(callDictionary(dictionary, objects: ["the": "THE", "brown": "BROWN"]))
    verify(dictionary.method(objects: notEmpty())).wasCalled()
  }
  
  func testDictionaryMatching_notEmpty_ignoresCountMatcher() {
    given(dictionary.method(objects: any())) ~> false
    given(dictionary.method(objects: notEmpty())) ~> true
    XCTAssertFalse(callDictionary(dictionary, objects: [:]))
    verify(dictionary.method(objects: notEmpty())).wasNeverCalled()
  }
}
