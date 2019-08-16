# Mockingbird

[![Swift Package Manager](https://img.shields.io/badge/swift%20package%20manager-compatible-brightgreen.svg)](https://swift.org/package-manager/)

Mockingbird is a convenient mocking framework for Swift.

```swift
let bird = BirdMock()
given(bird.canFly.get()) ~> true    // Given the bird can fly
PalmTree(containing: bird).shake()  // When the palm tree is shaken
verify(bird.fly()).wasCalled()      // Then the bird flies away
```
---

## Installation

### Carthage

Add Mockingbird to your `Cartfile`.

```
github "birdrides/mockingbird" ~> 0.0.1
```

Then download and install the latest `Mockingbird.pkg` from [Releases](https://github.com/birdrides/mockingbird/releases).

### CocoaPods

CocoaPods support coming soon™

### Swift Package Manager

Add Mockingbird as a dependency in your `Package.swift` file.

```swift
dependencies: [
  .package(url: "https://github.com/birdrides/mockingbird.git", .upToNextMajor(from: "0.0.1"))
]
```

Then download and install the latest `Mockingbird.pkg` from [Releases](https://github.com/birdrides/mockingbird/releases).

### From Source

Clone the repository and build the `MockingbirdFramework` scheme for the desired platform. Drag the built 
`MockingbirdFramework.framework` product into your project and link the library.

```bash
git clone https://github.com/birdrides/mockingbird.git
cd mockingbird
open Mockingbird.xcodeproj
```

Then install the Mockingbird command line interface.

```bash
make install
```

## Setup

Mockingbird generates mocks using the `mockingbird` command line tool which can be integrated into your
build process in many different ways.

### Automatic Integration

Mockingbird CLI can automatically add a build step to generate mocks in the background whenever the specified 
targets are compiled.

```bash
mockingbird install --project <xcodeproj_path> --targets <comma_separated_targets>
```

### Manual Integration

If you use a project or workspace generator such as [XcodeGen](https://github.com/yonaskolb/XcodeGen) you 
may need to add a Run Script Phase to generate mocks. See [Mockingbird CLI - Generate](#generate) for all 
generator options. 

```bash
mockingbird generate &
```

## Usage

### Importing Mocks

By default, Mockingbird will generate target mocks into `Mockingbird/Mocks/` under the project’s source root 
directory. (Specify a custom location to generate mocks for each target using the `outputs` CLI option.)

Unit test targets that import a module with a corresponding mocks file should include the mocks file under Build
Phases → Compile Sources.

![Build Phases → Compile Sources](Documentation/Assets/test-target-compile-sources.png)

### Mock Initialization

Mockingbird adds the `Mock` suffix to mocks that it generates, providing the same methods, variables, and 
initializers as the original type. 

```swift
let bird = BirdMock()
```

### Stubbing

Stubbing allows mocks to return custom results or perform an operation.

```swift
given(bird.chirp(volume: 10)) ~> true
given(bird.chirp(volume: any())) ~> true    // Matches any volume
given(bird.chirp(volume: notNil())) ~> true // Matches any non-nil volume
```

You can also stub variables.

```swift
given(bird.name.get()) ~> "Big Bird"
given(bird.name.set(any())) ~> { invocation in
  print(invocation.arguments.first)
}
```

And conveniently stub multiple methods with the same return type.

```swift
given(
  bird1.name.get(),
  bird2.name.get(),
  bird3.name.get()
) ~> "Big Bird"
```

### Verification

Mocks keep a record of invocations that it receives which can then be verified.

```swift
verify(bird.chirp(volume: 50)).wasCalled()
```

You can also conveniently verify multiple invocations at once (order doesn’t matter).

```swift
verify(
  bird.name.get(),
  bird.chirp(volume: any()),
  bird.fly(to: notNil())
).wasCalled()
```

It’s possible to verify that an invocation was called a specific number of times with a call matcher.

```swift
verify(bird.name.get()).wasNeverCalled()             // n = 0
verify(bird.name.get()).wasCalled(exactly(10))       // n = 10
verify(bird.name.get()).wasCalled(atLeast(10))       // n ≥ 10
verify(bird.name.get()).wasCalled(atMost(10))        // n ≤ 10
verify(bird.name.get()).wasCalled(not(exactly(10)))  // n ≠ 10
verify(bird.name.get()).wasCalled(
  atLeast(5).or(atMost(10))                          // 5 ≤ n ≤ 10
)
```

Sometimes you need to perform custom checks on received parameters by using an argument captor.

```swift
let nameCaptor = ArgumentCaptor<String>()
verify(bird.name.set(nameCaptor)).wasCalled()
XCTAssertEqual(nameCaptor.value, "Big Bird")   // Last value received 
XCTAssertEqual(nameCaptor.allValues.count, 1)  // All values received
```

Verifying doesn’t remove recorded invocations, so it’s safe to call verify multiple times (even if not recommended).

```swift
verify(bird.name.get()).wasCalled() // If this succeeds...
verify(bird.name.get()).wasCalled() // ...this also succeeds
```

### Resetting Mocks

Occasionally it’s necessary to remove stubs or clear recorded invocations.

```swift
reset(bird) // Removes all stubs and recorded invocations
clearStubs(on: bird) // Only removes stubs
clearInvocations(on: bird) // Only removes recorded invocations
```
 
## Mockingbird CLI

### Generate

Generate mocks for a set of targets in a project.

`mockingbird generate` 
* `--project <xcodeproj_path>` Path to the Xcode project file. Defaults to the `PROJECT_FILE_PATH` environment variable set during builds.
* `--srcroot <source_root_path>` Path to the directory containing the project’s source files. Defaults to the `SRCROOT` environment variable set during builds or to the parent directory of `<xcodeproj_path>`.
* `--targets <comma_separated_targets>` Comma-separated list of target names to mock. For better performance, batch mock generation by specifying multiple targets. Defaults to the `TARGET_NAME` environment variable set during builds.
* `--outputs <comma_separated_output_paths>` Comma-separated list of custom file paths to store generated mocks for each target. The number of `outputs` should match the number of `targets`. Defaults to `<src_root>/Mockingbird/Mocks/<target_name>Mocks.generated.swift`.
* `--preprocessor <preprocessor_expression>` Preprocessor expression to wrap all generated mocks in. For example, specifying `DEBUG` will add `#if DEBUG ... #endif` to every mock file. Defaults to not adding a preprocessor expression.
* `--disable-module-import` Whether `@testable import <target_name>` should be omitted from generated mocks. Add this flag if mocks are included in targets instead of in test targets. Consider specifying a `preprocessor` expression when using the `no-module-import` option.

### Install

Starts automatically calling `mockingbird generate` when building any of the provided targets. Adds a custom 
Run Script Phase to each target.

`mockingbird install`
* `--project <xcodeproj_path>` Path to the Xcode project file.
* `--srcroot <source_root_path>` Path to the directory containing the project’s source files. Defaults to the parent directory of `<xcodeproj_path>`.
* `--targets <comma_separated_targets>` Comma-separated list of target names that will start automatically generating mocks.
* `--outputs <comma_separated_output_paths>` Comma-separated list of custom file paths to store generated mocks for each target. The number of `outputs` should match the number of `targets`. Defaults to `<src_root>/Mockingbird/Mocks/<target_name>Mocks.generated.swift`.
* `--preprocessor` Preprocessor expression to wrap all generated mocks in. For example, specifying `DEBUG` will add `#if DEBUG ... #endif` to every mock file. Defaults to not adding a preprocessor expression.
* `--override` Whether to re-install the Run Script Phase for each target in `targets`.
* `--synchronous` Whether building each target waits until mock generation completes. Add this flag if mocks are included in targets instead of in test targets. See also the `disable-module-import` flag.

### Uninstall

Stops automatically calling `mockingbird generate` when building.

`mockingbird uninstall`
* `--project <xcodeproj_path>` Path to the Xcode project file.
* `--targets <comma_separated_targets>` Comma-separated list of target names that will stop automatically generating mocks.
