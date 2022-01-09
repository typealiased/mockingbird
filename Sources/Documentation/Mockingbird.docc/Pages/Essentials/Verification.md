# Verification

Check whether a mocked method or property was called.

## Overview

Verification lets you assert that a mock received a particular invocation during its lifetime.

```swift
verify(bird.fly()).wasCalled()
```

Verifying doesn’t remove recorded invocations, so it’s safe to call `verify` multiple times.

```swift
verify(bird.fly()).wasCalled()  // If this succeeds...
verify(bird.fly()).wasCalled()  // ...this also succeeds
```

### Verify Methods with Parameters

[Match argument values](#4-argument-matching) to verify methods with parameters.

```swift
verify(bird.chirp(volume: any())).wasCalled()     // Any volume
verify(bird.chirp(volume: notNil())).wasCalled()  // Any non-nil volume
verify(bird.chirp(volume: 10)).wasCalled()        // Volume = 10
```

### Verify Properties

Verify property invocations using their getter and setter methods.

```swift
verify(bird.name).wasCalled()
verify(bird.name = any()).wasCalled()
```

### Verify the Number of Invocations

It’s possible to verify that an invocation was called a specific number of times with a count matcher.

```swift
verify(bird.fly()).wasNeverCalled()            // n = 0
verify(bird.fly()).wasCalled(exactly(10))      // n = 10
verify(bird.fly()).wasCalled(atLeast(10))      // n ≥ 10
verify(bird.fly()).wasCalled(atMost(10))       // n ≤ 10
verify(bird.fly()).wasCalled(between(5...10))  // 5 ≤ n ≤ 10
```

Count matchers also support chaining and negation using logical operators.

```swift
verify(bird.fly()).wasCalled(not(exactly(10)))           // n ≠ 10
verify(bird.fly()).wasCalled(exactly(10).or(atMost(5)))  // n = 10 || n ≤ 5
```

### Capture Argument Values

An argument captor extracts received argument values which can be used in other parts of the test.

```swift
let bird = mock(Bird.self)
bird.name = "Ryan"

let nameCaptor = ArgumentCaptor<String>()
verify(bird.name = nameCaptor.any()).wasCalled()

print(nameCaptor.value)  // Prints "Ryan"
```

### Verify Invocation Order

Enforce the relative order of invocations with an `inOrder` verification block.

```swift
// Verify that `canFly` was called before `fly`
inOrder {
  verify(bird.canFly).wasCalled()
  verify(bird.fly()).wasCalled()
}
```

Pass options to `inOrder` verification blocks for stricter checks with additional invariants.

```swift
inOrder(with: .noInvocationsAfter) {
  verify(bird.canFly).wasCalled()
  verify(bird.fly()).wasCalled()
}
```

### Verify Asynchronous Calls

Mocked methods that are invoked asynchronously can be verified using an `eventually` block which creates an `XCTestExpectation` and attaches it to the current `XCTestCase`.

```swift
DispatchQueue.main.async {
  guard bird.canFly else { return }
  bird.fly()
}

eventually {
  verify(bird.canFly).wasCalled()
  verify(bird.fly()).wasCalled()
}

waitForExpectations(timeout: 1.0)
```

### Verify Overloaded Methods

Use the `returning` modifier to disambiguate methods overloaded by return type. Methods overloaded by parameter types do not require disambiguation.

```swift
protocol Bird {
  func getMessage<T>() -> T    // Overloaded generically
  func getMessage() -> String  // Overloaded explicitly
  func getMessage() -> Data
}

verify(bird.getMessage()).returning(String.self).wasCalled()
```

## Topics

### Verifying Invocations

- ``/documentation/Mockingbird/verify(_:file:line:)-4nziv``
- ``/documentation/Mockingbird/verify(_:file:line:)-tojb``

### Matching Invocation Counts

- ``never``
- ``once``
- ``twice``
- ``exactly(_:)``
- ``atLeast(_:)``
- ``atMost(_:)``
- ``between(_:)``
- ``/documentation/Mockingbird/not(_:)-7i8si``
- ``/documentation/Mockingbird/not(_:)-8uq76``

### Advanced Verification

- ``ArgumentCaptor``
- ``inOrder(with:file:line:_:)``
- ``eventually(_:_:)``
