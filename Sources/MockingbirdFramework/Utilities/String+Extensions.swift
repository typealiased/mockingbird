import Foundation

extension String {
  static func describe(_ subject: Any?) -> String {
    guard let subject = subject else { return "nil" }
    return String(describing: subject)
  }
  
  /// Returns a new string created by removing generic typing, e.g. `SomeType<T>` becomes `SomeType`
  func removingGenericTyping() -> String {
    guard let genericTypeStartIndex = firstIndex(of: "<") else { return self }
    guard contains(".") else { return String(self[..<genericTypeStartIndex]) }
    return self[...]
      .components(separatedBy: ".", excluding: ["<": ">"])
      .map({ component -> Substring in
        guard let genericTypeStartIndex = component.firstIndex(of: "<") else { return component }
        return component[..<genericTypeStartIndex]
      }).joined(separator: ".")
  }
}

extension Substring {
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
