//
//  MockingbirdVerify+Convenience.swift
//  Mockingbird
//
//  Created by Andrew Chang on 8/4/19.
//

import Foundation

/// MARK: - Convenience methods for multi-verification

public func verify(file: StaticString = #file, line: UInt = #line,
                   _ scope0: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope1: @escaping @autoclosure () -> MockingbirdScopedMock) -> MockingbirdVerificationScope {
  return MockingbirdVerificationScope({
    [scope0(), scope1()]
  }, at: MockingbirdSourceLocation(file, line))
}

public func verify(file: StaticString = #file, line: UInt = #line,
                   _ scope0: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope1: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope2: @escaping @autoclosure () -> MockingbirdScopedMock) -> MockingbirdVerificationScope {
  return MockingbirdVerificationScope({
    [scope0(), scope1(), scope2()]
  }, at: MockingbirdSourceLocation(file, line))
}

public func verify(file: StaticString = #file, line: UInt = #line,
                   _ scope0: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope1: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope2: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope3: @escaping @autoclosure () -> MockingbirdScopedMock) -> MockingbirdVerificationScope {
  return MockingbirdVerificationScope({
    [scope0(), scope1(), scope2(), scope3()]
  }, at: MockingbirdSourceLocation(file, line))
}

public func verify(file: StaticString = #file, line: UInt = #line,
                   _ scope0: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope1: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope2: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope3: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope4: @escaping @autoclosure () -> MockingbirdScopedMock) -> MockingbirdVerificationScope {
  return MockingbirdVerificationScope({
    [scope0(), scope1(), scope2(), scope3(), scope4()]
  }, at: MockingbirdSourceLocation(file, line))
}

public func verify(file: StaticString = #file, line: UInt = #line,
                   _ scope0: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope1: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope2: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope3: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope4: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope5: @escaping @autoclosure () -> MockingbirdScopedMock) -> MockingbirdVerificationScope {
  return MockingbirdVerificationScope({
    [scope0(), scope1(), scope2(), scope3(), scope4(), scope5()]
  }, at: MockingbirdSourceLocation(file, line))
}

public func verify(file: StaticString = #file, line: UInt = #line,
                   _ scope0: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope1: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope2: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope3: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope4: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope5: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope6: @escaping @autoclosure () -> MockingbirdScopedMock) -> MockingbirdVerificationScope {
  return MockingbirdVerificationScope({
    [scope0(), scope1(), scope2(), scope3(), scope4(), scope5(), scope6()]
  }, at: MockingbirdSourceLocation(file, line))
}

public func verify(file: StaticString = #file, line: UInt = #line,
                   _ scope0: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope1: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope2: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope3: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope4: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope5: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope6: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope7: @escaping @autoclosure () -> MockingbirdScopedMock) -> MockingbirdVerificationScope {
  return MockingbirdVerificationScope({
    [scope0(), scope1(), scope2(), scope3(), scope4(), scope5(), scope6(), scope7()]
  }, at: MockingbirdSourceLocation(file, line))
}

public func verify(file: StaticString = #file, line: UInt = #line,
                   _ scope0: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope1: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope2: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope3: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope4: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope5: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope6: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope7: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope8: @escaping @autoclosure () -> MockingbirdScopedMock) -> MockingbirdVerificationScope {
  return MockingbirdVerificationScope({
    [scope0(), scope1(), scope2(), scope3(), scope4(), scope5(), scope6(), scope7(), scope8()]
  }, at: MockingbirdSourceLocation(file, line))
}

public func verify(file: StaticString = #file, line: UInt = #line,
                   _ scope0: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope1: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope2: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope3: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope4: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope5: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope6: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope7: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope8: @escaping @autoclosure () -> MockingbirdScopedMock,
                   _ scope9: @escaping @autoclosure () -> MockingbirdScopedMock) -> MockingbirdVerificationScope {
  return MockingbirdVerificationScope({
    [scope0(), scope1(), scope2(), scope3(), scope4(), scope5(), scope6(), scope7(), scope8(), scope9()]
  }, at: MockingbirdSourceLocation(file, line))
}
