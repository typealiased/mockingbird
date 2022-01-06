import Foundation

/// Specifies the argument position for an argument matcher.
///
/// You must provide an explicit argument position when using argument matchers on an Objective-C
/// method with multiple value type parameters.
///
/// ```swift
/// @objc class Bird: NSObject {
///   @objc dynamic func chirp(volume: Int, duration: Int) {}
/// }
///
/// given(bird.chirp(volume: arg(any(), at: 0),
///                  duration: arg(any(), at: 1))).will {
///   print($0 as! Int, $1 as! Int)
/// }
///
/// bird.chirp(42, 9001)  // Prints 42, 9001
/// ```
///
/// This is equivalent to the verbose form of declaring an argument position.
///
/// ```swift
/// given(bird.chirp(volume: firstArg(any()),
///                  duration: secondArg(any()))).will {
///   print($0 as! Int, $1 as! Int)
/// }
/// ```
///
/// - Note: This helper has no effect on argument matchers passed to statically generated Swift
/// mocks or to object parameter types.
///
/// - Parameters:
///   - matcher: An argument matcher.
///   - position: The position of the argument in the mocked declaration.
public func arg<T>(_ matcher: @autoclosure () -> T, at position: Int) -> T {
  precondition(position > 0, "Argument positions must be a positive integer")
  if let recorder = InvocationRecorder.sharedRecorder {
    recorder.recordArgumentIndex(position-1)
  }
  return matcher()
}


// MARK: - Shorthand

/// Specifies the first argument position for an argument matcher.
///
/// You must provide an explicit argument position when using argument matchers on an Objective-C
/// method with multiple value type parameters.
///
/// ```swift
/// @objc class Bird: NSObject {
///   @objc dynamic func chirp(volume: Int, duration: Int) {}
/// }
///
/// given(bird.chirp(volume: firstArg(any()),
///                  duration: secondArg(any()))).will {
///   print($0 as! Int, $1 as! Int)
/// }
///
/// bird.chirp(42, 9001)  // Prints 42, 9001
/// ```
///
/// This is equivalent to the verbose form of declaring an argument position.
///
/// ```swift
/// given(bird.chirp(volume: arg(any(), at: 0),
///                  duration: arg(any(), at: 1))).will {
///   print($0 as! Int, $1 as! Int)
/// }
/// ```
///
/// - Note: This helper has no effect on argument matchers passed to statically generated Swift
/// mocks or to object parameter types.
///
/// - Parameters:
///   - matcher: An argument matcher.
public func firstArg<T>(_ matcher: @autoclosure () -> T) -> T {
  return arg(matcher(), at: 1)
}

/// Specifies the second argument position for an argument matcher.
///
/// You must provide an explicit argument position when using argument matchers on an Objective-C
/// method with multiple value type parameters.
///
/// ```swift
/// @objc class Bird: NSObject {
///   @objc dynamic func chirp(volume: Int, duration: Int) {}
/// }
///
/// given(bird.chirp(volume: firstArg(any()),
///                  duration: secondArg(any()))).will {
///   print($0 as! Int, $1 as! Int)
/// }
///
/// bird.chirp(42, 9001)  // Prints 42, 9001
/// ```
///
/// This is equivalent to the verbose form of declaring an argument position.
///
/// ```swift
/// given(bird.chirp(volume: arg(any(), at: 0),
///                  duration: arg(any(), at: 1))).will {
///   print($0 as! Int, $1 as! Int)
/// }
/// ```
///
/// - Note: This helper has no effect on argument matchers passed to statically generated Swift
/// mocks or to object parameter types.
///
/// - Parameters:
///   - matcher: An argument matcher.
public func secondArg<T>(_ matcher: @autoclosure () -> T) -> T {
  return arg(matcher(), at: 2)
}

/// Specifies the third argument position for an argument matcher.
///
/// You must provide an explicit argument position when using argument matchers on an Objective-C
/// method with multiple value type parameters.
///
/// ```swift
/// @objc class Bird: NSObject {
///   @objc dynamic func chirp(volume: Int, duration: Int) {}
/// }
///
/// given(bird.chirp(volume: firstArg(any()),
///                  duration: secondArg(any()))).will {
///   print($0 as! Int, $1 as! Int)
/// }
///
/// bird.chirp(42, 9001)  // Prints 42, 9001
/// ```
///
/// This is equivalent to the verbose form of declaring an argument position.
///
/// ```swift
/// given(bird.chirp(volume: arg(any(), at: 0),
///                  duration: arg(any(), at: 1))).will {
///   print($0 as! Int, $1 as! Int)
/// }
/// ```
///
/// - Note: This helper has no effect on argument matchers passed to statically generated Swift
/// mocks or to object parameter types.
///
/// - Parameters:
///   - matcher: An argument matcher.
public func thirdArg<T>(_ matcher: @autoclosure () -> T) -> T {
  return arg(matcher(), at: 3)
}

/// Specifies the fourth argument position for an argument matcher.
///
/// You must provide an explicit argument position when using argument matchers on an Objective-C
/// method with multiple value type parameters.
///
/// ```swift
/// @objc class Bird: NSObject {
///   @objc dynamic func chirp(volume: Int, duration: Int) {}
/// }
///
/// given(bird.chirp(volume: firstArg(any()),
///                  duration: secondArg(any()))).will {
///   print($0 as! Int, $1 as! Int)
/// }
///
/// bird.chirp(42, 9001)  // Prints 42, 9001
/// ```
///
/// This is equivalent to the verbose form of declaring an argument position.
///
/// ```swift
/// given(bird.chirp(volume: arg(any(), at: 0),
///                  duration: arg(any(), at: 1))).will {
///   print($0 as! Int, $1 as! Int)
/// }
/// ```
///
/// - Note: This helper has no effect on argument matchers passed to statically generated Swift
/// mocks or to object parameter types.
///
/// - Parameters:
///   - matcher: An argument matcher.
public func fourthArg<T>(_ matcher: @autoclosure () -> T) -> T {
  return arg(matcher(), at: 4)
}

/// Specifies the fifth argument position for an argument matcher.
///
/// You must provide an explicit argument position when using argument matchers on an Objective-C
/// method with multiple value type parameters.
///
/// ```swift
/// @objc class Bird: NSObject {
///   @objc dynamic func chirp(volume: Int, duration: Int) {}
/// }
///
/// given(bird.chirp(volume: firstArg(any()),
///                  duration: secondArg(any()))).will {
///   print($0 as! Int, $1 as! Int)
/// }
///
/// bird.chirp(42, 9001)  // Prints 42, 9001
/// ```
///
/// This is equivalent to the verbose form of declaring an argument position.
///
/// ```swift
/// given(bird.chirp(volume: arg(any(), at: 0),
///                  duration: arg(any(), at: 1))).will {
///   print($0 as! Int, $1 as! Int)
/// }
/// ```
///
/// - Note: This helper has no effect on argument matchers passed to statically generated Swift
/// mocks or to object parameter types.
///
/// - Parameters:
///   - matcher: An argument matcher.
public func fifthArg<T>(_ matcher: @autoclosure () -> T) -> T {
  return arg(matcher(), at: 5)
}
