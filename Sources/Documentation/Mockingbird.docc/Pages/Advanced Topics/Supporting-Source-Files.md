# Supporting Source Files

Add additional source files to resolve external type declarations.

## Overview

Types defined in a library or framework that you don’t have source access to cannot be parsed by Mockingbird. Supporting source files allow you to provide external types to the generator so that it can resolve inherited methods and properties correctly.

> Note: Supporting source files do not yet allow you to mock external types. See <doc:Mocking-External-Types> for more information.

### Starter Pack

Mockingbird provides a set of starter supporting source files for basic compatibility with the Swift standard library and common system frameworks. The configurator automatically downloads and integrates them into your project, but you can retrieve the latest version from the [GitHub release artifacts](https://github.com/birdrides/mockingbird/releases).

### Adding Files

Add supporting source files whenever a type inherits from an external type. For example, the protocol `Bird` cannot be mocked because it inherits from `ExternalType` and Mockingbird does not know that it declares the method `foobar`.

```swift
// Defined in `ExternalFramework`
public protocol ExternalType {
  func foobar()
}

// Defined in `BirdApp`
protocol Bird: ExternalType {}
```

In order to generate a mock for `Bird`, the declaration for `ExternalType` should be added to a supporting source file. File names are arbitrary, but the containing directory must be equal to the module name.

> Important: You should never add supporting source files to any Xcode targets as they will not compile.

```swift
// Added to `MockingbirdSupport/ExternalFramework/ExternalType.swift`
public protocol ExternalType {
  func someMethod()
}
```

Mockingbird can now parse `ExternalType` and the method `foobar`, allowing `Bird` and any other types that inherit from `ExternalType` to be generated and mocked.
