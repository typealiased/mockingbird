import Foundation

/// Types that cannot be stored and referenced later.
protocol NonEscapingType {}

/// Placeholder for non-escaping closure parameter types.
///
/// Non-escaping closures cannot be stored in an `Invocation` so an instance of a
/// `NonEscapingClosure` is stored instead.
///
/// ```swift
/// protocol Bird {
///   func send(_ message: String, callback: (Result) -> Void)
/// }
///
/// bird.send("Hello", callback: { print($0) })
///
/// // Must use a wildcard argument matcher like `any`
/// verify(bird.send("Hello", callback: any())).wasCalled()
/// ```
///
/// Mark closure parameter types as `@escaping` to capture closures during verification.
///
/// ```swift
/// protocol Bird {
///   func send(_ message: String, callback: @escaping (Result) -> Void)
/// }
///
/// bird.send("Hello", callback: { print($0) })
///
/// let argumentCaptor = ArgumentCaptor<(Result) -> Void>()
/// verify(bird.send("Hello", callback: argumentCaptor.matcher)).wasCalled()
/// argumentCaptor.value?(.success)  // Prints Result.success
/// ```
public class NonEscapingClosure<ClosureType>: NonEscapingType {}
