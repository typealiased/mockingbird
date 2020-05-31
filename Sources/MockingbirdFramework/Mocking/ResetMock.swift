//
//  ResetMock.swift
//  MockingbirdFramework
//
//  Created by Andrew Chang on 5/31/20.
//

import Foundation

/// Remove all recorded invocations and configured stubs.
///
/// Fully reset a set of mocks during test runs by removing all recorded invocations and clearing
/// all configurations.
///
///     let bird = mock(Bird.self)
///     given(bird.getName()).willReturn("Ryan")
///
///     print(bird.name)  // Prints "Ryan"
///     verify(bird.getName()).wasCalled()  // Passes
///
///     reset(bird)
///
///     print(bird.name)  // Error: Missing stubbed implementation
///     verify(bird.getName()).wasCalled()  // Error: Got 0 invocations
///
/// - Parameter mocks: A set of mocks to reset.
public func reset(_ mocks: Mock...) {
  mocks.forEach({
    $0.mockingContext.clearInvocations()
    $0.stubbingContext.clearStubs()
    $0.stubbingContext.defaultValueProvider.reset()
  })
}

/// Remove all recorded invocations.
///
/// Partially reset a set of mocks during test runs by removing all recorded invocations.
///
///     let bird = mock(Bird.self)
///     given(bird.getName()).willReturn("Ryan")
///
///     print(bird.name)  // Prints "Ryan"
///     verify(bird.getName()).wasCalled()  // Passes
///
///     clearInvocations(on: bird)
///
///     print(bird.name)  // Prints "Ryan"
///     verify(bird.getName()).wasCalled()  // Error: Got 0 invocations
///
/// - Parameter mocks: A set of mocks to reset.
public func clearInvocations(on mocks: Mock...) {
  mocks.forEach({ $0.mockingContext.clearInvocations() })
}

/// Remove all concrete stubs.
///
/// Partially reset a set of mocks during test runs by removing all stubs.
///
///     let bird = mock(Bird.self)
///     given(bird.getName()).willReturn("Ryan")
///
///     print(bird.name)  // Prints "Ryan"
///     verify(bird.getName()).wasCalled()  // Passes
///
///     clearStubs(on: bird)
///
///     print(bird.name)  // Error: Missing stubbed implementation
///     verify(bird.getName()).wasCalled()  // Passes
///
/// - Parameter mocks: A set of mocks to reset.
public func clearStubs(on mocks: Mock...) {
  mocks.forEach({ $0.stubbingContext.clearStubs() })
}

/// Remove all registered default values.
///
/// Partially reset a set of mocks during test runs by removing all registered default values.
///
///     let bird = mock(Bird.self)
///     bird.useDefaultValues(from: .standardProvider)
///
///     print(bird.name)  // Prints ""
///     verify(bird.getName()).wasCalled()  // Passes
///
///     clearDefaultValues(on: bird)
///
///     print(bird.name)  // Error: Missing stubbed implementation
///     verify(bird.getName()).wasCalled()  // Passes
///
/// - Parameter mocks: A set of mocks to reset.
public func clearDefaultValues(on mocks: Mock...) {
  mocks.forEach({ $0.stubbingContext.defaultValueProvider.reset() })
}
