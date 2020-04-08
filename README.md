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

## Overview

Mockingbird uses code generation to create overridable mocks and stubs with similar semantics to [Mockito](https://site.mockito.org).

At a high level, Mockingbird consists of two main components: the generator and the testing framework. Before each
test bundle compilation, the generator creates an intermediary layer that implements protocols and subclasses
classes. The testing framework provides hooks into the intermediary layer for mocking, stubbing, and verification
during test runs.

Let’s start with a simple example!

```swift
protocol Bird {
  var canFly: Bool { get }
  func fly()
}

class Tree {
  let bird: Bird
  
  init(with bird: Bird) {
    self.bird = bird
  }
  
  func shake() {
    guard bird.canFly else { return }
    bird.fly()
  }
}

func testShakingTreeCausesBirdToFly() {
  // Given
  let bird = mock(Bird.self)
  let tree = Tree(with: bird) // a tree with a bird
  given(bird.getCanFly()) ~> true // that can fly
  
  // When
  tree.shake() // the tree is shaken
  
  // Then
  verify(bird.fly()).wasCalled() // the bird flies away
}
```

## Installation

### CocoaPods

Add the framework to a test target in your `Podfile`, making sure to include the `use_frameworks!` option.

```ruby
target 'MyTestTarget' do
  use_frameworks!
  pod 'MockingbirdFramework', '~> 0.11.0'
end
```

Initialize the pod.

```bash
$ pod install
```

Then install the CLI.

```bash
$ cd Pods/MockingbirdFramework
$ make install-prebuilt
```

### Carthage

Add the framework to your `Cartfile`.

```
github "birdrides/mockingbird" ~> 0.11.0
```

Build the framework using Carthage and [link it to your test target](Documentation/LinkingTestTargets.md), making
sure to add the framework to a Copy Files build phase with the destination set to `Frameworks`.

```bash
$ carthage update --no-build
$ cp Carthage/Checkouts/mockingbird/Scripts/carthage-update.sh ./
$ ./carthage-update.sh
```

<details><summary>Upcoming changes in Mockingbird 0.11.0</summary>

```bash
$ carthage update
```

</details>

Then install the CLI.

```bash
$ cd Carthage/Checkouts/mockingbird
$ make install-prebuilt
```

### Swift Package Manager

Add `https://github.com/birdrides/mockingbird` as a dependency and link it to your test target.

Then download and install the
[latest CLI from Releases](https://github.com/birdrides/mockingbird/releases/download/0.11.0/MockingbirdCli.pkg).

### From Source

Clone the repository and build the `MockingbirdFramework` scheme for the desired platform. Drag the built 
`Mockingbird.framework` product into your project and 
[link it to your test target](Documentation/LinkingTestTargets.md).

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

Use the CLI to configure a test target, listing all source targets that should generate mocks before each build. Below,
mock types will be generated for the `Bird` app target and the `BirdManagers` framework target, which can then be
used in `BirdTests`.

```bash
$ mockingbird install \
  --target BirdTests \
  --sources Bird BirdManagers
```

Need to [set up your project manually](Documentation/ManualSetup.md)?

### System Framework Compatibility

Download the latest
[starter supporting source files](https://github.com/birdrides/mockingbird/releases/download/0.11.0/MockingbirdSupport.zip)
and place the `MockingbirdSupport` folder in the root directory of your project. This provides basic compatibility
with system frameworks such as `UIKit`. See [Supporting Source Files](#supporting-source-files) for more
information.

### Excluding Files

You can exclude unwanted or problematic sources from being mocked by adding a `.mockingbird-ignore` file. 
Mockingbird follows the same pattern format as [`.gitignore`](https://git-scm.com/docs/gitignore#_pattern_format) 
and scopes ignore files to their enclosing directory.

## Usage

Example projects demonstrating basic usage of Mockingbird:

- [CocoaPods tutorial + example project](/Examples/iOSMockingbirdExample-CocoaPods)
- [Carthage tutorial + example project](/Examples/iOSMockingbirdExample-Carthage)

### Mocking

Mock types can be passed in place of the original type and are suffixed with `Mock`. Avoid explicitly coercing mock
types into their supertype, as this breaks stubbing and verification.

#### Protocol Mocks

Note that the initialized mock type is `BirdMock` instead of `Bird`.

```swift
let bird: BirdMock = mock(Bird.self)  // The concrete type is `BirdMock`
let inferredBird = mock(Bird.self)    // but type inference also works
```

#### Class Mocks

Initialize concrete class mocks using the `initialize` method. Keep in mind that class mocks rely on subclassing
which has certain limitations, so consider using protocol mocks whenever possible.

```swift
class Bird {
  let name: String
  init(named name: String) { self.name = name }
}
let bird = mock(Bird.self).initialize(named: "Ryan")
```

#### Dummy Objects

Occasionally it’s desirable to initialize objects that are passed around as arguments but never used as mocks or
stubs.

```swift
let tree = Tree(with: dummy(Bird.self))
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
given(bird.getName()) ~> "Ryan"
given(bird.setName(any())) ~> { print($0) }
```

Getters can be stubbed to automatically save and return values.

```swift
given(bird.getName()) ~> lastSetValue(initial: "One")
bird.name = "Two"
assert(bird.name == "Two")
```

Use a closure to implement complex stubs that contain logic or that interact with arguments. 

```swift
given(bird.chirp(volume: any(), callback: any())) ~> { volume, callback in
  callback(volume * 2)
}
```

Closures also allow for stubbing methods that can throw.

```swift
given(bird.chirp(volume: any())) ~> { volume in
  if volume > 42 {
    throw BirdError.invalidVolume
  }
}
```

It’s possible to stub multiple methods with the same return type in a single call.

```swift
given(
  birdOne.getName(),
  birdTwo.getName()
) ~> "Ryan"
```

### Verification

Verification lets you assert that a mock received a particular invocation during its lifetime.

```swift
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

To enforce the relative order of invocations, use an `inOrder` block.

```swift
// Check that `fly` was called before `chirp`
inOrder {
  verify(bird.fly()).wasCalled()
  verify(bird.chirp()).wasCalled()
}
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
protocol Bird {
  func getMessage<T>() -> T
  func getMessage() -> String
  func getMessage() -> StaticString
}

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

Match arguments received by mocks for stubbing and verification. The parameter type must explicitly conform to
`Equatable` or the arguments will be compared by reference.

```swift
// Many Swift standard library types such as `String` conform to `Equatable`
verify(bird.setName("Ryan")).wasCalled()

// Types that explicitly conform to `Equatable` work out of the box
struct Fruit: Equatable {
  let size: Int
}
verify(bird.eat(Fruit(size: 42))).wasCalled()

// Classes can be safely compared by reference
class Tree {
  init(with bird: Bird) {
    bird.home = self
  }
}
let tree = Tree(with: bird)
verify(bird.setHome(tree)).wasCalled()
```

Argument matchers allow wildcard and custom matching of arguments.

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

Mathematical operations on floating point numbers can cause unexpected behavior, so consider using `around` to
fuzzily match floating point arguments with some tolerance.

```swift
around(10.0, tolerance: 0.01)
```

## Supporting Source Files

Add supporting source files to mock inherited types defined outside of your project. You should always provide 
supporting source files when working with system frameworks like `UIKit` or precompiled external dependencies.

```swift
/* MockingbirdSupport/Swift/Codable.swift */

public protocol Encodable {
  func encode(to encoder: Encoder) throws
}

public protocol Decodable {
  init(from decoder: Decoder) throws
}

public typealias Codable = Decodable & Encodable
```

### Starter Pack

Mockingbird includes starter supporting source files for `Foundation`, `UIKit`, and other common system
frameworks. Download the latest
[starter supporting source files](https://github.com/birdrides/mockingbird/releases/download/0.11.0/MockingbirdSupport.zip)
and place the `MockingbirdSupport` folder in the root directory of your project.

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
    ├── Codable.swift
    ├── Comparable.swift
    ├── Equatable.swift
    └── Hashable.swift
```

With the above file structure, `NSObject` can be imported from both the `Foundation` and `ObjectiveC` modules.

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
| `--disable-relaxed-linking` | Only search explicitly imported modules. |

### Install

Set up a destination (unit test) target.

`mockingbird install`

| Option | Default Value | Description |
| --- | --- | --- |
| `--target` | *(required)* | The target name where Mockingbird will be installed. |
| `--sources` | *(required)* | List of target names to generate mocks for. |
| `--project` | [`(inferred)`](#--project) | Your project’s `.xcodeproj` file. |
| `--srcroot` |  `<project>/../` | The folder containing your project’s source files. |
| `--outputs` | [`(inferred)`](#--outputs) | List of mock output file paths for each target. |
| `--support` | [`(inferred)`](#--support) | The folder containing [supporting source files](#). |
| `--condition` | `(none)` | [Compilation condition](https://docs.swift.org/swift-book/ReferenceManual/Statements.html#ID538) to wrap all generated mocks in, e.g. `DEBUG`. |
| `--loglevel` |  `(none)` | The log level to use when generating mocks, `quiet` or `verbose` |

| Flag | Description |
| --- | --- |
| `--preserve-existing` | Don’t overwrite previously installed configurations. |
| `--asynchronous` | Generate mocks asynchronously in the background when building. |
| `--only-protocols` | Only generate mocks for protocols. |
| `--disable-swiftlint` | Disable all SwiftLint rules in generated mocks. |
| `--disable-cache` | Ignore cached mock information stored on disk. |
| `--disable-relaxed-linking` | Only search explicitly imported modules. |

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

## Troubleshooting

### Mocks don’t exist or are out of date 

Mocks are generated when the test target is built and run. Run tests once and check that generated mock files
appear in `$(SRCROOT)/MockingbirdMocks` and are not empty. If nothing is generated or the files contain no
mocks then something is wrong with the installation.

- [Check the configured build phase](#debugging-a-configured-build-phase)
- [Check the generator logs](#debugging-the-generator)

### Generated mock does not compile

Ensure that the project has [supporting source files](#supporting-source-files). Common compiler errors from not
having supporting source files:

- `MyTypeMock` does not conform to protocol `NSObjectProtocol`
- Superclass must appear first in the inheritance clause
- `Type` can only be used as a generic constraint because it has `Self` or associated type requirements

If there are supporting source files and the error is related to inheritance, you may need to add a new supporting
source file with definitions for the inherited type.

If the issue is unrelated to inheritance, you may have found a [generator bug](#debugging-the-generator). If all else
fails, [exclude the problematic source file](#excluding-files) and
[file an issue](https://github.com/birdrides/mockingbird/issues/new/choose).

### Editor placeholder in source file warning

Generated mocks will contain the editor placeholder `__UnknownType__` for types that could not be inferred.
Help the generator by adding
[explicit type annotations](https://docs.swift.org/swift-book/ReferenceManual/Types.html#ID446) to the definition.

### Cannot call stubbing or verification functions

Ensure that Mockingbird is imported at the top of the test file.

### Expression type is ambiguous without more context error

This usually happens when trying to stub or verify a mock that was explicitly coerced into its supertype. Make sure
the variable storing the mock has the concrete mock type, e.g. `MyTypeMock` instead of `MyType`.

### Tests crash with an unable to load framework, image not found error

Link Mockingbird and ensure that it’s included in the test bundle by
[adding it to the Copy Files build phase](Documentation/LinkingTestTargets.md).

### Unable to stub or verify methods with arguments

Ensure that all parameter types explicitly conform to `Equatable` or work when compared by reference. Note that
`struct` types that implicitly conform to `Equatable` have undefined behavior. Use a wildcard
[argument matcher](#argument-matching) such as `any()` or `any(where:)` to match non-equatable or implicitly
equatable types.

### Debugging a configured build phase

Open the test target
[build phase](https://developer.apple.com/library/archive/documentation/ToolsLanguages/Conceptual/Xcode_Overview/WorkingwithTargets.html)
and expand the build phase named `Generate Mockingbird Mocks`. If no phase exists or the listed targets seem incorrect, [set up](#setup) the test target again.

### Debugging the generator

Open the
[Xcode report navigator](https://developer.apple.com/library/archive/documentation/ToolsLanguages/Conceptual/Xcode_Overview/NavigatingYourWorkspace.html)
and select the Build entry for the most recent test run. Find the log message for
`Run custom shell script 'Generate Mockingbird Mocks'` and check for any relevant warnings or errors.
To increase the log verbosity, specify `--verbose` in the
[configured build phase](#debugging-a-configured-build-phase).

## Additional Resources

- [Slack channel](https://slofile.com/slack/birdopensource)
- [CocoaPods tutorial + example project](/Examples/iOSMockingbirdExample-CocoaPods)
- [Carthage tutorial + example project](/Examples/iOSMockingbirdExample-Carthage)
