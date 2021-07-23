//
//  ArgumentIndex.swift
//  MockingbirdFramework
//
//  Created by typealias on 7/21/21.
//

import Foundation

/// Specifies the positional index of an argument matcher for dynamic mocks.
///
/// When using dynamic mocking with wildcard argument matchers, you must provide the argument index
/// if stubbing or verifying a primitive (non-object) parameter type.
///
///     @objc class Bird: NSObject {
///       @objc dynamic func chirp(volume: Int, duration: Int) {}
///     }
///
///     given(bird.chirp(volume: firstArg(any()),
///                      duration: secondArg(any()))).will {
///       print($0 as! Int, $1 as! Int)
///     }
///
///     bird.chirp(42, 9001)  // Prints 42, 9001
///
/// This is equivalent to the verbose form of declaring an argument index.
///
///     given(bird.chirp(volume: arg(any(), at: 0),
///                      duration: arg(any(), at: 1))).will {
///       print($0 as! Int, $1 as! Int)
///     }
///
/// - Note: This helper has no effect on argument matchers passed to statically generated Swift
/// mocks or to object parameter types.
///
/// - Parameters:
///   - matcher: An argument matcher.
///   - index: The position index of the argument in the mocked declaration.
public func arg<T>(_ matcher: @autoclosure () -> T, at index: UInt) -> T {
  if let recorder = InvocationRecorder.sharedRecorder {
    recorder.recordArgumentIndex(index)
  }
  return matcher()
}


// MARK: - Shorthand

/// Specifies the first positional index of an argument matcher for dynamic mocks.
///
/// When using dynamic mocking with wildcard argument matchers, you must provide the argument index
/// if stubbing or verifying a primitive (non-object) parameter type.
///
///     @objc class Bird: NSObject {
///       @objc dynamic func chirp(volume: Int, duration: Int) {}
///     }
///
///     given(bird.chirp(volume: firstArg(any()),
///                      duration: secondArg(any()))).will {
///       print($0 as! Int, $1 as! Int)
///     }
///
///     bird.chirp(42, 9001)  // Prints 42, 9001
///
/// This is equivalent to the verbose form of declaring an argument index.
///
///     given(bird.chirp(volume: arg(any(), at: 0),
///                      duration: arg(any(), at: 1))).will {
///       print($0 as! Int, $1 as! Int)
///     }
///
/// - Note: This helper has no effect on argument matchers passed to statically generated Swift
/// mocks or to object parameter types.
///
/// - Parameters:
///   - matcher: An argument matcher.
public func firstArg<T>(_ matcher: @autoclosure () -> T) -> T {
  return arg(matcher(), at: 0)
}

/// Specifies the second argument positional index of an argument matcher for dynamic mocks.
///
/// When using dynamic mocking with wildcard argument matchers, you must provide the argument index
/// if stubbing or verifying a primitive (non-object) parameter type.
///
///     @objc class Bird: NSObject {
///       @objc dynamic func chirp(volume: Int, duration: Int) {}
///     }
///
///     given(bird.chirp(volume: firstArg(any()),
///                      duration: secondArg(any()))).will {
///       print($0 as! Int, $1 as! Int)
///     }
///
///     bird.chirp(42, 9001)  // Prints 42, 9001
///
/// This is equivalent to the verbose form of declaring an argument index.
///
///     given(bird.chirp(volume: arg(any(), at: 0),
///                      duration: arg(any(), at: 1))).will {
///       print($0 as! Int, $1 as! Int)
///     }
///
/// - Note: This helper has no effect on argument matchers passed to statically generated Swift
/// mocks or to object parameter types.
///
/// - Parameters:
///   - matcher: An argument matcher.
public func secondArg<T>(_ matcher: @autoclosure () -> T) -> T {
  return arg(matcher(), at: 1)
}

/// Specifies the third argument positional index of an argument matcher for dynamic mocks.
///
/// When using dynamic mocking with wildcard argument matchers, you must provide the argument index
/// if stubbing or verifying a primitive (non-object) parameter type.
///
///     @objc class Bird: NSObject {
///       @objc dynamic func chirp(volume: Int, duration: Int) {}
///     }
///
///     given(bird.chirp(volume: firstArg(any()),
///                      duration: secondArg(any()))).will {
///       print($0 as! Int, $1 as! Int)
///     }
///
///     bird.chirp(42, 9001)  // Prints 42, 9001
///
/// This is equivalent to the verbose form of declaring an argument index.
///
///     given(bird.chirp(volume: arg(any(), at: 0),
///                      duration: arg(any(), at: 1))).will {
///       print($0 as! Int, $1 as! Int)
///     }
///
/// - Note: This helper has no effect on argument matchers passed to statically generated Swift
/// mocks or to object parameter types.
///
/// - Parameters:
///   - matcher: An argument matcher.
public func thirdArg<T>(_ matcher: @autoclosure () -> T) -> T {
  return arg(matcher(), at: 2)
}

/// Specifies the fourth argument positional index of an argument matcher for dynamic mocks.
///
/// When using dynamic mocking with wildcard argument matchers, you must provide the argument index
/// if stubbing or verifying a primitive (non-object) parameter type.
///
///     @objc class Bird: NSObject {
///       @objc dynamic func chirp(volume: Int, duration: Int) {}
///     }
///
///     given(bird.chirp(volume: firstArg(any()),
///                      duration: secondArg(any()))).will {
///       print($0 as! Int, $1 as! Int)
///     }
///
///     bird.chirp(42, 9001)  // Prints 42, 9001
///
/// This is equivalent to the verbose form of declaring an argument index.
///
///     given(bird.chirp(volume: arg(any(), at: 0),
///                      duration: arg(any(), at: 1))).will {
///       print($0 as! Int, $1 as! Int)
///     }
///
/// - Note: This helper has no effect on argument matchers passed to statically generated Swift
/// mocks or to object parameter types.
///
/// - Parameters:
///   - matcher: An argument matcher.
public func fourthArg<T>(_ matcher: @autoclosure () -> T) -> T {
  return arg(matcher(), at: 3)
}

/// Specifies the fifth argument positional index of an argument matcher for dynamic mocks.
///
/// When using dynamic mocking with wildcard argument matchers, you must provide the argument index
/// if stubbing or verifying a primitive (non-object) parameter type.
///
///     @objc class Bird: NSObject {
///       @objc dynamic func chirp(volume: Int, duration: Int) {}
///     }
///
///     given(bird.chirp(volume: firstArg(any()),
///                      duration: secondArg(any()))).will {
///       print($0 as! Int, $1 as! Int)
///     }
///
///     bird.chirp(42, 9001)  // Prints 42, 9001
///
/// This is equivalent to the verbose form of declaring an argument index.
///
///     given(bird.chirp(volume: arg(any(), at: 0),
///                      duration: arg(any(), at: 1))).will {
///       print($0 as! Int, $1 as! Int)
///     }
///
/// - Note: This helper has no effect on argument matchers passed to statically generated Swift
/// mocks or to object parameter types.
///
/// - Parameters:
///   - matcher: An argument matcher.
public func fifthArg<T>(_ matcher: @autoclosure () -> T) -> T {
  return arg(matcher(), at: 4)
}
