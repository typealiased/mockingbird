import AppKit
import Foundation

protocol ObjCParameters {
  func method(value: NSViewController) -> Bool
  func method(optionalValue: NSViewController?) -> Bool
}
