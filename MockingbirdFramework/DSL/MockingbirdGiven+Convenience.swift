//
//  MockingbirdWhen+Convenience.swift
//  Mockingbird
//
//  Created by Andrew Chang on 8/4/19.
//

import Foundation

/// MARK: - Convenience methods for multi-stubbing

public func given<T>(_ scope0: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope1: @escaping @autoclosure () -> MockingbirdScopedStub<T>) -> MockingbirdStubbingScope<T> {
  return MockingbirdStubbingScope<T>({ [scope0(), scope1()] })
}

public func given<T>(_ scope0: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope1: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope2: @escaping @autoclosure () -> MockingbirdScopedStub<T>) -> MockingbirdStubbingScope<T> {
  return MockingbirdStubbingScope<T>({ [scope0(), scope1(), scope2()] })
}

public func given<T>(_ scope0: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope1: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope2: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope3: @escaping @autoclosure () -> MockingbirdScopedStub<T>) -> MockingbirdStubbingScope<T> {
  return MockingbirdStubbingScope<T>({ [scope0(), scope1(), scope2(), scope3()] })
}

public func given<T>(_ scope0: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope1: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope2: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope3: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope4: @escaping @autoclosure () -> MockingbirdScopedStub<T>) -> MockingbirdStubbingScope<T> {
  return MockingbirdStubbingScope<T>({ [scope0(), scope1(), scope2(), scope3(), scope4()] })
}

public func given<T>(_ scope0: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope1: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope2: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope3: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope4: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope5: @escaping @autoclosure () -> MockingbirdScopedStub<T>) -> MockingbirdStubbingScope<T> {
  return MockingbirdStubbingScope<T>({ [scope0(), scope1(), scope2(), scope3(), scope4(), scope5()] })
}

public func given<T>(_ scope0: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope1: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope2: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope3: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope4: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope5: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope6: @escaping @autoclosure () -> MockingbirdScopedStub<T>) -> MockingbirdStubbingScope<T> {
  return MockingbirdStubbingScope<T>({ [scope0(), scope1(), scope2(), scope3(), scope4(), scope5(), scope6()] })
}

public func given<T>(_ scope0: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope1: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope2: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope3: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope4: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope5: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope6: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope7: @escaping @autoclosure () -> MockingbirdScopedStub<T>) -> MockingbirdStubbingScope<T> {
  return MockingbirdStubbingScope<T>({
    [scope0(), scope1(), scope2(), scope3(), scope4(), scope5(), scope6(), scope7()]
  })
}

public func given<T>(_ scope0: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope1: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope2: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope3: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope4: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope5: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope6: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope7: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope8: @escaping @autoclosure () -> MockingbirdScopedStub<T>) -> MockingbirdStubbingScope<T> {
  return MockingbirdStubbingScope<T>({
    [scope0(), scope1(), scope2(), scope3(), scope4(), scope5(), scope6(), scope7(), scope8()]
  })
}

public func given<T>(_ scope0: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope1: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope2: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope3: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope4: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope5: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope6: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope7: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope8: @escaping @autoclosure () -> MockingbirdScopedStub<T>,
                    _ scope9: @escaping @autoclosure () -> MockingbirdScopedStub<T>) -> MockingbirdStubbingScope<T> {
  return MockingbirdStubbingScope<T>({
    [scope0(), scope1(), scope2(), scope3(), scope4(), scope5(), scope6(), scope7(), scope8(), scope9()]
  })
}
