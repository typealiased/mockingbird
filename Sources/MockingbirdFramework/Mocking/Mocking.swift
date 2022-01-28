import Foundation

/// Fallback for types without a generated mock.
///
/// Each generated mock defines a specialized version of `mock`, and the absence of a mocked type is
/// detected at compile time with this overload. In most cases, generating mocks for the current
/// test target will fix the issue. Otherwise, please consult the troubleshooting guide for
/// additional solutions: https://mockingbirdswift.com/common-problems
@available(*, unavailable,
           message: "No generated mock for this type; try building the test target (⇧⌘U) to generate mocks")
public func mock<T>(_ type: T.Type) -> T {
  fatalError()
}

/// Returns a dynamic mock of a given Objective-C object type.
///
/// Initialized mocks can be passed in place of the original type. Dynamic mocks use the
/// Objective-C runtime and do not require explicit initialization like Swift class mocks.
///
/// ```swift
/// // Objective-C declarations
/// @protocol Bird <NSObject>
/// - (instancetype)initWithName:(NSString *);
/// @end
/// @interface Tree : NSObject
/// - (instancetype)initWithHeight:(NSInteger)height;
/// @end
///
/// let bird = mock(Bird.self)  // Protocol mock
/// let tree = mock(Tree.self)  // Class mock
/// ```
///
/// It's also possible to mock Swift types inheriting from `NSObject` or conforming to
/// `NSObjectProtocol`. Members must be dynamically dispatched and available to the Objective-C
/// runtime by specifying the `objc` attribute and `dynamic` modifier.
///
/// ```swift
/// @objc protocol Bird: NSObjectProtocol {
///   @objc dynamic func chirp()
///   @objc dynamic var name: String { get }
/// }
/// @objc class Tree: NSObject {
///   @objc dynamic func shake() {}
///   @objc dynamic var height: Int
/// }
/// ```
///
/// - Parameter type: The type to mock.
@_disfavoredOverload
public func mock<T: NSObjectProtocol>(_ type: T.Type) -> T {
  return MKBTypeFacade.create(from: MKBMock(type))
}

/// Remove all recorded invocations and configured stubs.
///
/// Fully reset a set of mocks during test runs by removing all recorded invocations and clearing
/// all configurations.
///
/// ```swift
/// let bird = mock(Bird.self)
/// given(bird.name).willReturn("Ryan")
///
/// print(bird.name)  // Prints "Ryan"
/// verify(bird.name).wasCalled()  // Passes
///
/// reset(bird)
///
/// print(bird.name)  // Error: Missing stubbed implementation
/// verify(bird.name).wasCalled()  // Error: Got 0 invocations
/// ```
///
/// - Parameter mocks: A set of mocks to reset.
public func reset(_ mocks: Mock...) {
  mocks.forEach({ mock in
    clearInvocations(on: mock)
    clearStubs(on: mock)
  })
}

/// Remove all recorded invocations and configured stubs on static members.
///
/// Fully reset a set of mocks during test runs by removing all recorded invocations and clearing
/// all configurations.
///
/// ```swift
/// let bird = mock(Bird.self)
/// given(bird.name).willReturn("Ryan")
///
/// print(bird.name)  // Prints "Ryan"
/// verify(bird.name).wasCalled()  // Passes
///
/// reset(bird)
///
/// print(bird.name)  // Error: Missing stubbed implementation
/// verify(bird.name).wasCalled()  // Error: Got 0 invocations
/// ```
///
/// - Parameter mocks: A set of static mocks to reset.
public func reset(_ staticMocks: Mock.Type...) {
  staticMocks.forEach({ mock in
    clearInvocations(on: mock)
    clearStubs(on: mock)
  })
}

/// Remove all recorded invocations and configured stubs for Objective-C mocks.
///
/// Fully reset a set of mocks during test runs by removing all recorded invocations and clearing
/// all configurations.
///
/// ```swift
/// let bird = mock(Bird.self)
/// given(bird.name).willReturn("Ryan")
///
/// print(bird.name)  // Prints "Ryan"
/// verify(bird.name).wasCalled()  // Passes
///
/// reset(bird)
///
/// print(bird.name)  // Error: Missing stubbed implementation
/// verify(bird.name).wasCalled()  // Error: Got 0 invocations
/// ```
///
/// - Parameter mocks: A set of Objective-C mocks to reset.
@_disfavoredOverload
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
/// ```swift
/// let bird = mock(Bird.self)
/// given(bird.name).willReturn("Ryan")
///
/// print(bird.name)  // Prints "Ryan"
/// verify(bird.name).wasCalled()  // Passes
///
/// clearInvocations(on: bird)
/// verify(bird.name).wasCalled()  // Error: Got 0 invocations
/// ```
///
/// - Parameter mocks: A set of mocks to reset.
public func clearInvocations(on mocks: Mock...) {
  mocks.forEach({ $0.mockingbirdContext.mocking.clearInvocations() })
}

/// Remove all recorded invocations on static members.
///
/// Partially reset a set of static mocks during test runs by removing all recorded invocations.
///
/// ```swift
/// given(BirdMock.species).willReturn("Mimus polyglottos")
///
/// print(BirdMock.name)  // Prints "Mimus polyglottos"
/// verify(BirdMock.name).wasCalled()  // Passes
///
/// clearInvocations(on: BirdMock.self)
/// verify(BirdMock.species).wasCalled()  // Error: Got 0 invocations
/// ```
///
/// - Parameter mocks: A set of static mocks to reset.
public func clearInvocations(on mocks: Mock.Type...) {
  mocks.forEach({ $0.mockingbirdContext.mocking.clearInvocations() })
}

/// Remove all recorded invocations for Objective-C mocks.
///
/// Partially reset a set of mocks during test runs by removing all recorded invocations.
///
/// ```swift
/// let bird = mock(Bird.self)
/// given(bird.name).willReturn("Ryan")
///
/// print(bird.name)  // Prints "Ryan"
/// verify(bird.name).wasCalled()  // Passes
///
/// clearInvocations(on: bird)
/// verify(bird.name).wasCalled()  // Error: Got 0 invocations
/// ```
///
/// - Parameter mocks: A set of Objective-C mocks to reset.
@_disfavoredOverload
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
/// ```swift
/// let bird = mock(Bird.self)
/// given(bird.name).willReturn("Ryan")
///
/// print(bird.name)  // Prints "Ryan"
/// clearStubs(on: bird)
/// print(bird.name)  // Error: Missing stubbed implementation
/// ```
///
/// - Parameter mocks: A set of mocks to reset.
public func clearStubs(on mocks: Mock...) {
  mocks.forEach({ clearStubs(on: $0.mockingbirdContext) })
}

/// Remove all concrete stubs on static members.
///
/// Partially reset a set of static mocks during test runs by removing all stubs.
///
/// ```swift
/// given(BirdMock.species).willReturn("Mimus polyglottos")
///
/// print(BirdMock.species)  // Prints "Mimus polyglottos"
/// clearStubs(on: bird)
/// print(BirdMock.species)  // Error: Missing stubbed implementation
/// ```
///
/// - Parameter mocks: A set of mocks to reset.
public func clearStubs(on mocks: Mock.Type...) {
  mocks.forEach({ clearStubs(on: $0.mockingbirdContext) })
}

/// Remove all concrete stubs for Objective-C mocks.
///
/// Partially reset a set of mocks during test runs by removing all stubs.
///
/// ```swift
/// let bird = mock(Bird.self)
/// given(bird.name).willReturn("Ryan")
///
/// print(bird.name)  // Prints "Ryan"
/// clearStubs(on: bird)
/// print(bird.name)  // Error: Missing stubbed implementation
/// ```
///
/// - Parameter mocks: A set of mocks to reset.
@_disfavoredOverload
public func clearStubs(on mocks: NSObjectProtocol...) {
  mocks.forEach({ mock in
    guard let context = mock.mockingbirdContext else { return }
    clearStubs(on: context)
  })
}

/// Removes all configured stubs in a context.
private func clearStubs(on context: Context) {
  context.stubbing.clearStubs()
  context.stubbing.defaultValueProvider.update { $0.reset() }
  context.proxy.clearTargets()
}

/// Remove all registered default values.
///
/// Partially reset a set of mocks during test runs by removing all registered default values.
///
/// ```swift
/// let bird = mock(Bird.self)
/// bird.useDefaultValues(from: .standardProvider)
///
/// print(bird.name)  // Prints ""
/// verify(bird.name).wasCalled()  // Passes
///
/// clearDefaultValues(on: bird)
/// print(bird.name)  // Error: Missing stubbed implementation
/// ```
///
/// - Parameter mocks: A set of mocks to reset.
@available(*, deprecated, renamed: "clearStubs")
public func clearDefaultValues(on mocks: Mock...) {
  mocks.forEach({
    $0.mockingbirdContext.stubbing.defaultValueProvider.update { $0.reset() }
  })
}
