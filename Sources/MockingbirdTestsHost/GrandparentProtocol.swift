import Foundation

protocol GrandparentProtocol {
  // MARK: Instance
  var grandparentPrivateSetterInstanceVariable: Bool { get }
  var grandparentInstanceVariable: Bool { get set }
  func grandparentTrivialInstanceMethod()
  func grandparentParameterizedInstanceMethod(param1: Bool, _ param2: Int) -> Bool
  
  // MARK: Static
  static var grandparentPrivateSetterStaticVariable: Bool { get }
  static var grandparentStaticVariable: Bool { get set }
  static func grandparentTrivialStaticMethod()
  static func grandparentParameterizedStaticMethod(param1: Bool, _ param2: Int) -> Bool
}
