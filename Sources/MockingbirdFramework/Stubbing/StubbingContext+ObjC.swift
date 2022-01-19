import Foundation

/// Used to forward errors thrown from stubbed implementations to the Objective-C runtime.
@objc(MKBErrorBox) public class ErrorBox: NSObject {
  // There's some weird bridging errors with Swift errors, so ErrorBox is just an abstract class
  // that the Obj-C runtime can (responsibly) pull errors from using `performSelector:`.
}

/// Holds Swift errors which are bridged to `NSErrors`.
@objc(MKBSwiftErrorBox) public class SwiftErrorBox: ErrorBox {
  @objc public let error: Error
  init(_ error: Error) {
    self.error = error
  }
}

/// Holds Objective-C `NSError` objects.
@objc(MKBObjCErrorBox) public class ObjCErrorBox: ErrorBox {
  @objc public let error: NSError?
  init(_ error: NSError) {
    self.error = error
  }
}

/// Represents `nil` return values to prevent Swift from implicitly bridging to `NSNull`.
@objc(MKBNilValue) public class NilValue: NSObject {}

extension StubbingContext {
  /// Used to indicate that no implementation exists for a given invocation.
  @objc public static let noImplementation = NSObject()
  
  /// Apply arguments to a Swift implementation forwarded by the Objective-C runtime.
  ///
  /// Invocations with more than 10 arguments will throw a missing stubbed implementation error.
  ///
  /// - Parameter invocation: An Objective-C invocation to handle.
  /// - Returns: The value returned from evaluating the Swift implementation.
  @objc public func evaluateReturnValue(for invocation: ObjCInvocation) -> Any? {
    let impl = implementation(for: invocation as Invocation)
    do {
      let value = try applyInvocation(invocation, to: impl)
        ?? applyThrowingInvocation(invocation, to: impl)
        ?? Self.noImplementation
      // It's possible to stub `NSNull` as a return value, so we need to check that this is an
      // actual nil Swift value before creating a `NilValue` representation for Obj-C.
      if !(value is NSNull) && (value as? Nullable)?.isNil ?? false {
        return NilValue()
      } else {
        return value
      }
    } catch let err as NSError {
      return ObjCErrorBox(err)
    } catch let err {
      return SwiftErrorBox(err)
    }
  }
  
  /// Attempts to return a value using the default value provider.
  ///
  /// - Parameter invocation: An Objective-C invocation to handle.
  /// - Returns: A value or `nil` if the provider could not handle the Objective-C return type.
  @objc public func provideDefaultValue(for invocation: ObjCInvocation) -> Any? {
    return defaultValueProvider.read({ $0.provideValue(for: invocation.objcReturnType) })
  }
  
  private func applyInvocation(_ invocation: ObjCInvocation, to implementation: Any?) -> Any? {
    if let concreteImplementation = implementation
                as? () -> Any {
      return concreteImplementation()
    } else if let concreteImplementation = implementation
                as? (Any?) -> Any {
      return concreteImplementation(invocation.arguments.get(0)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?) -> Any {
      return concreteImplementation(invocation.arguments.get(0)?.base,
                                    invocation.arguments.get(1)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?, Any?) -> Any {
      return concreteImplementation(invocation.arguments.get(0)?.base,
                                    invocation.arguments.get(1)?.base,
                                    invocation.arguments.get(2)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?, Any?, Any?) -> Any {
      return concreteImplementation(invocation.arguments.get(0)?.base,
                                    invocation.arguments.get(1)?.base,
                                    invocation.arguments.get(2)?.base,
                                    invocation.arguments.get(3)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?, Any?, Any?, Any?) -> Any {
      return concreteImplementation(invocation.arguments.get(0)?.base,
                                    invocation.arguments.get(1)?.base,
                                    invocation.arguments.get(2)?.base,
                                    invocation.arguments.get(3)?.base,
                                    invocation.arguments.get(4)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?, Any?, Any?, Any?, Any?) -> Any {
      return concreteImplementation(invocation.arguments.get(0)?.base,
                                    invocation.arguments.get(1)?.base,
                                    invocation.arguments.get(2)?.base,
                                    invocation.arguments.get(3)?.base,
                                    invocation.arguments.get(4)?.base,
                                    invocation.arguments.get(5)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?, Any?, Any?, Any?, Any?, Any?) -> Any {
      return concreteImplementation(invocation.arguments.get(0)?.base,
                                    invocation.arguments.get(1)?.base,
                                    invocation.arguments.get(2)?.base,
                                    invocation.arguments.get(3)?.base,
                                    invocation.arguments.get(4)?.base,
                                    invocation.arguments.get(5)?.base,
                                    invocation.arguments.get(6)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?) -> Any {
      return concreteImplementation(invocation.arguments.get(0)?.base,
                                    invocation.arguments.get(1)?.base,
                                    invocation.arguments.get(2)?.base,
                                    invocation.arguments.get(3)?.base,
                                    invocation.arguments.get(4)?.base,
                                    invocation.arguments.get(5)?.base,
                                    invocation.arguments.get(6)?.base,
                                    invocation.arguments.get(7)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?) -> Any {
      return concreteImplementation(invocation.arguments.get(0)?.base,
                                    invocation.arguments.get(1)?.base,
                                    invocation.arguments.get(2)?.base,
                                    invocation.arguments.get(3)?.base,
                                    invocation.arguments.get(4)?.base,
                                    invocation.arguments.get(5)?.base,
                                    invocation.arguments.get(6)?.base,
                                    invocation.arguments.get(7)?.base,
                                    invocation.arguments.get(8)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?) -> Any {
      return concreteImplementation(invocation.arguments.get(0)?.base,
                                    invocation.arguments.get(1)?.base,
                                    invocation.arguments.get(2)?.base,
                                    invocation.arguments.get(3)?.base,
                                    invocation.arguments.get(4)?.base,
                                    invocation.arguments.get(5)?.base,
                                    invocation.arguments.get(6)?.base,
                                    invocation.arguments.get(7)?.base,
                                    invocation.arguments.get(8)?.base,
                                    invocation.arguments.get(9)?.base)
    }
    return nil
  }
  
  private func applyThrowingInvocation(_ invocation: ObjCInvocation,
                                       to implementation: Any?) throws -> Any? {
    if let concreteImplementation = implementation
                as? () throws -> Any {
      return try concreteImplementation()
    } else if let concreteImplementation = implementation
                as? (Any?) throws -> Any {
      return try concreteImplementation(invocation.arguments.get(0)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?) throws -> Any {
      return try concreteImplementation(invocation.arguments.get(0)?.base,
                                        invocation.arguments.get(1)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?, Any?) throws -> Any {
      return try concreteImplementation(invocation.arguments.get(0)?.base,
                                        invocation.arguments.get(1)?.base,
                                        invocation.arguments.get(2)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?, Any?, Any?) throws -> Any {
      return try concreteImplementation(invocation.arguments.get(0)?.base,
                                        invocation.arguments.get(1)?.base,
                                        invocation.arguments.get(2)?.base,
                                        invocation.arguments.get(3)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?, Any?, Any?, Any?) throws -> Any {
      return try concreteImplementation(invocation.arguments.get(0)?.base,
                                        invocation.arguments.get(1)?.base,
                                        invocation.arguments.get(2)?.base,
                                        invocation.arguments.get(3)?.base,
                                        invocation.arguments.get(4)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?, Any?, Any?, Any?, Any?) throws -> Any {
      return try concreteImplementation(invocation.arguments.get(0)?.base,
                                        invocation.arguments.get(1)?.base,
                                        invocation.arguments.get(2)?.base,
                                        invocation.arguments.get(3)?.base,
                                        invocation.arguments.get(4)?.base,
                                        invocation.arguments.get(5)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?, Any?, Any?, Any?, Any?, Any?) throws -> Any {
      return try concreteImplementation(invocation.arguments.get(0)?.base,
                                        invocation.arguments.get(1)?.base,
                                        invocation.arguments.get(2)?.base,
                                        invocation.arguments.get(3)?.base,
                                        invocation.arguments.get(4)?.base,
                                        invocation.arguments.get(5)?.base,
                                        invocation.arguments.get(6)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?) throws -> Any {
      return try concreteImplementation(invocation.arguments.get(0)?.base,
                                        invocation.arguments.get(1)?.base,
                                        invocation.arguments.get(2)?.base,
                                        invocation.arguments.get(3)?.base,
                                        invocation.arguments.get(4)?.base,
                                        invocation.arguments.get(5)?.base,
                                        invocation.arguments.get(6)?.base,
                                        invocation.arguments.get(7)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?) throws -> Any {
      return try concreteImplementation(invocation.arguments.get(0)?.base,
                                        invocation.arguments.get(1)?.base,
                                        invocation.arguments.get(2)?.base,
                                        invocation.arguments.get(3)?.base,
                                        invocation.arguments.get(4)?.base,
                                        invocation.arguments.get(5)?.base,
                                        invocation.arguments.get(6)?.base,
                                        invocation.arguments.get(7)?.base,
                                        invocation.arguments.get(8)?.base)
    } else if let concreteImplementation = implementation
                as? (Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?, Any?) throws -> Any {
      return try concreteImplementation(invocation.arguments.get(0)?.base,
                                        invocation.arguments.get(1)?.base,
                                        invocation.arguments.get(2)?.base,
                                        invocation.arguments.get(3)?.base,
                                        invocation.arguments.get(4)?.base,
                                        invocation.arguments.get(5)?.base,
                                        invocation.arguments.get(6)?.base,
                                        invocation.arguments.get(7)?.base,
                                        invocation.arguments.get(8)?.base,
                                        invocation.arguments.get(9)?.base)
    }
    return nil
  }
}
