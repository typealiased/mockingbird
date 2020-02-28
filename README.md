# Mockingbird

[![Package managers](https://img.shields.io/badge/package-cocoapods%20|%20carthage%20|%20spm-4BC51D.svg)](#installation)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)
[![Slack](https://img.shields.io/badge/slack-join%20channel-A417A6.svg)](https://slofile.com/slack/birdopensource)

Mockingbird is a convenient mocking framework for Swift.

```swift
// Mocking
let bird = mock(Bird.self)

// Stubbing
given(bird.getName()) ~> "Ryan"

// Verification
verify(bird.fly()).wasCalled()
```

---

## Installation

Mockingbird comes in two parts, both of which should be installed:

1. The **Mockingbird Framework** provides functions for mocking, stubbing, and verification in tests.
2. The **Mockingbird CLI** generates mocks.

### CocoaPods

Add the framework to a test target in your `Podfile`, making sure to include the `use_frameworks!` option.

```ruby
target 'ATestTarget' do
  use_frameworks!
  pod 'MockingbirdFramework', '~> 0.10.0'
end
```

Then initialize the pod.

```bash
$ pod install
```

And install the CLI.

```bash
$ cd Pods/MockingbirdFramework
$ make install-prebuilt
```

### Carthage

Add the framework to your `Cartfile`.

```
github "birdrides/mockingbird" ~> 0.10.0
```

And copy the Carthage script into your project root.

```bash
$ carthage update --no-build
$ cp Carthage/Checkouts/mockingbird/Scripts/carthage-update.sh ./
```

Use the script to checkout and build Carthage dependencies instead of `carthage update`.

```bash
$ ./carthage-update.sh
```

Then download and install the CLI.

```bash
$ cd Carthage/Checkouts/mockingbird
$ make install-prebuilt
```

### Swift Package Manager

Add `https://github.com/birdrides/mockingbird` as a dependency and link it to your unit test target.

Then download and install the CLI by selecting `MockingbirdCLI.pkg` from
[Releases](https://github.com/birdrides/mockingbird/releases).

### From Source

Clone the repository and build the `MockingbirdFramework` scheme for the desired platform. Drag the built 
`Mockingbird.framework` product into your project and 
[link the library to your test target](Documentation/LinkingTestTargets.md).

```bash
$ git clone https://github.com/birdrides/mockingbird.git
$ cd mockingbird
$ open Mockingbird.xcodeproj
```

Then build and install the CLI.

```bash
$ make install
```

## Setup

Mockingbird generates mocks using the `mockingbird` command line tool which can be integrated into your
build process in many different ways.

### Automatic Integration

Use the Mockingbird CLI to set up a destination unit test target. List all source targets that should generate mocks.
Below, Mockingbird will mock types in `Bird` and `BirdManagers` which can then be used in `BirdTests`.

```bash
$ mockingbird install \
  --targets Bird BirdManagers \
  --destination BirdTests
```

### Manual Integration

Add a Run Script Phase to each target that should generate mocks.

```bash
mockingbird generate
```

By default, Mockingbird will generate target mocks into the `$(SRCROOT)/MockingbirdMocks` directory.
You can specify a custom output location for each target using the
[`outputs`](https://github.com/birdrides/mockingbird#generate) CLI option.

Once generated, you must include each `.generated.swift` mock file as part of your unit test target sources.

### Excluding Files

You can exclude unwanted or problematic sources from being mocked by adding a `.mockingbird-ignore` file. 
Mockingbird follows the same pattern format as [`.gitignore`](https://git-scm.com/docs/gitignore#_pattern_format) 
and scopes ignore files to their enclosing directory.

## Usage

An example demonstrating basic usage of Mockingbird can be found at 
[TreeTests.swift](/MockingbirdTests/Example/TreeTests.swift).

### Mocking

Mocking lets you create objects which can be passed in place of the original type. Generated mock types are 
always suffixed with `Mock`.

```swift
/* Bird.swift */
protocol Bird {
  var name: String { get set }
  func canChirp(volume: Int) -> Bool
  func fly()
}

/* Tests.swift */
let bird = mock(Bird.self)  // Returns a `BirdMock`
```

You can also mock classes that have designated initializers. Keep in mind that class mocks rely on subclassing 
which has certain limitations, so consider using protocols whenever possible.

```swift
/* BirdClass.swift */
class BirdClass {
  let name: String
  init(name: String) {
    self.name = name
  }
}

/* Tests.swift */
let birdClass = mock(BirdClass.self).initialize(name: "Ryan")
```

### Stubbing

Stubbing allows you to define a custom value to return when a mocked method is called.

```swift
given(bird.getName()) ~> "Ryan"
```

You can use an [argument matcher](#argument-matching) when stubbing methods with parameters. Stubs added 
later have precedence over those added earlier, so stubs containing specific matchers should be added last.

```swift
given(bird.canChirp(volume: any())) ~> false    // Matches any volume
given(bird.canChirp(volume: notNil())) ~> true  // Matches any non-nil volume
given(bird.canChirp(volume: 10)) ~> false       // Matches volume = 10
```

Stub variables with their getter and setter methods.

```swift
given(bird.getName()) ~> "Big Bird"
given(bird.setName(any())) ~> { print($0) }
```

Getters can be stubbed to automatically save and return values.

```swift
given(bird.getName()) ~> lastSetValue(initial: "One")
bird.name = "Two"
assert(bird.name == "Two")
```

It’s possible to stub multiple methods with the same return type in a single call.

```swift
given(
  birdOne.getName(),
  birdTwo.getName()
) ~> "Big Bird"
```

### Verification

Verification lets you assert that a mock received a particular invocation during its lifetime.

```swift
/* Tree.swift */
class Tree {
  let bird: Bird
  init(with bird: Bird) {
    self.bird = bird
  }

  func shake() {
    bird.fly()
  }
}

/* Tests.swift */
let tree = Tree(with: bird)
tree.shake()  // Shaking the tree should scare the bird away
verify(bird.fly()).wasCalled()
```

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

Sometimes you need to perform custom checks on received parameters by using an argument captor.

```swift
let nameCaptor = ArgumentCaptor<String>()
verify(bird.setName(nameCaptor.matcher)).wasCalled()
assert(nameCaptor.value?.hasPrefix("R"))
```

You can test asynchronous code by using an `eventually` block which returns an `XCTestExpectation`. 

```swift
DispatchQueue.main.async {
  Tree(with: bird).shake()
}
let expectation = eventually {
  verify(bird.fly()).wasCalled()
  verify(bird.chirp()).wasCalled()
}
wait(for: [expectation], timeout: 1.0)
```

Verifying doesn’t remove recorded invocations, so it’s safe to call verify multiple times (even if not recommended).

```swift
verify(bird.fly()).wasCalled()  // If this succeeds...
verify(bird.fly()).wasCalled()  // ...this also succeeds
```

For methods overloaded by return type, you should help the compiler by specifying the type returned.

```swift
/* Bird.swift */
protocol Bird {
  func getMessage<T>() -> T
  func getMessage() -> String
  func getMessage() -> StaticString
}

/* Tests.swift */
verify(bird.getMessage()).returning(String.self).wasCalled()
```

### Resetting Mocks

Occasionally it’s necessary to remove stubs or clear recorded invocations.

```swift
reset(bird)                 // Removes all stubs and recorded invocations
clearStubs(on: bird)        // Only removes stubs
clearInvocations(on: bird)  // Only removes recorded invocations
```

### Argument Matching

Argument matchers allow wildcard matching of arguments during stubbing or verification.

```swift
any()                    // Matches any value
any(of: 1, 2, 3)         // Matches any value in {1, 2, 3}
any(where: { $0 > 42 })  // Matches any number greater than 42
notNil()                 // Matches any non-nil value
```

For methods overloaded by parameter type (such as with generics), using a matcher may cause ambiguity for 
the compiler. You can help the compiler by specifying an explicit type in the matcher.

```swift
any(Int.self)
any(Int.self, of: 1, 2, 3)
any(Int.self, where: { $0 > 42 })
notNil(String?.self)
```

You can also match elements or keys within collection types.

```swift
any(containing: 1, 2, 3)  // Matches any collection with values {1, 2, 3}
any(keys: "a", "b", "c")  // Matches any dictionary with keys {"a", "b", "c"}
any(count: atMost(42))    // Matches any collection with at most 42 elements
notEmpty()                // Matches any non-empty collection
```

If you provide a concrete instance of an `Equatable` type, argument values will be compared using equality. 
Types that don’t conform to `Equatable` will be compared by reference.

```swift
// Many Swift stdlib types such as `String` conform to `Equatable`
verify(bird.setName("Ryan")).wasCalled()
```

## Supporting Source Files

Add supporting source files to mock inherited types defined outside of your project. You should always provide 
supporting source files when working with system frameworks like `UIKit` or precompiled external dependencies.

```swift
/* MyEquatableProtocol.swift */
protocol MyEquatableProtocol: Equatable {
  // ...
}

/* MockingbirdSupport/Swift/Equatable.swift */
public protocol Equatable {
  static func == (lhs: Self, rhs: Self) -> Bool
}
```

### Setup

Mockingbird includes supporting source files for `Foundation`, `UIKit`, and other common system frameworks.
For automatic integration, simply copy the `MockingbirdSupport` folder into your project’s source root. 

If you share supporting source files between projects, you can specify a custom `--support` directory when 
running the CLI installer or generator.

### Structure

Supporting source files should be contained in a directory that matches the module name. You can define 
submodules and transitive dependencies by nesting directories.

```
MockingbirdSupport/
├── Foundation/
│   └── ObjectiveC/
│       └── NSObject.swift
└── Swift/
    └── Codable.swift
    └── Comparable.swift
    └── Equatable.swift
    └── Hashable.swift
```

With the above file structure, `NSObject` can be imported from both the `Foundation` and `ObjectiveC` modules.

## Performance

Mockingbird was built to be fast. Its current baseline is under 1 ms per generated mock. See 
[Performance](Documentation/Performance.md) for benchmarks and methodology.

## Mockingbird CLI

### Generate

Generate mocks for a set of targets in a project.

`mockingbird generate` 

| Option | Default Value | Description | 
| --- | --- | --- |
| `--project` | [`(inferred)`](#--project) | Path to your project’s `.xcodeproj` file. |
| `--targets` | `$TARGET_NAME` | List of target names to generate mocks for. |
| `--srcroot` | `$SRCROOT` | The folder containing your project’s source files. |
| `--outputs` | [`(inferred)`](#--outputs) | List of mock output file paths for each target. |
| `--support` | [`(inferred)`](#--support) | The folder containing [supporting source files](#). |
| `--condition` | `(none)` | [Compilation condition](https://docs.swift.org/swift-book/ReferenceManual/Statements.html#ID538) to wrap all generated mocks in, e.g. `DEBUG`. |

| Flag | Description |
| --- | --- |
| `--disable-module-import` | Omit `@testable import <module>` from generated mocks. |
| `--only-protocols` | Only generate mocks for protocols. |
| `--disable-swiftlint` | Disable all SwiftLint rules in generated mocks. |
| `--disable-cache` | Ignore cached mock information stored on disk. |

### Install

Set up a destination (unit test) target.

`mockingbird install`

| Option | Default Value | Description |
| --- | --- | --- |
| `--targets` | *(required)* | List of target names that should generate mocks. |
| `--destination` | *(required)* | The target name where the Run Script Phase will be installed. |
| `--project` | [`(inferred)`](#--project) | Your project’s `.xcodeproj` file. |
| `--srcroot` |  `<project>/../` | The folder containing your project’s source files. |
| `--outputs` | [`(inferred)`](#--outputs) | List of mock output file paths for each target. |
| `--support` | [`(inferred)`](#--support) | The folder containing [supporting source files](#). |
| `--condition` | `(none)` | [Compilation condition](https://docs.swift.org/swift-book/ReferenceManual/Statements.html#ID538) to wrap all generated mocks in, e.g. `DEBUG`. |
| `--loglevel` |  `(none)` | The log level to use when generating mocks, `quiet` or `verbose` |

| Flag | Description |
| --- | --- |
| `--ignore-existing` | Don’t overwrite existing Run Scripts created by Mockingbird CLI. |
| `--asynchronous` | Generate mocks asynchronously in the background when building. |
| `--only-protocols` | Only generate mocks for protocols. |
| `--disable-swiftlint` | Disable all SwiftLint rules in generated mocks. |
| `--disable-cache` | Ignore cached mock information stored on disk. |

### Uninstall

Remove Mockingbird from a (unit test) target.

`mockingbird uninstall`

| Option | Default Value | Description |
| --- | --- | --- |
| `--targets` | *(required)* | List of target names to uninstall the Run Script Phase. |
| `--project` | [`(inferred)`](#--project) | Your project’s `.xcodeproj` file. |
| `--srcroot` |  `<project>/../` | The folder containing your project’s source files. |

### Global Options

| Flag | Description |
| --- | --- |
| `--verbose` | Log all errors, warnings, and debug messages. |
| `--quiet` | Only log error messages. |

### Inferred Paths

#### `--project`

Mockingbird will first check if the environment variable `$PROJECT_FILE_PATH` was set (usually by an Xcode build 
context). It will then perform a shallow search of the current working directory for an `.xcodeproj` file. If multiple
`.xcodeproj` files exist then you must explicitly provide a project file path.

#### `--outputs`

By default Mockingbird will generate mocks into the `$(SRCROOT)/MockingbirdMocks` directory with the file name 
`$(PRODUCT_MODULE_NAME)Mocks.generated.swift`.

#### `--support`

Mockingbird will recursively look for [supporting source files](#supporting-source-files) in the
`$(SRCROOT)/MockingbirdSupport` directory.

## Resources

- [Slack channel](https://slofile.com/slack/birdopensource)
- [Example unit test](/MockingbirdTests/Example/TreeTests.swift)
- [CocoaPods tutorial + example project](https://github.com/andrewchang-bird/MockingbirdCocoaPodsExample)
