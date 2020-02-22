//
//  PathFnmatchTests.swift
//  MockingbirdTests
//
//  Created by Andrew Chang on 10/29/19.
//

import XCTest
import PathKit
@testable import MockingbirdGenerator

class PathFnmatchTests: XCTestCase {
  
  // MARK: - Exact

  func testFnmatch_matchesExactFile() {
    let path = Path("/foo/bar.txt")
    XCTAssertTrue(path.matches(pattern: "/foo/bar.txt", isDirectory: false))
  }

  func testFnmatch_matchesExactDirectory_noTrailingSlash() {
    let path = Path("/foo/bar")
    XCTAssertTrue(path.matches(pattern: "/foo/bar/", isDirectory: true))
  }
  
  func testFnmatch_matchesExactDirectory_withTrailingSlash() {
    let path = Path("/foo/bar/")
    XCTAssertTrue(path.matches(pattern: "/foo/bar/", isDirectory: true))
  }
  
  func testFnmatch_matchesExactDirectory_rootDirectory() {
    let path = Path("/")
    XCTAssertTrue(path.matches(pattern: "/", isDirectory: true))
  }
  
  // MARK: - Relative
  
  func testFnmatch_matchesRelativeFile() {
    let path = Path("./foo/bar.txt")
    XCTAssertTrue(path.matches(pattern: "./foo/bar.txt", isDirectory: false))
  }
  
  func testFnmatch_matchesRelativeDirectory_noTrailingSlash() {
    let path = Path("./foo/bar")
    XCTAssertTrue(path.matches(pattern: "./foo/bar/", isDirectory: true))
  }
  
  func testFnmatch_matchesRelativeDirectory_withTrailingSlash() {
    let path = Path("./foo/bar/")
    XCTAssertTrue(path.matches(pattern: "./foo/bar/", isDirectory: true))
  }
  
  // MARK: - Wildcard
  
  func testFnmatch_matchesWildcardFilePath() {
    let path = Path("/foo/bar.txt")
    XCTAssertTrue(path.matches(pattern: "/foo/*", isDirectory: false))
  }
  
  func testFnmatch_matchesWildcardFileName() {
    let path = Path("/foo/bar.txt")
    XCTAssertTrue(path.matches(pattern: "/foo/*.txt", isDirectory: false))
  }
  
  func testFnmatch_matchesWildcardFileExtension() {
    let path = Path("/foo/bar.txt")
    XCTAssertTrue(path.matches(pattern: "/foo/bar.*", isDirectory: false))
  }
  
  func testFnmatch_matchesWildcardDirectory_withSpecificFileName() {
    let path = Path("/foo/baz/bar.txt")
    XCTAssertTrue(path.matches(pattern: "/foo/**/bar.txt", isDirectory: false))
  }
  
  func testFnmatch_matchesWildcardDirectory_withWildcardFilePath() {
    let path = Path("/foo/baz/bar.txt")
    XCTAssertTrue(path.matches(pattern: "/foo/**/*", isDirectory: false))
  }
  
  func testFnmatch_matchesWildcardDirectory_withWildcardFileName() {
    let path = Path("/foo/baz/bar.txt")
    XCTAssertTrue(path.matches(pattern: "/foo/**/*.txt", isDirectory: false))
  }
  
  func testFnmatch_matchesWildcardDirectory_withWildcardFileExtension() {
    let path = Path("/foo/baz/bar.txt")
    XCTAssertTrue(path.matches(pattern: "/foo/**/bar.*", isDirectory: false))
  }
  
  func testFnmatch_matchesWildcardDirectory() {
    let filePath = Path("/foo/bar.txt")
    let directoryPath = Path("/foo/bar")
    XCTAssertTrue(filePath.matches(pattern: "/foo/**", isDirectory: false))
    XCTAssertTrue(directoryPath.matches(pattern: "/foo/**", isDirectory: true))
  }
  
  func testFnmatch_matchesDotFile_withWildcardFileName() {
    let filePath = Path(".foo")
    XCTAssertTrue(filePath.matches(pattern: "*foo", isDirectory: false))
  }
}
