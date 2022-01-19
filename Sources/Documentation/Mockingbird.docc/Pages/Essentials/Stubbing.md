# Stubbing

Configure mocks to return a value or perform an operation.

## Overview

Stubbing allows you to define custom behavior for mocks to perform.

```swift
given(bird.name).willReturn("Ryan")                // Return a value
given(bird.chirp()).willThrow(BirdError())         // Throw an error
given(bird.chirp(volume: any())).will { volume in  // Call a closure
  return volume < 42
}
```

This is equivalent to the shorthand syntax using the stubbing operator `~>`.

```swift
given(bird.name) ~> "Ryan"                       // Return a value
given(bird.chirp()) ~> { throw BirdError() }     // Throw an error
given(bird.chirp(volume: any())) ~> { volume in  // Call a closure
  return volume < 42
}
```

### Stub Methods with Parameters

You can match exact or wildcard argument values when stubbing. See <doc:Matching-Arguments> for more examples.

```swift
given(bird.chirp(volume: any())).willReturn(true)     // Any volume
given(bird.chirp(volume: notNil())).willReturn(true)  // Any non-nil volume
given(bird.chirp(volume: 42)).willReturn(true)        // Volume = 42
```

It’s possible to add multiple stubs to a single method or property. Stubs are checked in reverse order, so add stubs with specific matchers last.

```swift
given(bird.chirp(volume: 42)).willReturn(true)      // #2
given(bird.chirp(volume: any())).willReturn(false)  // #1
print(bird.chirp(volume: 42))  // Prints "false"
```

### Stub Properties

Property getters and setters can both be stubbed.

```swift
given(bird.name).willReturn("Ryan")
given(bird.name = any()).will { (name: String) in
  print("Hello \(name)")
}

print(bird.name)        // Prints "Ryan"
bird.name = "Sterling"  // Prints "Hello Sterling"
```

This is equivalent to using the synthesized getter and setter methods.

```swift
given(bird.getName()).willReturn("Ryan")
given(bird.setName(any())).will { (name: String) in
  print("Hello \(name)")
}

print(bird.name)        // Prints "Ryan"
bird.name = "Sterling"  // Prints "Hello Sterling"
```

Readwrite properties can be stubbed to automatically save and return values.

```swift
given(bird.name).willReturn(lastSetValue(initial: ""))
print(bird.name)  // Prints ""
bird.name = "Ryan"
print(bird.name)  // Prints "Ryan"
```

### Stub as a Relaxed Mock

Use a `ValueProvider` to create a relaxed mock that returns default values for unstubbed methods. Mockingbird provides preset value providers which are guaranteed to be backwards compatible, such as `.standardProvider`.

```swift
let bird = mock(Bird.self)
bird.useDefaultValues(from: .standardProvider)
print(bird.name)  // Prints ""
```

You can create custom value providers by registering values for specific types.

```swift
var valueProvider = ValueProvider()
valueProvider.register("Ryan", for: String.self)
bird.useDefaultValues(from: valueProvider)
print(bird.name)  // Prints "Ryan"
```

Values from concrete stubs always have a higher precedence than default values.

```swift
given(bird.name).willReturn("Ryan")
print(bird.name)  // Prints "Ryan"

bird.useDefaultValues(from: .standardProvider)
print(bird.name)  // Prints "Ryan"
```

Provide wildcard instances for generic types by conforming the base type to `Providable` and registering the type.

```swift
extension Array: Providable {
  public static func createInstance() -> Self? {
    return Array()
  }
}

// Provide an empty array for all specialized `Array` types
valueProvider.registerType(Array<Any>.self)
```

### Stub as a Partial Mock

Partial mocks can be created by forwarding all calls to a specific object. Forwarding targets are strongly referenced and receive invocations until removed with `clearStubs`.

```swift
class Crow: Bird {
  let name: String
  init(_ name: String) { self.name = name }
}

let bird = mock(Bird.self)
bird.forwardCalls(to: Crow("Ryan"))
print(bird.name)  // Prints "Ryan"
```

Swift class mocks can also forward invocations to its underlying superclass.

```swift
let tree = mock(Tree.self).initialize(height: 42)
tree.forwardCallsToSuper()
print(tree.height)  // Prints "42"
```

For more granular stubbing, it’s possible to scope both object and superclass forwarding targets to a specific declaration.

```swift
given(bird.name).willForward(to: Crow("Ryan"))  // Object target
given(tree.height).willForwardToSuper()         // Superclass target
```

Concrete stubs always have a higher priority than forwarding targets, regardless of the order
they were added.

```swift
given(bird.name).willReturn("Ryan")
given(bird.name).willForward(to: Crow("Sterling"))
print(bird.name)  // Prints "Ryan"
```

### Stub a Sequence of Values

Methods that return a different value each time can be stubbed with a sequence of values. The last value will be used for all subsequent invocations.

```swift
given(bird.name).willReturn(sequence(of: "Ryan", "Sterling"))
print(bird.name)  // Prints "Ryan"
print(bird.name)  // Prints "Sterling"
print(bird.name)  // Prints "Sterling"
```

It’s also possible to stub a sequence of arbitrary behaviors.

```swift
given(bird.name)
  .willReturn("Ryan")
  .willReturn("Sterling")
  .will { return Bool.random() ? "Ryan" : "Sterling" }
```

## Topics

### Creating a Stub

- ``/documentation/Mockingbird/given(_:)-8yr0t``
- ``/documentation/Mockingbird/given(_:)-88nm9``

### Forwarding Invocations

- ``forward(to:)``
- ``forwardToSuper()``

### Readwrite Properties

- ``lastSetValue(initial:)``

### Stubbing Sequences

- ``/documentation/Mockingbird/sequence(of:)-7dfhm``
- ``/documentation/Mockingbird/sequence(of:)-2t65o``
- ``/documentation/Mockingbird/loopingSequence(of:)-3j25v``
- ``/documentation/Mockingbird/loopingSequence(of:)-3ew2v``
- ``/documentation/Mockingbird/finiteSequence(of:)-73crl``
- ``/documentation/Mockingbird/finiteSequence(of:)-7srgo``

### Objective-C Arguments

- ``firstArg(_:)``
- ``secondArg(_:)``
- ``thirdArg(_:)``
- ``fourthArg(_:)``
- ``fifthArg(_:)``
- ``arg(_:at:)``

### Providing Default Values

- ``Providable``
- ``ValueProvider``

### Stubbing Operator

- ``/documentation/Mockingbird/~_(_:_:)-6m8gw``
- ``/documentation/Mockingbird/~_(_:_:)-3eb81``
- ``/documentation/Mockingbird/~_(_:_:)-6yox8``
- ``/documentation/Mockingbird/~_(_:_:)-3to0j``
