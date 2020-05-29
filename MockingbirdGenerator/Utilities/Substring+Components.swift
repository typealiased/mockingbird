//
//  Substring+Components.swift
//  MockingbirdGenerator
//
//  Created by Andrew Chang on 5/25/20.
//

import Foundation

public extension Substring {
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
  
  /// Whether the substring contains `needle`, ignoring any characters within the excluded `groups`.
  ///
  /// - Parameters:
  ///   - needle: The character to search for.
  ///   - groups: A map containing start group characters to end group characters.
  func contains(_ needle: Character, excluding groups: [Character: Character]) -> Bool {
    return firstIndex(of: needle, excluding: groups) != nil
  }
  
  /// The start of the first index of `needle` found in the substring, excluding grouped characters.
  ///
  /// - Parameters:
  ///   - needle: The character to search for.
  ///   - groups: A map containing start group characters to end group characters.
  /// - Returns: The first index if found, `nil` if `needle` does not exist.
  func firstIndex(of needle: Character, excluding groups: [Character: Character]) -> String.Index? {
    var currentGroups = [Character]()
    for (i, scalarValue) in utf8.enumerated() {
      let character = Character(UnicodeScalar(scalarValue))
      
      if currentGroups.isEmpty && character == needle {
        return index(startIndex, offsetBy: i)
      }
      
      if groups[character] != nil {
        currentGroups.append(character)
      }
      if let groupEnd = currentGroups.last, groups[groupEnd] == character {
        currentGroups.removeLast()
      }
    }
    return nil
  }
  
  /// Whether the substring contains `needle`, ignoring any characters within the excluded `groups`.
  ///
  /// - Parameters:
  ///   - needle: The string to search for.
  ///   - groups: A map containing start group characters to end group characters.
  func contains(_ needle: String, excluding groups: [Character: Character]) -> Bool {
    return firstIndex(of: needle, excluding: groups) != nil
  }
  
  /// The start of the first index of `needle` found in the substring, excluding grouped characters.
  ///
  /// - Parameters:
  ///   - needle: The string to search for.
  ///   - groups: A map containing start group characters to end group characters.
  /// - Returns: The first index if found, `nil` if `needle` does not exist.
  func firstIndex(of needle: String, excluding groups: [Character: Character]) -> String.Index? {
    var currentGroups = [Character]()
    var stateMachineStartIndex: Int?
    var stateMachine = 0
    for (i, scalarValue) in utf8.enumerated() {
      let character = Character(UnicodeScalar(scalarValue))
      
      if currentGroups.isEmpty {
        let needleIndex = needle.index(needle.startIndex, offsetBy: stateMachine)
        if character != needle[needleIndex] {
          stateMachine = 0
        } else {
          stateMachine += 1
          if stateMachine == 1 { stateMachineStartIndex = i }
          if stateMachine == needle.count {
            return index(startIndex, offsetBy: stateMachineStartIndex ?? 0)
          }
        }
      }
      
      if groups[character] != nil {
        currentGroups.append(character)
        stateMachine = 0
      }
      if let groupEnd = currentGroups.last, groups[groupEnd] == character {
        currentGroups.removeLast()
        stateMachine = 0
      }
    }
    return nil
  }
  
  /// Split the substring by a single delimiter character, excluding any characters found in groups.
  ///
  /// - Parameters:
  ///   - delimiter: A character to split the substring by.
  ///   - groups: A map containing start group characters to end group characters.
  /// - Returns: Substring components from splitting the current substring.
  func components(separatedBy delimiter: Character,
                  excluding groups: [Character: Character]) -> [Substring] {
    return components(separatedBy: [delimiter], excluding: groups)
  }
  
  /// Split the substring by multiple delimiters, excluding any characters found in groups.
  ///
  /// - Parameters:
  ///   - delimiters: A set of characters to split the substring by.
  ///   - groups: A map containing start group characters to end group characters.
  /// - Returns: Substring components from splitting the current substring.
  func components(separatedBy delimiters: Set<Character>,
                  excluding groups: [Character: Character]) -> [Substring] {
    var currentGroups = [Character]()
    var components = [Substring]()
    var currentComponent = Substring()
    for scalarValue in utf8 {
      let character = Character(UnicodeScalar(scalarValue))
      if groups[character] != nil {
        currentGroups.append(character)
      }
      if let groupEnd = currentGroups.last, groups[groupEnd] == character {
        currentGroups.removeLast()
      }
      if delimiters.contains(character) && currentGroups.isEmpty {
        components.append(currentComponent)
        currentComponent = Substring()
      }
      if !currentGroups.isEmpty || !delimiters.contains(character) {
        currentComponent.append(character)
      }
    }
    components.append(currentComponent)
    return components
  }
}
