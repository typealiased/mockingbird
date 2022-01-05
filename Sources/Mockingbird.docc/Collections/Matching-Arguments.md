# Matching Arguments

Stub and verify methods with parameters.

## Overview

Argument matchers allow you to stub or verify specific invocations of parameterized methods.

### Match Exact Values

Types that explicitly conform to `Equatable` work out of the box, such as `String`.

```swift
given(bird.chirp(volume: 42)).willReturn(true)
print(bird.chirp(volume: 42))               // Prints "true"
verify(bird.chirp(volume: 42)).wasCalled()  // Passes
```

Structs able to synthesize `Equatable` conformance must explicitly declare conformance to enable exact argument matching.

```swift
struct Fruit: Equatable {
  let size: Int
}

bird.eat(Fruit(size: 42))
verify(bird.eat(Fruit(size: 42))).wasCalled()
```

Non-equatable classes are compared by reference instead.

```swift
class Fruit {}
let fruit = Fruit()

bird.eat(fruit)
verify(bird.eat(fruit)).wasCalled()
```

### Match Wildcard Values and Non-Equatable Types

Argument matchers allow for wildcard or custom matching of arguments that are not `Equatable`.

```swift
any()                    // Any value
any(of: 1, 2, 3)         // Any value in {1, 2, 3}
any(where: { $0 > 42 })  // Any number greater than 42
notNil()                 // Any non-nil value
```

For methods overloaded by parameter type, you should help the compiler by specifying an explicit type in the matcher.

```swift
any(Int.self)
any(Int.self, of: 1, 2, 3)
any(Int.self, where: { $0 > 42 })
notNil(String?.self)
```

You can also match elements or keys within collection types.

```swift
any(containing: 1, 2, 3)  // Any collection with values {1, 2, 3}
any(keys: "a", "b", "c")  // Any dictionary with keys {"a", "b", "c"}
any(count: atMost(42))    // Any collection with at most 42 elements
notEmpty()                // Any non-empty collection
```

### Match Value Types in Objective-C

You must specify an argument position when matching an Objective-C method with multiple value type parameters. Mockingbird will raise a test failure if the argument position is not inferrable and no explicit position was provided.

```swift
@objc class Bird: NSObject {
  @objc dynamic func chirp(volume: Int, duration: Int) {}
}

verify(bird.chirp(volume: firstArg(any()),
                  duration: secondArg(any())).wasCalled()

// Equivalent verbose syntax
verify(bird.chirp(volume: arg(any(), at: 1),
                  duration: arg(any(), at: 2)).wasCalled()
```

### Match Floating Point Values

Mathematical operations on floating point numbers can cause loss of precision. Fuzzily match floating point arguments instead of using exact values to increase the robustness of tests.

```swift
around(10.0, tolerance: 0.01)
```

## Topics

### All Values

- ``/documentation/Mockingbird/any(_:)-8gb6h``
- ``/documentation/Mockingbird/notNil(_:)-352p4``

### Specific Values

- ``/documentation/Mockingbird/any(_:where:)-7cboq``
- ``/documentation/Mockingbird/any(_:of:)-29tpo``
- ``/documentation/Mockingbird/any(_:of:)-huee``
- ``around(_:tolerance:)``

### Collection Elements

- ``/documentation/Mockingbird/any(_:containing:)-so7o``
- ``/documentation/Mockingbird/any(_:count:)``
- ``/documentation/Mockingbird/any(_:containing:)-64rt9``
- ``/documentation/Mockingbird/any(_:keys:)``
- ``/documentation/Mockingbird/notEmpty(_:)``

### Objective-C Objects

- ``/documentation/Mockingbird/any(_:)-h08s``
- ``/documentation/Mockingbird/any(_:where:)-2b6ht``
- ``/documentation/Mockingbird/notNil(_:)-3dht5``
