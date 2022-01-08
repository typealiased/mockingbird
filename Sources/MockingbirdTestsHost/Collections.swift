import Foundation

protocol ArrayCollection {
  func method(objects: [String]) -> Bool
}

protocol DictionaryCollection {
  func method(objects: [String: String]) -> Bool
}
