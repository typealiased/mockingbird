//
//  Verify+Convenience.swift
//  Mockingbird
//
//  Created by Andrew Chang on 8/4/19.
//

import Foundation

/// MARK: - Convenience methods for multi-verification

/// Verify that a set of mocks recieved a specific invocation some number of times.
public func verify<T>(file: StaticString = #file, line: UInt = #line,
                      _ mock0: @escaping @autoclosure () -> Mockable<T>,
                      _ mock1: @escaping @autoclosure () -> Mockable<T>) -> Verification {
  return Verification({ [mock0(), mock1()] }, at: SourceLocation(file, line))
}

/// Verify that a set of mocks recieved a specific invocation some number of times.
public func verify<T>(file: StaticString = #file, line: UInt = #line,
                      _ mock0: @escaping @autoclosure () -> Mockable<T>,
                      _ mock1: @escaping @autoclosure () -> Mockable<T>,
                      _ mock2: @escaping @autoclosure () -> Mockable<T>) -> Verification {
  return Verification({ [mock0(), mock1(), mock2()] }, at: SourceLocation(file, line))
}

/// Verify that a set of mocks recieved a specific invocation some number of times.
public func verify<T>(file: StaticString = #file, line: UInt = #line,
                      _ mock0: @escaping @autoclosure () -> Mockable<T>,
                      _ mock1: @escaping @autoclosure () -> Mockable<T>,
                      _ mock2: @escaping @autoclosure () -> Mockable<T>,
                      _ mock3: @escaping @autoclosure () -> Mockable<T>) -> Verification {
  return Verification({ [mock0(), mock1(), mock2(), mock3()] }, at: SourceLocation(file, line))
}

/// Verify that a set of mocks recieved a specific invocation some number of times.
public func verify<T>(file: StaticString = #file, line: UInt = #line,
                      _ mock0: @escaping @autoclosure () -> Mockable<T>,
                      _ mock1: @escaping @autoclosure () -> Mockable<T>,
                      _ mock2: @escaping @autoclosure () -> Mockable<T>,
                      _ mock3: @escaping @autoclosure () -> Mockable<T>,
                      _ mock4: @escaping @autoclosure () -> Mockable<T>) -> Verification {
  return Verification({
    [mock0(), mock1(), mock2(), mock3(), mock4()]
  }, at: SourceLocation(file, line))
}

/// Verify that a set of mocks recieved a specific invocation some number of times.
public func verify<T>(file: StaticString = #file, line: UInt = #line,
                      _ mock0: @escaping @autoclosure () -> Mockable<T>,
                      _ mock1: @escaping @autoclosure () -> Mockable<T>,
                      _ mock2: @escaping @autoclosure () -> Mockable<T>,
                      _ mock3: @escaping @autoclosure () -> Mockable<T>,
                      _ mock4: @escaping @autoclosure () -> Mockable<T>,
                      _ mock5: @escaping @autoclosure () -> Mockable<T>) -> Verification {
  return Verification({
    [mock0(), mock1(), mock2(), mock3(), mock4(), mock5()]
  }, at: SourceLocation(file, line))
}

/// Verify that a set of mocks recieved a specific invocation some number of times.
public func verify<T>(file: StaticString = #file, line: UInt = #line,
                      _ mock0: @escaping @autoclosure () -> Mockable<T>,
                      _ mock1: @escaping @autoclosure () -> Mockable<T>,
                      _ mock2: @escaping @autoclosure () -> Mockable<T>,
                      _ mock3: @escaping @autoclosure () -> Mockable<T>,
                      _ mock4: @escaping @autoclosure () -> Mockable<T>,
                      _ mock5: @escaping @autoclosure () -> Mockable<T>,
                      _ mock6: @escaping @autoclosure () -> Mockable<T>) -> Verification {
  return Verification({
    [mock0(), mock1(), mock2(), mock3(), mock4(), mock5(), mock6()]
  }, at: SourceLocation(file, line))
}

/// Verify that a set of mocks recieved a specific invocation some number of times.
public func verify<T>(file: StaticString = #file, line: UInt = #line,
                      _ mock0: @escaping @autoclosure () -> Mockable<T>,
                      _ mock1: @escaping @autoclosure () -> Mockable<T>,
                      _ mock2: @escaping @autoclosure () -> Mockable<T>,
                      _ mock3: @escaping @autoclosure () -> Mockable<T>,
                      _ mock4: @escaping @autoclosure () -> Mockable<T>,
                      _ mock5: @escaping @autoclosure () -> Mockable<T>,
                      _ mock6: @escaping @autoclosure () -> Mockable<T>,
                      _ mock7: @escaping @autoclosure () -> Mockable<T>) -> Verification {
  return Verification({
    [mock0(), mock1(), mock2(), mock3(), mock4(), mock5(), mock6(), mock7()]
  }, at: SourceLocation(file, line))
}

/// Verify that a set of mocks recieved a specific invocation some number of times.
public func verify<T>(file: StaticString = #file, line: UInt = #line,
                      _ mock0: @escaping @autoclosure () -> Mockable<T>,
                      _ mock1: @escaping @autoclosure () -> Mockable<T>,
                      _ mock2: @escaping @autoclosure () -> Mockable<T>,
                      _ mock3: @escaping @autoclosure () -> Mockable<T>,
                      _ mock4: @escaping @autoclosure () -> Mockable<T>,
                      _ mock5: @escaping @autoclosure () -> Mockable<T>,
                      _ mock6: @escaping @autoclosure () -> Mockable<T>,
                      _ mock7: @escaping @autoclosure () -> Mockable<T>,
                      _ mock8: @escaping @autoclosure () -> Mockable<T>) -> Verification {
  return Verification({
    [mock0(), mock1(), mock2(), mock3(), mock4(), mock5(), mock6(), mock7(), mock8()]
  }, at: SourceLocation(file, line))
}

/// Verify that a set of mocks recieved a specific invocation some number of times.
public func verify<T>(file: StaticString = #file, line: UInt = #line,
                      _ mock0: @escaping @autoclosure () -> Mockable<T>,
                      _ mock1: @escaping @autoclosure () -> Mockable<T>,
                      _ mock2: @escaping @autoclosure () -> Mockable<T>,
                      _ mock3: @escaping @autoclosure () -> Mockable<T>,
                      _ mock4: @escaping @autoclosure () -> Mockable<T>,
                      _ mock5: @escaping @autoclosure () -> Mockable<T>,
                      _ mock6: @escaping @autoclosure () -> Mockable<T>,
                      _ mock7: @escaping @autoclosure () -> Mockable<T>,
                      _ mock8: @escaping @autoclosure () -> Mockable<T>,
                      _ mock9: @escaping @autoclosure () -> Mockable<T>) -> Verification {
  return Verification({
    [mock0(), mock1(), mock2(), mock3(), mock4(), mock5(), mock6(), mock7(), mock8(), mock9()]
  }, at: SourceLocation(file, line))
}
