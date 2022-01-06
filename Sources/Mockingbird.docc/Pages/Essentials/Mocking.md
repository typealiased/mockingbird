# Mocking

Create test doubles of Swift and Objective-C types.

## Overview

Mocks can be passed as instances of the original type, recording any calls they receive for later verification. Note that mocks are strict by default, meaning that calls to unstubbed non-void methods will trigger a test failure. To create a relaxed or “loose” mock, use a default value provider when <doc:Stubbing>.

```swift
// Swift types
let protocolMock = mock(MyProtocol.self)
let classMock = mock(MyClass.self).initialize(…)

// Objective-C types
let protocolMock = mock(MyProtocol.self)
let classMock = mock(MyClass.self)
```

### Mock Swift Classes

Swift class mocks rely on subclassing the original type which comes with a few <doc:Known-Limitations>. When creating a Swift class mock, you must initialize the instance by calling `initialize(…)` with appropriate values.

```swift
class Tree {
  init(height: Int) { assert(height > 0) }
}

let tree = mock(Tree.self).initialize(height: 42)  // Initialized
let tree = mock(Tree.self).initialize(height: 0)   // Assertion failed (height ≤ 0)
```

### Store Mocks

Generated Swift mock types are suffixed with `Mock`. Avoid coercing mocks into their original type as stubbing and verification will no longer work.

```swift
// Good
let bird: BirdMock = mock(Bird.self)  // Concrete type is `BirdMock`
let bird = mock(Bird.self)            // Inferred type is `BirdMock`

// Avoid
let bird: Bird = mock(Bird.self)      // Type is coerced into `Bird`
```

### Reset Mocks

You can reset mocks and clear specific metadata during test runs. However, resetting mocks isn’t usually necessary in well-constructed tests.

```swift
reset(bird)                 // Reset everything
clearStubs(on: bird)        // Only remove stubs
clearInvocations(on: bird)  // Only remove recorded invocations
```

## Topics

### Creating a Mock

- ``/documentation/Mockingbird/mock(_:)-90c7z``

### Resetting State

- ``/documentation/Mockingbird/reset(_:)-2rnp3``
- ``/documentation/Mockingbird/reset(_:)-1qqcc``
- ``/documentation/Mockingbird/clearInvocations(on:)-9e90o``
- ``/documentation/Mockingbird/clearInvocations(on:)-1wkme``
- ``/documentation/Mockingbird/clearStubs(on:)-3qkw6``
- ``/documentation/Mockingbird/clearStubs(on:)-23b4v``
- ``clearDefaultValues(on:)``
