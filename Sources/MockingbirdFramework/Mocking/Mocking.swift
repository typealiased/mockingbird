//
//  Mocking.swift
//  Mockingbird
//
//  Created by Andrew Chang on 7/29/19.
//

import Foundation

/// Returns a mock of a given Swift type.
///
/// Initialized mocks can be passed in place of the original type. Protocol mocks do not require
/// explicit initialization while class mocks should be created using `initialize(…)`.
///
///     protocol Bird {
///       init(name: String)
///     }
///     class Tree {
///       init(with bird: Bird) {}
///     }
///
///     let bird = mock(Bird.self)  // Protocol mock
///     let tree = mock(Tree.self).initialize(with: bird)  // Class mock
///
/// Generated mock types are suffixed with `Mock` and should not be coerced into their supertype.
///
///     let bird: BirdMock = mock(Bird.self)  // The concrete type is `BirdMock`
///     let inferredBird = mock(Bird.self)    // Type inference also works
///     let coerced: Bird = mock(Bird.self)   // Avoid upcasting mocks
///
/// - Parameter type: The type to mock.
@available(*, unavailable, message: "No generated mock for this type which might be resolved by building the test target (⇧⌘U)")
public func mock<T>(_ type: T.Type) -> T { fatalError() }

/// Returns a dynamic mock of a given Objective-C object type.
///
/// Initialized mocks can be passed in place of the original type. Dynamic mocks use the
/// Objective-C runtime and do not require explicit initialization like Swift class mocks.
///
///     // Objective-C declarations
///     @protocol Bird <NSObject>
///     - (instancetype)initWithName:(NSString *);
///     @end
///     @interface Tree : NSObject
///     - (instancetype)initWithHeight:(NSInteger)height;
///     @end
///
///     let bird = mock(Bird.self)  // Protocol mock
///     let tree = mock(Tree.self)  // Class mock
///
/// It's also possible to mock Swift types inheriting from `NSObject` or conforming to
/// `NSObjectProtocol`. Members must be dynamically dispatched and available to the Objective-C
/// runtime by specifying the `objc` attribute and `dynamic` modifier.
///
///     @objc protocol Bird: NSObjectProtocol {
///       @objc dynamic func chirp()
///       @objc dynamic var name: String { get }
///     }
///     @objc class Tree: NSObject {
///       @objc dynamic func shake() {}
///       @objc dynamic var height: Int
///     }
///
/// - Parameter type: The type to mock.
public func mock<T: NSObjectProtocol>(_ type: T.Type) -> T {
  return MKBTypeFacade.create(from: MKBMock(type))
}

/// Remove all recorded invocations and configured stubs.
///
/// Fully reset a set of mocks during test runs by removing all recorded invocations and clearing
/// all configurations.
///
///     let bird = mock(Bird.self)
///     given(bird.name).willReturn("Ryan")
///
///     print(bird.name)  // Prints "Ryan"
///     verify(bird.name).wasCalled()  // Passes
///
///     reset(bird)
///
///     print(bird.name)  // Error: Missing stubbed implementation
///     verify(bird.name).wasCalled()  // Error: Got 0 invocations
///
/// - Parameter mocks: A set of mocks to reset.
public func reset(_ mocks: Mock...) {
  mocks.forEach({ mock in
    clearInvocations(on: mock)
    clearStubs(on: mock)
  })
}

/// Remove all recorded invocations and configured stubs.
///
/// Fully reset a set of mocks during test runs by removing all recorded invocations and clearing
/// all configurations.
///
///     let bird = mock(Bird.self)
///     given(bird.name).willReturn("Ryan")
///
///     print(bird.name)  // Prints "Ryan"
///     verify(bird.name).wasCalled()  // Passes
///
///     reset(bird)
///
///     print(bird.name)  // Error: Missing stubbed implementation
///     verify(bird.name).wasCalled()  // Error: Got 0 invocations
///
/// - Parameter mocks: A set of mocks to reset.
public func reset(_ mocks: NSObjectProtocol...) {
  mocks.forEach({ mock in
    clearInvocations(on: mock)
    clearStubs(on: mock)
  })
}

/// Remove all recorded invocations.
///
/// Partially reset a set of mocks during test runs by removing all recorded invocations.
///
///     let bird = mock(Bird.self)
///     given(bird.name).willReturn("Ryan")
///
///     print(bird.name)  // Prints "Ryan"
///     verify(bird.name).wasCalled()  // Passes
///
///     clearInvocations(on: bird)
///
///     print(bird.name)  // Prints "Ryan"
///     verify(bird.name).wasCalled()  // Error: Got 0 invocations
///
/// - Parameter mocks: A set of mocks to reset.
public func clearInvocations(on mocks: Mock...) {
  mocks.forEach({ $0.mockingbirdContext.mocking.clearInvocations() })
}

/// Remove all recorded invocations.
///
/// Partially reset a set of mocks during test runs by removing all recorded invocations.
///
///     let bird = mock(Bird.self)
///     given(bird.name).willReturn("Ryan")
///
///     print(bird.name)  // Prints "Ryan"
///     verify(bird.name).wasCalled()  // Passes
///
///     clearInvocations(on: bird)
///
///     print(bird.name)  // Prints "Ryan"
///     verify(bird.name).wasCalled()  // Error: Got 0 invocations
///
/// - Parameter mocks: A set of mocks to reset.
public func clearInvocations(on mocks: NSObjectProtocol...) {
  mocks.forEach({ mock in
    guard let context = mock.mockingbirdContext else { return }
    context.mocking.clearInvocations()
  })
}

/// Remove all concrete stubs.
///
/// Partially reset a set of mocks during test runs by removing all stubs.
///
///     let bird = mock(Bird.self)
///     given(bird.name).willReturn("Ryan")
///
///     print(bird.name)  // Prints "Ryan"
///     verify(bird.name).wasCalled()  // Passes
///
///     clearStubs(on: bird)
///
///     print(bird.name)  // Error: Missing stubbed implementation
///
/// - Parameter mocks: A set of mocks to reset.
public func clearStubs(on mocks: Mock...) {
  mocks.forEach({
    let context = $0.mockingbirdContext
    context.stubbing.clearStubs()
    context.stubbing.defaultValueProvider.update { $0.reset() }
    context.proxy.clearTargets()
  })
}

/// Remove all concrete stubs.
///
/// Partially reset a set of mocks during test runs by removing all stubs.
///
///     let bird = mock(Bird.self)
///     given(bird.name).willReturn("Ryan")
///
///     print(bird.name)  // Prints "Ryan"
///     verify(bird.name).wasCalled()  // Passes
///
///     clearStubs(on: bird)
///
///     print(bird.name)  // Error: Missing stubbed implementation
///
/// - Parameter mocks: A set of mocks to reset.
public func clearStubs(on mocks: NSObjectProtocol...) {
  mocks.forEach({ mock in
    guard let context = mock.mockingbirdContext else { return }
    context.stubbing.clearStubs()
    context.stubbing.defaultValueProvider.update { $0.reset() }
    context.proxy.clearTargets()
  })
}

/// Remove all registered default values.
///
/// Partially reset a set of mocks during test runs by removing all registered default values.
///
///     let bird = mock(Bird.self)
///     bird.useDefaultValues(from: .standardProvider)
///
///     print(bird.name)  // Prints ""
///     verify(bird.name).wasCalled()  // Passes
///
///     clearDefaultValues(on: bird)
///
///     print(bird.name)  // Error: Missing stubbed implementation
///
/// - Parameter mocks: A set of mocks to reset.
@available(*, deprecated, renamed: "clearStubs")
public func clearDefaultValues(on mocks: Mock...) {
  mocks.forEach({
    $0.mockingbirdContext.stubbing.defaultValueProvider.update { $0.reset() }
  })
}
