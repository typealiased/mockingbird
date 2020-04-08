# Mockingbird Carthage Example

A minimal example of [Mockingbird](https://github.com/birdrides/mockingbird) integrated into an Xcode project using
Carthage.

Having issues setting up Mockingbird? Join the [Slack channel](https://slofile.com/slack/birdopensource) or
[file an issue](https://github.com/birdrides/mockingbird/issues/new/choose).

## Tutorial

### Create the Xcode Project

Open Xcode and create an iOS Single View App with the name `iOSMockingbirdExample-Carthage`. Make sure
that the checkbox labeled “Include Unit Tests” is selected.

### Configure Carthage

Create the Cartfile in the Xcode project root directory.

```bash
$ cd iOSMockingbirdExample-Carthage
$ touch Cartfile
```

Add Mockingbird as a dependency in the Cartfile.

```ruby
$ echo 'github "birdrides/mockingbird" ~> 0.11.0' >> Cartfile
```

### Install Mockingbird

Build the framework using Carthage.

```bash
$ carthage update --platform ios
$ open Carthage/Build/iOS
```

Link the built `Mockingbird.framework` to the test target, making sure to add the framework to a new Copy Files
build phase with the destination set to `Frameworks`.

![Test target build phases](/Documentation/Assets/test-target-build-phases.png)

Then install the CLI.

```bash
$ cd Carthage/Checkouts/mockingbird
$ make install-prebuilt
```

Configure the test target by using the CLI.

```bash
$ mockingbird install \
  --target iOSMockingbirdExample-CarthageTests \
  --source iOSMockingbirdExample-Carthage
```

Finally, download the starter supporting source files into your project root.

```bash
$ curl -Lo \
  'MockingbirdSupport.zip' \
  'https://github.com/birdrides/mockingbird/releases/download/0.11.0/MockingbirdSupport.zip'
$ unzip -o 'MockingbirdSupport.zip'
$ rm -f 'MockingbirdSupport.zip'
```

### Run Tests

Open the Xcode project.

```bash
$ open iOSMockingbirdExample-Carthage.xcodeproj
```

Take a peek at the example test and sources and then run the tests (⌘+U).:

- [`TreeTests.swift`](iOSMockingbirdExample-CarthageTests/TreeTests.swift)
- [`Tree.swift`](iOSMockingbirdExample-Carthage/Tree.swift)
- [`Bird.swift`](iOSMockingbirdExample-Carthage/Bird.swift)

Bonus: look at the contents of 
[`.mockingbird-ignore`](iOSMockingbirdExample-CarthageTests/.mockingbird-ignore). 
