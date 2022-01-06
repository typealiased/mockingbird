import Foundation

/// Checks whether a number matches some expected count.
public struct CountMatcher {
  let matcher: (Int) -> Bool

  /// Creates a printable description of the expected call count.
  let descriptionCreator: (Invocation, Bool) -> String

  init(_ matcher: @escaping (Int) -> Bool,
       describedBy descriptionCreator: @escaping (Invocation, Bool) -> String) {
    self.matcher = matcher
    self.descriptionCreator = descriptionCreator
  }

  func matches(_ count: Int) -> Bool { return matcher(count) }

  func describe(invocation: Invocation, negated: Bool = false) -> String {
    return descriptionCreator(invocation, negated)
  }
}

// MARK: - Adverbial counts

/// A count of zero.
public let never: Int = 0

/// A count of one.
public let once: Int = 1

/// A count of two.
public let twice: Int = 2

// MARK: - Count matchers

/// Matches an exact count.
///
/// The `exactly` count matcher can be used to verify that the actual number of invocations received
/// by a mock equals the expected number of invocations.
///
/// ```swift
/// // Given two invocations (n = 2)
/// bird.fly()
/// bird.fly()
///
/// verify(bird.fly()).wasCalled(exactly(1))  // Fails (n ≠ 1)
/// verify(bird.fly()).wasCalled(exactly(2))  // Passes
/// ```
///
/// You can combine count matchers with adverbial counts for improved readability.
///
/// ```swift
/// verify(bird.fly()).wasCalled(exactly(once))
/// ```
///
/// - Parameter times: An exact integer count.
/// - Returns: A count matcher.
public func exactly(_ times: Int) -> CountMatcher {
  return CountMatcher({ $0 == times }, describedBy: { "n \($1 ? "≠" : "=") \(times)" })
}

/// Matches greater than or equal to some count.
///
/// The `atLeast` count matcher can be used to verify that the actual number of invocations received
/// by a mock is greater than or equal to the expected number of invocations.
///
/// ```swift
/// // Given two invocations (n = 2)
/// bird.fly()
/// bird.fly()
///
/// verify(bird.fly()).wasCalled(atLeast(1))  // Passes
/// verify(bird.fly()).wasCalled(atLeast(2))  // Passes
/// verify(bird.fly()).wasCalled(atLeast(3))  // Fails (n < 3)
/// ```
///
/// You can combine count matchers with adverbial counts for improved readability.
///
/// ```swift
/// verify(bird.fly()).wasCalled(atLeast(once))
/// ```
///
/// - Parameter times: An inclusive lower bound.
/// - Returns: A count matcher.
public func atLeast(_ times: Int) -> CountMatcher {
  return CountMatcher({ $0 >= times }, describedBy: { "n \($1 ? "<" : "≥") \(times)" })
}

/// Matches less than or equal to some count.
///
/// The `atMost` count matcher can be used to verify that the actual number of invocations received
/// by a mock is less than or equal to the expected number of invocations.
///
/// ```swift
/// // Given two invocations (n = 2)
/// bird.fly()
/// bird.fly()
///
/// verify(bird.fly()).wasCalled(atMost(1))  // Fails (n > 1)
/// verify(bird.fly()).wasCalled(atMost(2))  // Passes
/// verify(bird.fly()).wasCalled(atMost(3))  // Passes
/// ```
///
/// You can combine count matchers with adverbial counts for improved readability.
///
/// ```swift
/// verify(bird.fly()).wasCalled(atMost(once))
/// ```
///
/// - Parameter times: An inclusive upper bound.
/// - Returns: A count matcher.
public func atMost(_ times: Int) -> CountMatcher {
  return CountMatcher({ $0 <= times }, describedBy: { "n \($1 ? ">" : "≤") \(times)" })
}

/// Matches counts that fall within some range.
///
/// The `between` count matcher can be used to verify that the actual number of invocations received
/// by a mock is within an inclusive range of expected invocations.
///
/// ```swift
/// // Given two invocations (n = 2)
/// bird.fly()
/// bird.fly()
///
/// verify(bird.fly()).wasCalled(between(1...2))  // Passes
/// verify(bird.fly()).wasCalled(between(3...4))  // Fails (3 ≮ n < 4)
/// ```
///
/// You can combine count matchers with adverbial counts for improved readability.
///
/// ```swift
/// verify(bird.fly()).wasCalled(between(once...twice))
/// ```
///
/// - Parameter range: An closed integer range.
/// - Returns: A count matcher.
public func between(_ range: Range<Int>) -> CountMatcher {
  return atLeast(range.lowerBound).and(atMost(range.upperBound))
}

// MARK: - Composition

extension CountMatcher {
  /// Logically combine another count matcher, passing if either matches.
  ///
  /// Combined count matchers can be used to perform complex checks on the number of invocations
  /// received.
  ///
  /// ```swift
  /// // Checks that n = 1 || n ≥ 42
  /// verify(bird.fly()).wasCalled(exactly(once).or(atLeast(42)))
  /// ```
  ///
  /// - Parameter countMatcher: Another count matcher to combine.
  /// - Returns: A combined count matcher.
  public func or(_ countMatcher: CountMatcher) -> CountMatcher {
    let matcherCopy = self
    let otherMatcherCopy = countMatcher
    return CountMatcher({ matcherCopy.matcher($0) || otherMatcherCopy.matcher($0) },
      describedBy: {
        let matcherDescription = matcherCopy.describe(invocation: $0, negated: $1)
        let otherMatcherDescription = otherMatcherCopy.describe(invocation: $0, negated: $1)
        let operand = $1 ? "&&" : "||"
        return "(\(matcherDescription)) \(operand) (\(otherMatcherDescription))"
    })
  }
  
  /// Logically combine with an exact count, passing if either matches.
  ///
  /// Combined count matchers can be used to perform complex checks on the number of invocations
  /// received.
  ///
  /// ```swift
  /// // Checks that n = 1 || n = 2
  /// verify(bird.fly()).wasCalled(exactly(once).or(twice))
  /// ```
  ///
  /// - Parameter times: An exact count to combine.
  /// - Returns: A combined count matcher.
  public func or(_ times: Int) -> CountMatcher { return or(exactly(times)) }

  /// Logically combine another count matcher, only passing if both match.
  ///
  /// Combined count matchers can be used to perform complex checks on the number of invocations
  /// received.
  ///
  /// ```swift
  /// // Checks that n = 1 && n ≥ 42
  /// verify(bird.fly()).wasCalled(exactly(once).and(atLeast(42)))
  /// ```
  ///
  /// - Parameter countMatcher: Another count matcher to combine.
  /// - Returns: A combined count matcher.
  public func and(_ countMatcher: CountMatcher) -> CountMatcher {
    let matcherCopy = self
    let otherMatcherCopy = countMatcher
    return CountMatcher({ matcherCopy.matcher($0) && otherMatcherCopy.matcher($0) },
      describedBy: {
        let matcherDescription = matcherCopy.describe(invocation: $0, negated: $1)
        let otherMatcherDescription = otherMatcherCopy.describe(invocation: $0, negated: $1)
        let operand = $1 ? "||" : "&&"
        return "(\(matcherDescription)) \(operand) (\(otherMatcherDescription))"
    })
  }

  /// Logically combine another count matcher, only passing if one matches but not the other.
  ///
  /// Combined count matchers can be used to perform complex checks on the number of invocations
  /// received.
  ///
  /// ```swift
  /// // Checks that n ≤ 2 ⊕ n ≥ 1
  /// verify(bird.fly()).wasCalled(atMost(twice).xor(atLeast(once)))
  /// ```
  ///
  /// - Parameter countMatcher: Another count matcher to combine.
  /// - Returns: A combined count matcher.
  public func xor(_ countMatcher: CountMatcher) -> CountMatcher {
    let matcherCopy = self
    let otherMatcherCopy = countMatcher
    return CountMatcher({ matcherCopy.matcher($0) != otherMatcherCopy.matcher($0) },
      describedBy: {
        let matcherDescription = matcherCopy.describe(invocation: $0, negated: $1)
        let otherMatcherDescription = otherMatcherCopy.describe(invocation: $0, negated: $1)
        let operand = $1 ? "≠" : "="
        return "(\(matcherDescription)) \(operand) (\(otherMatcherDescription))"
    })
  }
  
  /// Logically combine an exact count, only passing if one matches but not the other.
  ///
  /// Combined count matchers can be used to perform complex checks on the number of invocations
  /// received.
  ///
  /// ```swift
  /// // Checks that n ≥ 1 ⊕ n = 2
  /// verify(bird.fly()).wasCalled(atLeast(once).xor(twice))
  /// ```
  ///
  /// - Parameter times: An exact count.
  /// - Returns: A combined count matcher.
  public func xor(_ times: Int) -> CountMatcher { return xor(exactly(times)) }
}

/// Negate a count matcher, only passing on non-matching counts.
///
/// Combined count matchers can be used to perform complex checks on the number of invocations
/// received.
///
/// ```swift
/// // Checks that n ≠ 1
/// verify(bird.fly()).wasCalled(not(exactly(once)))
/// ```
///
/// - Parameter countMatcher: A count matcher to negate.
/// - Returns: A negated count matcher.
public func not(_ countMatcher: CountMatcher) -> CountMatcher {
  let matcherCopy = countMatcher
  return CountMatcher({ !matcherCopy.matcher($0) },
    describedBy: {
      let matcherDescription = matcherCopy.describe(invocation: $0, negated: !$1)
      return "\(matcherDescription)"
  })
}

/// Negate an exact count, only passing on non-matching counts.
///
/// Combined count matchers can be used to perform complex checks on the number of invocations
/// received.
///
/// ```swift
/// // Checks that n ≠ 1
/// verify(bird.fly()).wasCalled(not(once))
/// ```
///
/// - Parameter countMatcher: An exact count to negate.
/// - Returns: A negated count matcher.
public func not(_ times: Int) -> CountMatcher { return not(exactly(times)) }
