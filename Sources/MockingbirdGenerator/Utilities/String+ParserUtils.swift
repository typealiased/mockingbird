//
//  String+ParserUtils.swift
//  MockingbirdCli
//
//  Created by Andrew Chang on 8/16/19.
//  Copyright © 2019 Bird Rides, Inc. All rights reserved.
//

import Foundation

public extension String {
  /// Capitalizes only the first character of the string.
  var capitalizedFirst: String {
    return prefix(1).uppercased() + dropFirst()
  }

  /// Wraps the string with backticks, e.g. for escaping keywords
  var backtickWrapped: String {
    return "`\(self)`"
  }
  
  var backtickUnwrapped: String {
    return replacingOccurrences(of: "`", with: "")
  }
  
  /// Wraps the string in single quotes.
  var singleQuoted: String {
    return "'\(self)'"
  }
  
  /// Wraps the string in double quotes.
  var doubleQuoted: String {
    return "\"\(self)\""
  }
  
  /// Escape the string for use in module names, replacing special characters and invalid prefixes.
  func escapingForModuleName() -> String {
    let replaced = replacingOccurrences(of: "\\W", with: "_", options: .regularExpression)
    if String(replaced[startIndex]).range(of: "\\d", options: .regularExpression) != nil {
      return replaced.replacingCharacters(in: ...startIndex, with: "_")
    } else {
      return replaced
    }
  }
  
  /// Adds two-space indentation `offset` number of times.
  ///
  /// - Parameter offset: The number of times to indent the current string.
  /// - Returns: A new indented string instance.
  func indent(by offset: Int = 1) -> String {
    guard offset > 0, !isEmpty else { return self }
    let lines = substringComponents(separatedBy: "\n")
    let indentation = String(repeating: "  ", count: offset)
    return String(lines: lines.map({
      guard !$0.isEmpty else { return String($0) }
      return indentation + $0
    }), keepEmptyLines: true)
  }
  
  /// Returns a new string created by removing implicitly unwrapped optionals.
  func removingImplicitlyUnwrappedOptionals() -> String {
    return replacingOccurrences(of: "!", with: "")
  }
  
  /// Returns a new string created by removing function parameter attributes.
  func removingParameterAttributes() -> String {
    // Happy path; heuristically determines if we need to perform the complex encode-decode routine.
    // This is potentially dangerous but saves a lot of computation time.
    guard firstIndex(of: ":") != nil // Has label
      || firstIndex(of: "!") != nil // Has implicitly unwrapped optional
      || firstIndex(of: "@") != nil // Has attribute
      || contains("...") // Is variadic
      || contains("inout") // Is inout (probably)
      else { return self }
    
    var options = SerializationRequest.Options.standard
    options.insert(.shouldExcludeImplicitlyUnwrappedOptionals)
    let request = SerializationRequest(method: .notQualified,
                                       context: SerializationRequest.Context(),
                                       options: options)
    return Function.Parameter(from: self).type.serialize(with: request)
  }
  
  /// Returns a new string created by removing generic typing, e.g. `SomeType<T>` becomes `SomeType`
  func removingGenericTyping() -> String {
    guard let genericTypeStartIndex = firstIndex(of: "<") else { return self }
    guard contains(".") else { return String(self[..<genericTypeStartIndex]) }
    return self[...]
      .components(separatedBy: ".", excluding: .allGroups)
      .map({ component -> Substring in
        guard let genericTypeStartIndex = component.firstIndex(of: "<") else { return component }
        return component[..<genericTypeStartIndex]
      }).joined(separator: ".")
  }
}
