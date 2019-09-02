//
//  String+Extensions.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/16/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

extension String {
  /// Capitalizes only the first character of the string.
  var capitalizedFirst: String {
    return prefix(1).uppercased() + dropFirst()
  }
  
  /// Splits a string into substrings given a character delimiter.
  ///
  /// - Note: This method is 2x faster than the built-in method on Release builds.
  ///
  /// - Parameter delimiter: A character to use to split the string.
  /// - Returns: An array of substrings.
  func substringComponents(separatedBy delimiter: Character) -> [Substring] {
    var components = [Substring]()
    var currentSubstring = self[..<endIndex]
    while true {
      let index = currentSubstring.firstIndex(of: delimiter) ?? endIndex
      let component = currentSubstring[..<index]
      components.append(component)
      guard index != endIndex else { break }
      currentSubstring = currentSubstring[currentSubstring.index(after: index)..<endIndex]
    }
    return components
  }
  
  /// Adds two-space indentation `offset` number of times.
  ///
  /// - Parameter offset: The number of times to indent the current string.
  /// - Returns: A new indented string instance.
  func indent(by offset: UInt) -> String {
    guard offset > 0 else { return self }
    let lines = substringComponents(separatedBy: "\n")
    var indentation = "  "
    for _ in 0..<(offset-1) { indentation += "  " }
    return lines.map({ indentation + $0 }).joined(separator: "\n")
  }
  
  /// Whether the current string contains some needle outside of any parenthetical groups.
  ///
  /// - Note: This does the same thing as Sourcery's `isValidClosure()`, but ~3x faster.
  ///
  /// - Parameter needle: The string to search for within the current string.
  func containsUngrouped(_ needle: String,
                         groupStart: Character = "(",
                         groupEnd: Character = ")") -> Bool {
    var groupIndex = 0
    var stateMachine = 0
    var substring = self[...]
    while let character = substring.first {
      switch character {
      case groupStart:
        groupIndex += 1
        stateMachine = 0
      case groupEnd:
        groupIndex -= 1
        stateMachine = 0
      default:
        guard groupIndex == 0 else { break }
        let needleIndex = needle.index(needle.startIndex, offsetBy: stateMachine)
        guard character == needle[needleIndex] else {
          stateMachine = 0
          break
        }
        stateMachine += 1
        if stateMachine == needle.count { return true }
      }
      substring = substring.dropFirst()
    }
    return false
  }
  
  /// Returns a new string created by removing function parameter attributes.
  func removingParameterAttributes() -> String {
    let groupDelimiter = (open: "(", close: ")")
    var trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
      .components(separatedBy: "@escaping", excludingDelimiterBetween: groupDelimiter)
      .joined(separator: "")
      .components(separatedBy: "@autoclosure", excludingDelimiterBetween: groupDelimiter)
      .joined(separator: "")
    if let inoutRange = trimmed.range(of: #"\binout\b"#, options: .regularExpression),
      inoutRange.lowerBound == trimmed.startIndex {
      trimmed = String(trimmed[inoutRange.upperBound...])
    }
    if trimmed.hasSuffix("...") {
      trimmed = String(trimmed[..<trimmed.index(trimmed.endIndex, offsetBy: -3)])
    }
    return trimmed.trimmingCharacters(in: .whitespacesAndNewlines)
  }
  
  /// Returns a new string created by removing generic typing, e.g. `SomeType<T>` becomes `SomeType`
  func removingGenericTyping() -> String {
    return substringComponents(separatedBy: ".").map({ component -> Substring in
      guard let genericTypeStartIndex = component.firstIndex(of: "<") else { return component }
      return component[..<genericTypeStartIndex]
    }).joined(separator: ".")
  }
}

extension Substring {
  /// Splits a substring into substrings given a character delimiter.
  ///
  /// - Note: This method is 2x faster than the built-in method on Release builds.
  ///
  /// - Parameter delimiter: A character to use to split the substring.
  /// - Returns: An array of substrings.
  func substringComponents(separatedBy delimiter: Character) -> [Substring] {
    var components = [Substring]()
    var currentSubstring = self[..<endIndex]
    while true {
      let index = currentSubstring.firstIndex(of: delimiter) ?? endIndex
      let component = currentSubstring[..<index]
      components.append(component)
      guard index != endIndex else { break }
      currentSubstring = currentSubstring[currentSubstring.index(after: index)..<endIndex]
    }
    return components
  }
}
