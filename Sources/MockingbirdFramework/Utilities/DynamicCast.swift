import Foundation

/// Swift versions before 5.4 cannot cast from `Any` to a more optional type.
/// https://forums.swift.org/t/casting-from-any-to-optional/21883
func dynamicCast<T>(_ value: Any) -> T {
  return value as! T
}
