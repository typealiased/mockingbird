import Foundation

extension CharacterSet {
  static func createOptionalsSet() -> CharacterSet {
    var characterSet = CharacterSet()
    characterSet.insert(charactersIn: "!?")
    return characterSet
  }
}
