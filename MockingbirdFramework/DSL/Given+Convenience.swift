//
//  Given+Convenience.swift
//  Mockingbird
//
//  Created by Andrew Chang on 8/4/19.
//

import Foundation

/// MARK: - Convenience methods for multi-stubbing

/// Stub a set of mock objects to return a value or perform an operation.
public func given<T, M, I, R>(_ mock0: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock1: @escaping @autoclosure () -> Stubbable<T, M, I, R>) -> Stub<I, R> {
  return Stub<I, R>({ [mock0(), mock1()] })
}

/// Stub a set of mock objects to return a value or perform an operation.
public func given<T, M, I, R>(_ mock0: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock1: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock2: @escaping @autoclosure () -> Stubbable<T, M, I, R>) -> Stub<I, R> {
  return Stub<I, R>({ [mock0(), mock1(), mock2()] })
}

/// Stub a set of mock objects to return a value or perform an operation.
public func given<T, M, I, R>(_ mock0: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock1: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock2: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock3: @escaping @autoclosure () -> Stubbable<T, M, I, R>) -> Stub<I, R> {
  return Stub<I, R>({ [mock0(), mock1(), mock2(), mock3()] })
}

/// Stub a set of mock objects to return a value or perform an operation.
public func given<T, M, I, R>(_ mock0: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock1: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock2: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock3: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock4: @escaping @autoclosure () -> Stubbable<T, M, I, R>) -> Stub<I, R> {
  return Stub<I, R>({ [mock0(), mock1(), mock2(), mock3(), mock4()] })
}

/// Stub a set of mock objects to return a value or perform an operation.
public func given<T, M, I, R>(_ mock0: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock1: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock2: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock3: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock4: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock5: @escaping @autoclosure () -> Stubbable<T, M, I, R>) -> Stub<I, R> {
  return Stub<I, R>({ [mock0(), mock1(), mock2(), mock3(), mock4(), mock5()] })
}

/// Stub a set of mock objects to return a value or perform an operation.
public func given<T, M, I, R>(_ mock0: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock1: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock2: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock3: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock4: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock5: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock6: @escaping @autoclosure () -> Stubbable<T, M, I, R>) -> Stub<I, R> {
  return Stub<I, R>({ [mock0(), mock1(), mock2(), mock3(), mock4(), mock5(), mock6()] })
}

/// Stub a set of mock objects to return a value or perform an operation.
public func given<T, M, I, R>(_ mock0: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock1: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock2: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock3: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock4: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock5: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock6: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock7: @escaping @autoclosure () -> Stubbable<T, M, I, R>) -> Stub<I, R> {
  return Stub<I, R>({ [mock0(), mock1(), mock2(), mock3(), mock4(), mock5(), mock6(), mock7()] })
}

/// Stub a set of mock objects to return a value or perform an operation.
public func given<T, M, I, R>(_ mock0: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock1: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock2: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock3: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock4: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock5: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock6: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock7: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock8: @escaping @autoclosure () -> Stubbable<T, M, I, R>) -> Stub<I, R> {
  return Stub<I, R>({
    [mock0(), mock1(), mock2(), mock3(), mock4(), mock5(), mock6(), mock7(), mock8()]
  })
}

/// Stub a set of mock objects to return a value or perform an operation.
public func given<T, M, I, R>(_ mock0: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock1: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock2: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock3: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock4: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock5: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock6: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock7: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock8: @escaping @autoclosure () -> Stubbable<T, M, I, R>,
                              _ mock9: @escaping @autoclosure () -> Stubbable<T, M, I, R>) -> Stub<I, R> {
  return Stub<I, R>({
    [mock0(), mock1(), mock2(), mock3(), mock4(), mock5(), mock6(), mock7(), mock8(), mock9()]
  })
}
