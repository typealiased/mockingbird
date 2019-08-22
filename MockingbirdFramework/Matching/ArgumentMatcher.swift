//
//  ArgumentMatcher.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation

/// Matchers use equality for objects conforming to `Equatable` and fall back to comparison by
/// reference. For custom objects that are not equatable, provide a custom `comparator` that should
/// return `true` if `base` (lhs) is equal to the other `base` (rhs).
public class ArgumentMatcher: CustomStringConvertible {
  /// Necessary for custom comparators such as `any()` that only work on the lhs.
  public struct Commutativity: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) {
      self.rawValue = rawValue
    }

    /// The matcher can be used as the receiver (lhs) for comparison operations.
    public static let lhs = Commutativity(rawValue: 1 << 0)
    /// The matcher can be used as the argument (rhs) for comparison operations.
    public static let rhs = Commutativity(rawValue: 1 << 1)
    /// The matcher can be used as either the receiver or the argument for comparison operations.
    public static let commutative: Commutativity = [.lhs, .rhs]
  }

  /// A base instance to compare using `comparator`.
  let base: Any?
  
  /// The original type of the base instance.
  let baseType: Any?

  /// A description for test failure output.
  public let description: String

  /// The commutativity of the matcher comparator.
  let commutativity: Commutativity

  /// The method to compare base instances, returning `true` if they should be considered the same.
  let comparator: (_ lhs: Any?, _ rhs: Any?) -> Bool

  func compare(with rhs: Any?) -> Bool {
    return comparator(base, rhs)
  }

  public init<T: Equatable>(_ base: T?,
                            description: String? = nil,
                            commutativity: Commutativity = .commutative) {
    self.base = base
    self.baseType = T.self
    self.description = description ?? "\(String.describe(base))"
    self.commutativity = commutativity
    self.comparator = { base == $1 as? T }
  }

  public init(_ base: Any?,
              description: String,
              commutativity: Commutativity = .lhs,
              _ comparator: @escaping @autoclosure () -> Bool) {
    self.base = base
    self.baseType = type(of: base)
    self.description = description
    self.commutativity = commutativity
    self.comparator = { _, _ in comparator() }
  }

  public init(_ base: Any?,
              description: String? = nil,
              commutativity: Commutativity = .lhs,
              _ comparator: ((Any?, Any?) -> Bool)? = nil) {
    self.base = base
    self.baseType = type(of: base)
    self.commutativity = comparator != nil ? commutativity : .commutative
    self.comparator = comparator ?? { $0 as AnyObject === $1 as AnyObject }
    let annotation = comparator == nil && base != nil ? " (by reference)" : ""
    self.description = description ?? "\(String.describe(base))\(annotation)"
  }
}

extension ArgumentMatcher: Equatable {
  public static func == (lhs: ArgumentMatcher, rhs: ArgumentMatcher) -> Bool {
    if lhs.commutativity == .lhs {
      return lhs.compare(with: rhs.base)
    } else if lhs.commutativity == .rhs {
      return rhs.compare(with: lhs.base)
    }

    if rhs.commutativity == .lhs {
      return rhs.compare(with: lhs.base)
    } else if rhs.commutativity == .rhs {
      return lhs.compare(with: rhs.base)
    }

    return lhs.compare(with: rhs.base) && rhs.compare(with: lhs.base)
  }
}
