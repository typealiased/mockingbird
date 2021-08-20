<p align="center">
  <img src="/docs/images/mockingbird-hero-image.png" alt="Mockingbird - Swift Mocking Framework" width="150">
  <h1 align="center">Mockingbird</h1>
</p>

<p align="center">
  <a href="#installation"><img src="https://img.shields.io/badge/package-CocoaPods%20%7C%20Carthage%20%7C%20SwiftPM-4BC51D.svg" alt="Package managers"></a>
  <a href="/birdrides/mockingbird/blob/add-readme-logo/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="License"></a>
  <a href="https://slofile.com/slack/birdopensource" rel="nofollow"><img src="https://img.shields.io/badge/slack-%23mockingbird-A417A6.svg" alt="Slack channel"></a>
</p>

Mockingbird lets you mock, stub, and verify objects written in either Swift or Objective-C. The syntax takes inspiration from (OC)Mockito but was designed to be “Swifty” in terms of type safety and expressiveness.

```swift
// Mocking
let bird = mock(Bird.self)

// Stubbing
given(bird.name).willReturn("Ryan")

// Verification
verify(bird.fly()).wasCalled()
```

Mockingbird was built to reduce the number of “artisanal” hand-written mocks and make it easier to write tests at Bird. Conceptually, Mockingbird uses codegen to statically mock Swift types and `NSProxy` to dynamically mock Objective-C types. The approach is similar to other automatic Swift mocking frameworks and is unlikely to change due to Swift’s limited runtime introspection capabilities.

That said, there are a few key differences from other frameworks:

- Generating mocks takes seconds instead of minutes on large codebases with thousands of mocked types.
- Stubbing and verification failures appear inline and don’t abort the entire test run.
- Production code is kept separate from tests and never modified with annotations.
- Xcode projects can be used as the source of truth to automatically determine source files.

See a detailed [feature comparison table](https://github.com/birdrides/mockingbird/wiki/Alternatives-to-Mockingbird#feature-comparison) and [known limitations](https://github.com/birdrides/mockingbird/wiki/Known-Limitations).

### Who Uses Mockingbird?

Mockingbird powers thousands of tests at companies including [Facebook](https://facebook.com), [Amazon](https://amazon.com), [Twilio](https://twilio.com), and [Bird](https://bird.co). Using Mockingbird to improve your testing workflow? Consider dropping us a line on the [#mockingbird Slack channel](https://slofile.com/slack/birdopensource).

### An Example

Let’s say we wanted to test a `Person` class with a function that takes in a `Bird`.

```swift
protocol Bird {
  var canFly: Bool { get }
  func fly()
}

class Person {
  func release(_ bird: Bird) {
    guard bird.canFly else { return }
    bird.fly()
  }
}
```

With Mockingbird, it’s easy to stub return values and verify that mocked methods were called.

```swift
// Given a bird that can fly
let bird = mock(Bird.self)
given(bird.canFly).willReturn(true)

// When a person releases the bird
Person().release(bird)

// Then the bird flies away
verify(bird.fly()).wasCalled()
```

## Installation

Select your preferred dependency manager below to get started.

<details><summary><b>CocoaPods</b></summary>

Add the framework to a test target in your `Podfile`, making sure to include the `use_frameworks!` option.

```ruby
target 'MyAppTests' do
  use_frameworks!
  pod 'MockingbirdFramework', '~> 0.18'
end
```

In your project directory, initialize the pod.

```console
$ pod install
```

Finally, configure a test target to generate mocks for each listed source module. This adds a build phase to the test target which calls [`mockingbird generate`](#generate). For advanced usages, modify the installed build phase or [set up targets manually](https://github.com/birdrides/mockingbird/wiki/Manual-Setup).

```console
$ Pods/MockingbirdFramework/mockingbird install --target MyAppTests --sources MyApp MyLibrary1 MyLibrary2
```

Optional but recommended:

- [Exclude generated files from source control](https://github.com/birdrides/mockingbird/wiki/Integration-Tips#source-control-exclusion)
- [Add supporting source files for compatibility with external dependencies](https://github.com/birdrides/mockingbird/wiki/Supporting-Source-Files)

Have questions or issues?

- [Join the Slack channel](https://slofile.com/slack/birdopensource)
- [Search the troubleshooting guide](https://github.com/birdrides/mockingbird/wiki/Troubleshooting)
- [Check out the CocoaPods example project](/Examples/iOSMockingbirdExample-CocoaPods)

</details>

<details><summary><b>Carthage</b></summary>

Add the framework to your `Cartfile`.

```
github "birdrides/mockingbird" ~> 0.18
```

In your project directory, build the framework and [link it to your test target](https://github.com/birdrides/mockingbird/wiki/Linking-Test-Targets).

```console
$ carthage update --use-xcframeworks
```

Finally, configure a test target to generate mocks for each listed source module. This adds a build phase to the test target which calls [`mockingbird generate`](#generate). For advanced usages, modify the installed build phase or [set up targets manually](https://github.com/birdrides/mockingbird/wiki/Manual-Setup).

```console
$ mockingbird install --target MyAppTests --sources MyApp MyLibrary1 MyLibrary2
```

Optional but recommended:

- [Exclude generated files from source control](https://github.com/birdrides/mockingbird/wiki/Integration-Tips#source-control-exclusion)
- [Add supporting source files for compatibility with external dependencies](https://github.com/birdrides/mockingbird/wiki/Supporting-Source-Files)

Have questions or issues?

- [Join the Slack channel](https://slofile.com/slack/birdopensource)
- [Search the troubleshooting guide](https://github.com/birdrides/mockingbird/wiki/Troubleshooting)
- [Check out the Carthage example project](/Examples/iOSMockingbirdExample-Carthage)

</details>

<details><summary><b>Swift Package Manager</b></summary>

Add Mockingbird as a package and test target dependency in your `Package.swift` manifest.

```swift
let package = Package(
  name: "MyPackage",
  dependencies: [
    .package(name: "Mockingbird", url: "https://github.com/birdrides/mockingbird.git", .upToNextMinor(from: "0.18.0")),
  ],
  targets: [
    .testTarget(name: "MyPackageTests", dependencies: ["Mockingbird"]),
  ]
)
```

In your project directory, initialize the package dependency.

> Parsing the `DERIVED_DATA` path can take a minute.

```console
$ xcodebuild -resolvePackageDependencies
$ DERIVED_DATA="$(xcodebuild -showBuildSettings | pcregrep -o1 'OBJROOT = (/.*)/Build')"
$ REPO_PATH="${DERIVED_DATA}/SourcePackages/checkouts/mockingbird"
```

Finally, configure a test target to generate mocks for each listed source module. This adds a build phase to the test target which calls [`mockingbird generate`](#generate). For advanced usages, modify the installed build phase or [set up targets manually](https://github.com/birdrides/mockingbird/wiki/Manual-Setup).

> Not using an Xcode project? Generate mocks from the command line by calling [`mockingbird generate`](#generate).

```console
$ "${REPO_PATH}/mockingbird" install --target MyPackageTests --sources MyPackage MyLibrary1 MyLibrary2
```

Optional but recommended:

- [Exclude generated files from source control](https://github.com/birdrides/mockingbird/wiki/Integration-Tips#source-control-exclusion)
- [Add supporting source files for compatibility with external dependencies](https://github.com/birdrides/mockingbird/wiki/Supporting-Source-Files)

Have questions or issues?

- [Join the Slack channel](https://slofile.com/slack/birdopensource)
- [Search the troubleshooting guide](https://github.com/birdrides/mockingbird/wiki/Troubleshooting)
- [Check out the Swift Package Manager example project](/Examples/iOSMockingbirdExample-SPM)

</details>

## Usage

Mockingbird provides a comprehensive [API reference](https://birdrides.github.io/mockingbird/latest/) generated with [SwiftDoc](https://github.com/SwiftDocOrg/swift-doc).

1. [Mocking](#1-mocking)
2. [Stubbing](#2-stubbing)
3. [Verification](#3-verification)
4. [Argument Matching](#4-argument-matching)
5. [Advanced Topics](#5-advanced-topics)

### 1. Mocking

Mocks can be passed as instances of the original type, recording any calls they receive for later verification. Note that mocks are strict by default, meaning that calls to unstubbed non-void methods will trigger a test failure. To create a relaxed or “loose” mock, use a [default value provider](#stub-as-a-relaxed-mock).

```swift
// Swift types
let protocolMock = mock(MyProtocol.self)
let classMock = mock(MyClass.self).initialize(…)

// Objective-C types
let protocolMock = mock(MyProtocol.self)
let classMock = mock(MyClass.self)
```

#### Mock Swift Classes

Swift class mocks rely on subclassing the original type which comes with a few [known limitations](https://github.com/birdrides/mockingbird/wiki/Known-Limitations). When creating a Swift class mock, you must initialize the instance by calling `initialize(…)` with appropriate values.

```swift
class Tree {
  init(height: Int) { assert(height > 0) }
}

let tree = mock(Tree.self).initialize(height: 42)  // Initialized
let tree = mock(Tree.self).initialize(height: 0)   // Assertion failed (height ≤ 0)
```

#### Store Mocks

Generated Swift mock types are suffixed with `Mock`. Avoid coercing mocks into their original type as stubbing and verification will no longer work.

```swift
// Good
let bird: BirdMock = mock(Bird.self)  // Concrete type is `BirdMock`
let bird = mock(Bird.self)            // Inferred type is `BirdMock`

// Avoid
let bird: Bird = mock(Bird.self)      // Type is coerced into `Bird`
```

#### Reset Mocks

You can reset mocks and clear specific metadata during test runs. However, resetting mocks isn’t usually necessary in well-constructed tests.

```swift
reset(bird)                 // Reset everything
clearStubs(on: bird)        // Only remove stubs
clearInvocations(on: bird)  // Only remove recorded invocations
```

### 2. Stubbing

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

#### Stub Methods with Parameters

[Match argument values](#4-argument-matching) to stub parameterized methods. Stubs added later have a higher precedence, so add stubs with specific matchers last.

```swift
given(bird.chirp(volume: any())).willReturn(true)     // Any volume
given(bird.chirp(volume: notNil())).willReturn(true)  // Any non-nil volume
given(bird.chirp(volume: 10)).willReturn(true)        // Volume = 10
```

#### Stub Properties

Properties can have stubs on both their getters and setters.

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

#### Stub as a Relaxed Mock

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

#### Stub as a Partial Mock

Partial mocks can be created by forwarding all calls to a specific object. Forwarding targets are strongly referenced and receive invocations until removed with `clearStubs`.

```swift
class Crow: Bird {
  let name: String
  init(name: String) { self.name = name }
}

let bird = mock(Bird.self)
bird.forwardCalls(to: Crow(name: "Ryan"))
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
given(bird.name).willForward(to: Crow(name: "Ryan"))  // Object target
given(tree.height).willForwardToSuper()               // Superclass target
```

Concrete stubs always have a higher priority than forwarding targets, regardless of the order
they were added.

```swift
given(bird.name).willReturn("Ryan")
given(bird.name).willForward(to: Crow(name: "Sterling"))
print(bird.name)  // Prints "Ryan"
```

#### Stub a Sequence of Values

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

### 3. Verification

Verification lets you assert that a mock received a particular invocation during its lifetime.

```swift
verify(bird.fly()).wasCalled()
```

Verifying doesn’t remove recorded invocations, so it’s safe to call `verify` multiple times.

```swift
verify(bird.fly()).wasCalled()  // If this succeeds...
verify(bird.fly()).wasCalled()  // ...this also succeeds
```

#### Verify Methods with Parameters

[Match argument values](#4-argument-matching) to verify methods with parameters.

```swift
verify(bird.chirp(volume: any())).wasCalled()     // Any volume
verify(bird.chirp(volume: notNil())).wasCalled()  // Any non-nil volume
verify(bird.chirp(volume: 10)).wasCalled()        // Volume = 10
```

#### Verify Properties

Verify property invocations using their getter and setter methods.

```swift
verify(bird.name).wasCalled()
verify(bird.name = any()).wasCalled()
```

#### Verify the Number of Invocations

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

#### Capture Argument Values

An argument captor extracts received argument values which can be used in other parts of the test.

```swift
let bird = mock(Bird.self)
bird.name = "Ryan"

let nameCaptor = ArgumentCaptor<String>()
verify(bird.name = nameCaptor.any()).wasCalled()

print(nameCaptor.value)  // Prints "Ryan"
```

#### Verify Invocation Order

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

#### Verify Asynchronous Calls

Mocked methods that are invoked asynchronously can be verified using an `eventually` block which returns an `XCTestExpectation`.

```swift
DispatchQueue.main.async {
  guard bird.canFly else { return }
  bird.fly()
}

let expectation =
  eventually {
    verify(bird.canFly).wasCalled()
    verify(bird.fly()).wasCalled()
  }

wait(for: [expectation], timeout: 1.0)
```

#### Verify Overloaded Methods

Use the `returning` modifier to disambiguate methods overloaded by return type. Methods overloaded by parameter types do not require disambiguation.

```swift
protocol Bird {
  func getMessage<T>() -> T    // Overloaded generically
  func getMessage() -> String  // Overloaded explicitly
  func getMessage() -> Data
}

verify(bird.getMessage()).returning(String.self).wasCalled()
```

### 4. Argument Matching

Argument matching allows you to stub or verify specific invocations of parameterized methods.

#### Match Exact Values

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

#### Match Wildcard Values and Non-Equatable Types

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

#### Match Value Types in Objective-C

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

#### Match Floating Point Values

Mathematical operations on floating point numbers can cause loss of precision. Fuzzily match floating point arguments instead of using exact values to increase the robustness of tests.

```swift
around(10.0, tolerance: 0.01)
```

### 5. Advanced Topics

#### Excluding Files

You can exclude unwanted or problematic sources from being mocked by adding a `.mockingbird-ignore` file. Mockingbird follows the same pattern format as [`.gitignore`](https://git-scm.com/docs/gitignore#_pattern_format) and scopes ignore files to their enclosing directory.

#### Using Supporting Source Files

Supporting source files are used by the generator to resolve inherited types defined outside of your project. Although Mockingbird provides a preset “starter pack” for basic compatibility with common system frameworks, you will occasionally need to add your own definitions for third-party library types. Please see [Supporting Source Files](https://github.com/birdrides/mockingbird/wiki/Supporting-Source-Files) for more information.

#### Thunk Pruning

To improve compilation times for large projects, Mockingbird only generates mocking code (known as thunks) for types used in tests. Unused types can either produce “thunk stubs” or no code at all depending on the pruning level specified.

| Level | Description |
| --- | --- |
| `disable` | Always generate full thunks regardless of usage in tests. |
| `stub` | Generate partial definitions filled with `fatalError`. |
| `omit` | Don’t generate any definitions for unused types. |

Usage is determined by statically analyzing test target sources for calls to `mock(SomeType.self)`, which may not work out of the box for projects that indirectly synthesize types such as through Objective-C based dependency injection.

- **Option 1:** Explicitly reference each indirectly synthesized type in your tests, e.g. `_ = mock(SomeType.self)`. References can be placed anywhere in the test target sources, such as in the `setUp` method of a test case or in a single file.
- **Option 2:** Disable pruning entirely by setting the prune level with `--prunelevel disable`. Note that this may increase compilation times for large projects.

## Mockingbird CLI

### Generate

Generate mocks for a set of targets in a project.

`mockingbird generate`

| Option | Default Value | Description |
| --- | --- | --- |
| `--targets` | *(required)* | List of target names to generate mocks for. |
| `--project` | [`(inferred)`](#--project) | Path to an `.xcodeproj` file or a [JSON project description](https://github.com/birdrides/mockingbird/wiki/Manual-Setup#generating-mocks-for-non-xcode-projects). |
| `--srcroot` | [`(inferred)`](#--srcroot) | The directory containing your project’s source files. |
| `--outputs` | [`(inferred)`](#--outputs) | List of mock output file paths for each target. |
| `--support` | [`(inferred)`](#--support) | The directory containing [supporting source files](https://github.com/birdrides/mockingbird/wiki/Supporting-Source-Files). |
| `--testbundle` | [`(inferred)`](#--testbundle) | The name of the test bundle using the mocks. |
| `--header` |  `(none)` | Content to add at the beginning of each generated mock file. |
| `--condition` | `(none)` | [Compilation condition](https://docs.swift.org/swift-book/ReferenceManual/Statements.html#ID538) to wrap all generated mocks in, e.g. `DEBUG`. |
| `--diagnostics` | `(none)` | List of [diagnostic generator warnings](https://github.com/birdrides/mockingbird/wiki/Diagnostic-Warnings-and-Errors) to enable. |
| `--prune` | `stub` | The [pruning method](#thunk-pruning) to use on unreferenced types. |

| Flag | Description |
| --- | --- |
| `--only-protocols` | Only generate mocks for protocols. |
| `--disable-module-import` | Omit `@testable import <module>` from generated mocks. |
| `--disable-swiftlint` | Disable all SwiftLint rules in generated mocks. |
| `--disable-cache` | Ignore cached mock information stored on disk. |
| `--disable-relaxed-linking` | Only search explicitly imported modules. |

### Install

Configure a test target to use mocks.

`mockingbird install`

| Option | Default Value | Description |
| --- | --- | --- |
| `--target` | *(required)* | The name of a test target to configure. |
| `--sources` | *(required)* | List of target names to generate mocks for. |
| `--project` | [`(inferred)`](#--project) | Path to an `.xcodeproj` file or a [JSON project description](https://github.com/birdrides/mockingbird/wiki/Manual-Setup#generating-mocks-for-non-xcode-projects). |
| `--srcroot` | [`(inferred)`](#--srcroot) | The directory containing your project’s source files. |
| `--outputs` | [`(inferred)`](#--outputs) | List of mock output file paths for each target. |
| `--support` | [`(inferred)`](#--support) | The directory containing [supporting source files](https://github.com/birdrides/mockingbird/wiki/Supporting-Source-Files). |
| `--header` |  `(none)` | Content to add at the beginning of each generated mock file. |
| `--condition` | `(none)` | [Compilation condition](https://docs.swift.org/swift-book/ReferenceManual/Statements.html#ID538) to wrap all generated mocks in, e.g. `DEBUG`. |
| `--diagnostics` | `(none)` | List of [diagnostic generator warnings](https://github.com/birdrides/mockingbird/wiki/Diagnostic-Warnings-and-Errors) to enable. |
| `--loglevel` |  `(none)` | The log level to use when generating mocks, `quiet` or `verbose`. |
| `--prune` | `omit` | The [pruning method](#thunk-pruning) to use on unreferenced types. |

| Flag | Description |
| --- | --- |
| `--preserve-existing` | Don’t overwrite previously installed configurations. |
| `--asynchronous` | Generate mocks asynchronously in the background when building. |
| `--only-protocols` | Only generate mocks for protocols. |
| `--disable-swiftlint` | Disable all SwiftLint rules in generated mocks. |
| `--disable-cache` | Ignore cached mock information stored on disk. |
| `--disable-relaxed-linking` | Only search explicitly imported modules. |

### Uninstall

Remove Mockingbird from a test target.

`mockingbird uninstall`

| Option | Default Value | Description |
| --- | --- | --- |
| `--targets` | *(required)* | List of target names to uninstall the Run Script Phase. |
| `--project` | [`(inferred)`](#--project) | Your project’s `.xcodeproj` file. |
| `--srcroot` | [`(inferred)`](#--srcroot) | The directory containing your project’s source files. |

### Download

Download and unpack a compatible asset bundle. Bundles will never overwrite existing files on disk.

`mockingbird download <asset>`

| Asset | Description |
| --- | --- |
| `starter-pack` | Starter [supporting source files](https://github.com/birdrides/mockingbird/wiki/Supporting-Source-Files). |

| Option | Default Value | Description |
| --- | --- | --- |
| `--url` | `https://github.com/birdrides/mockingbird/releases/download` | The base URL containing downloadable asset bundles. |

### Global Options

| Flag | Description |
| --- | --- |
| `--verbose` | Log all errors, warnings, and debug messages. |
| `--quiet` | Only log error messages. |

### Inferred Paths

#### `--project`

Mockingbird first checks the environment variable `PROJECT_FILE_PATH` set by the Xcode build context and then performs a shallow search of the current working directory for an `.xcodeproj` file. If multiple `.xcodeproj` files exist then you must explicitly provide a project file path.

#### `--srcroot`

Mockingbird checks the environment variables `SRCROOT` and `SOURCE_ROOT` set by the Xcode build context and then falls back to the directory containing the `.xcodeproj` project file. Note that source root is ignored when using JSON project descriptions.

#### `--outputs`

By Mockingbird generates mocks into the directory `$(SRCROOT)/MockingbirdMocks` with the file name `$(PRODUCT_MODULE_NAME)Mocks.generated.swift`.

#### `--support`

Mockingbird recursively looks for [supporting source files](https://github.com/birdrides/mockingbird/wiki/Supporting-Source-Files) in the directory `$(SRCROOT)/MockingbirdSupport`.

#### `--testbundle`

Mockingbird checks the environment variables `TARGET_NAME` and `TARGETNAME` set by the Xcode build context and verifies that it refers to a valid Swift unit test target. The test bundle option must be set when using [JSON project descriptions](https://github.com/birdrides/mockingbird/wiki/Manual-Setup#generating-mocks-for-non-xcode-projects) in order to enable thunk stubs.

## Additional Resources

### Examples and Tutorials

- [CocoaPods tutorial + example project](/Examples/iOSMockingbirdExample-CocoaPods)
- [Carthage tutorial + example project](/Examples/iOSMockingbirdExample-Carthage)
- [Swift Package Manager tutorial + example project](/Examples/iOSMockingbirdExample-SPM)

### Help and Documentation

- [API reference](https://birdrides.github.io/mockingbird/latest/)
- [Slack channel](https://slofile.com/slack/birdopensource)
- [Troubleshooting guide](https://github.com/birdrides/mockingbird/wiki/Troubleshooting)
- [Mockingbird wiki](https://github.com/birdrides/mockingbird/wiki/)
