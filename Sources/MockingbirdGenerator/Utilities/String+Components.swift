//
//  String+Components.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 5/25/20.
//

import Foundation

public extension Dictionary where Key == Character, Value == Character {
  static var allGroups: [Character: Character] {
    return ["(": ")", "[": "]", "<": ">", "{": "}"]
  }

  static var nonParenthesisGroups: [Character: Character] {
    return ["[": "]", "<": ">", "{": "}"]
  }
}

public extension Set where Element == Character {
  static var whitespacesAndNewlines: Set<Character> {
    return ["\t", "\n", "\r", " "]
  }
}

public extension String {
  /// Whether the string contains `needle`, ignoring any characters within the excluded `groups`.
  ///
  /// - Parameters:
  ///   - needle: The character to search for.
  ///   - groups: A map containing start group characters to end group characters.
  func contains(_ needle: Character, excluding groups: [Character: Character]) -> Bool {
    return self[...].contains(needle, excluding: groups)
  }
  
  /// The start of the first index of `needle` found in the string, excluding grouped characters.
  ///
  /// - Parameters:
  ///   - needle: The character to search for.
  ///   - groups: A map containing start group characters to end group characters.
  /// - Returns: The first index if found, `nil` if `needle` does not exist.
  func firstIndex(of needle: Character, excluding groups: [Character: Character]) -> String.Index? {
    return self[...].firstIndex(of: needle, excluding: groups)
  }
  
  /// Whether the string contains `needle`, ignoring any characters within the excluded `groups`.
  ///
  /// - Parameters:
  ///   - needle: The string to search for.
  ///   - groups: A map containing start group characters to end group characters.
  func contains(_ needle: String, excluding groups: [Character: Character]) -> Bool {
    return self[...].contains(needle, excluding: groups)
  }
  
  /// The start of the first index of `needle` found in the string, excluding grouped characters.
  ///
  /// - Parameters:
  ///   - needle: The string to search for.
  ///   - groups: A map containing start group characters to end group characters.
  /// - Returns: The first index if found, `nil` if `needle` does not exist.
  func firstIndex(of needle: String, excluding groups: [Character: Character]) -> String.Index? {
    return self[...].firstIndex(of: needle, excluding: groups)
  }
  
  /// Splits a string into substrings given a character delimiter.
  ///
  /// - Note: This method is 2x faster than the built-in method on Release builds.
  ///
  /// - Parameter delimiter: A character to use to split the string.
  /// - Returns: An array of substrings.
  func substringComponents(separatedBy delimiter: Character) -> [Substring] {
    return self[...].substringComponents(separatedBy: delimiter)
  }
  
  /// Split the string by a single delimiter character, excluding any characters found in groups.
  ///
  /// - Parameters:
  ///   - delimiter: A character to split the string by.
  ///   - groups: A map containing start group characters to end group characters.
  /// - Returns: Substring components from splitting the current string.
  func components(separatedBy delimiter: Character,
                  excluding groups: [Character: Character]) -> [Substring] {
    return self[...].components(separatedBy: delimiter, excluding: groups)
  }
  
  /// Split the string by multiple delimiters, excluding any characters found in groups.
  ///
  /// - Parameters:
  ///   - delimiters: A set of characters to split the string by.
  ///   - groups: A map containing start group characters to end group characters.
  /// - Returns: Substring components from splitting the current string.
  func components(separatedBy delimiters: Set<Character>,
                  excluding groups: [Character: Character]) -> [Substring] {
    return self[...].components(separatedBy: delimiters, excluding: groups)
  }
}
