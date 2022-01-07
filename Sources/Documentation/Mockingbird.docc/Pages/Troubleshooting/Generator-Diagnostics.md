# Generator Diagnostics

Output Xcode diagnostic warnings and errors when generating mocks.

## Diagnostic Warnings

Specify diagnostic types that should be included in the `--diagnostics` generator option.

| Diagnostic | Description |
| --- | --- |
| `all` | Emit all diagnostic warnings. |
| `not-mockable` | Warn when skipping declarations that cannot be mocked. |
| `undefined-type` | Warn on external types not defined in a supporting source file. |
| `type-inference` | Warn when skipping complex property assignments in class mocks. |

## Runtime Test Failures

Test failures typically occur when evaluating `verify` statements and will show up in the Xcode “Test navigator” sidebar.

| **Error** | |
| --- | --- |
| Missing stubbed implementation for '`<I>`' |

A mocked method that must return a value was called without a stubbed implementation. This error is fatal and Mockingbird will try to gracefully stop the current test run without affecting other tests. Note that stubbed implementation errors will be attributed to the line where the mock was initialized, rather than the specific test case due to limitations with XCTest.

| **Error** |
| --- |
| Got [`<X>`] invocations of '`<I>`' but expected `<Y>` |

The actual number of invocations of a method did not match the expected count. Parameterized methods must have parameter types that explicitly conform to `Equatable` or be matched with a wildcard [argument matcher](https://github.com/birdrides/mockingbird#argument-matching).

| **Error** |
| --- |
| Unable to simultaneously satisfy expectations |

The recorded invocations did not pass the in order verification expectations. Due to ambiguity with which `verify` statement is actually responsible for the failure, the error is attributed to the enclosing in order block.

| **Error** |
| --- |
| Got unexpected invocations `<before:after>` '`<I>`' |

In order verification failed for one of the optional invariants. Due to ambiguity with which expectation constraint is actually responsible for the failure, the error is attributed to the in order block.

## Compile Time Generator Errors

Mockingbird uses availability attributes and diagnostic errors to signal when there are known issues during code generation. This differs from errors caused by a misconfigured project (or more rarely, a generator bug) where the generated mock does not compile.

| **Error** |
| --- |
| No generated mock for this type which might be resolved by building the test target (⇧⌘U) |

The type being mocked does not exist in a generated mock file. The project may not be correctly configured or the target should be rebuilt to trigger the mock generation build phase.

| **Error** |
| --- |
| '`<M>`' inherits from the externally-defined type '`<T>`' which needs to be declared in a supporting source file |

The protocol being mocked inherits from a type defined outside of the project. In order to generate valid mocking code, the inherited type needs to be defined in a [supporting source file](https://github.com/birdrides/mockingbird#supporting-source-files).

```swift
// Defined outside of the project, e.g. in a library
protocol ExternalProtocol {
  func method()
}

// Need to define `ExternalProtocol` in a supporting source file
protocol MyProtocol: ExternalProtocol {}
```

| **Error** |
| --- |
| '`<M>`' contains the property '`<P>`' that conflicts with an inherited declaration and cannot be mocked |

The protocol being mocked inherits conflicting properties with the same name but different types.

```swift
protocol MyBaseProtocol {
  var property: Bool { get set }
}

// Not possible to create a class that conforms to `MyProtocol`
protocol MyProtocol: MyBaseProtocol {
  var property: Int { get set }
}
```

| **Error** |
| --- |
| '`<M>`' does not declare any accessible designated initializers and cannot be mocked |

Change the existing designated initializer or add a new designated initializer with `internal` or higher accessibility.

```swift
class MyClass {
  private init() {}
}
```

| **Error** |
| --- |
| '`<M>`' subclasses a type from a different module but does not declare any accessible initializers and cannot be mocked |

Add a designated initializer in the mocked class type or change the externally-inherited initializers to have `public` or `open` accessibility.

```swift
// Defined in another module
open class ExternalBaseClass {
  // Internally-accessible designated initializer
  init(with param: String) {}
}

// Class to be mocked which cannot be initialized
class MyClass: ExternalBaseClass {}
```
