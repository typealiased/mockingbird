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
  /// - note: This method is 2x faster than the built-in method on Release builds.
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
      currentSubstring = currentSubstring[currentSubstring.index(index, offsetBy: 1)..<endIndex]
    }
    return components
  }
}

extension Substring {
  /// Splits a substring into substrings given a character delimiter.
  ///
  /// - note: This method is 2x faster than the built-in method on Release builds.
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
      currentSubstring = currentSubstring[currentSubstring.index(index, offsetBy: 1)..<endIndex]
    }
    return components
  }
}
