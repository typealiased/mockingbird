//
//  ArgumentMatcher.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation

/// Matches argument values with a comparator.
public class ArgumentMatcher: CustomStringConvertible {
  /// Necessary for custom comparators such as `any()` that only work on the lhs.
  enum Priority: UInt {
    case low = 0, `default` = 500, high = 1000
  }

  /// A base instance to compare using `comparator`.
  let base: Any?
  
  /// The original type of the base instance.
  let baseType: Any?

  /// A description for test failure output.
  public let description: String

  /// The commutativity of the matcher comparator.
  let priority: Priority

  /// The method to compare base instances, returning `true` if they should be considered the same.
  let comparator: (_ lhs: Any?, _ rhs: Any?) -> Bool

  func compare(with rhs: Any?) -> Bool {
    return comparator(base, rhs)
  }

  init<T: Equatable>(_ base: T?,
                     description: String? = nil,
                     priority: Priority = .default) {
    self.base = base
    self.baseType = T.self
    self.description = description ?? "\(String.describe(base))"
    self.priority = priority
    self.comparator = { base == $1 as? T }
  }
  
  convenience init(description: String,
                   priority: Priority = .low,
                   comparator: @escaping () -> Bool) {
    self.init(Optional<ArgumentMatcher>(nil), description: description, priority: priority) {
      (_, _) -> Bool in
      return comparator()
    }
  }
  
  init<T>(_ base: T? = nil,
          description: String? = nil,
          priority: Priority = .low,
          comparator: ((Any?, Any?) -> Bool)? = nil) {
    self.base = base
    self.baseType = type(of: base)
    self.priority = priority
    self.comparator = comparator ?? { $0 as AnyObject === $1 as AnyObject }
    let annotation = comparator == nil ? " (by reference)" : ""
    self.description = description ?? "\(String.describe(base))\(annotation)"
  }
  
  init(_ matcher: ArgumentMatcher) {
    self.base = matcher.base
    self.baseType = type(of: matcher.base)
    self.priority = matcher.priority
    self.comparator = matcher.comparator
    self.description = matcher.description
  }
}

extension ArgumentMatcher: Equatable {
  public static func == (lhs: ArgumentMatcher, rhs: ArgumentMatcher) -> Bool {
    if lhs.priority.rawValue >= rhs.priority.rawValue {
      return lhs.compare(with: rhs.base)
    } else {
      return rhs.compare(with: lhs.base)
    }
  }
}
