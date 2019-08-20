//
//  Given+Convenience.swift
//  Mockingbird
//
//  Created by Andrew Chang on 8/4/19.
//

import Foundation

/// MARK: - Convenience methods for multi-stubbing

public func given<T>(_ mock0: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock1: @escaping @autoclosure () -> Stubbable<T>) -> Stub<T> {
  return Stub<T>({ [mock0(), mock1()] })
}

public func given<T>(_ mock0: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock1: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock2: @escaping @autoclosure () -> Stubbable<T>) -> Stub<T> {
  return Stub<T>({ [mock0(), mock1(), mock2()] })
}

public func given<T>(_ mock0: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock1: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock2: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock3: @escaping @autoclosure () -> Stubbable<T>) -> Stub<T> {
  return Stub<T>({ [mock0(), mock1(), mock2(), mock3()] })
}

public func given<T>(_ mock0: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock1: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock2: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock3: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock4: @escaping @autoclosure () -> Stubbable<T>) -> Stub<T> {
  return Stub<T>({ [mock0(), mock1(), mock2(), mock3(), mock4()] })
}

public func given<T>(_ mock0: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock1: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock2: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock3: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock4: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock5: @escaping @autoclosure () -> Stubbable<T>) -> Stub<T> {
  return Stub<T>({ [mock0(), mock1(), mock2(), mock3(), mock4(), mock5()] })
}

public func given<T>(_ mock0: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock1: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock2: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock3: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock4: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock5: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock6: @escaping @autoclosure () -> Stubbable<T>) -> Stub<T> {
  return Stub<T>({ [mock0(), mock1(), mock2(), mock3(), mock4(), mock5(), mock6()] })
}

public func given<T>(_ mock0: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock1: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock2: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock3: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock4: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock5: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock6: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock7: @escaping @autoclosure () -> Stubbable<T>) -> Stub<T> {
  return Stub<T>({ [mock0(), mock1(), mock2(), mock3(), mock4(), mock5(), mock6(), mock7()] })
}

public func given<T>(_ mock0: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock1: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock2: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock3: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock4: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock5: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock6: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock7: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock8: @escaping @autoclosure () -> Stubbable<T>) -> Stub<T> {
  return Stub<T>({
    [mock0(), mock1(), mock2(), mock3(), mock4(), mock5(), mock6(), mock7(), mock8()]
  })
}

public func given<T>(_ mock0: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock1: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock2: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock3: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock4: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock5: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock6: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock7: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock8: @escaping @autoclosure () -> Stubbable<T>,
                    _ mock9: @escaping @autoclosure () -> Stubbable<T>) -> Stub<T> {
  return Stub<T>({
    [mock0(), mock1(), mock2(), mock3(), mock4(), mock5(), mock6(), mock7(), mock8(), mock9()]
  })
}
