# Mockingbird Carthage Example

A minimal example of [Mockingbird](https://github.com/birdrides/mockingbird) integrated into an Xcode project using
Carthage.

Having issues setting up Mockingbird? Join the [Slack channel](https://slofile.com/slack/birdopensource) or
[file an issue](https://github.com/birdrides/mockingbird/issues/new/choose).

## Tutorial

### Configure Carthage

Create the Cartfile in the Xcode project root directory.

```console
$ cd iOSMockingbirdExample-Carthage
$ touch Cartfile
```

Add Mockingbird as a dependency in the Cartfile.

```ruby
$ echo 'github "birdrides/mockingbird" ~> 0.13' >> Cartfile
```

### Install Mockingbird

Build the framework and link the built `Mockingbird.framework` to the test target, making sure to add the
framework to
[a new Copy Files build phase](https://github.com/birdrides/mockingbird/wiki/Linking-Test-Targets) with the
destination set to `Frameworks`.

```console
$ carthage update --platform ios
$ open Carthage/Build/iOS
```

Then install the CLI.

```console
$ (cd Carthage/Checkouts/mockingbird && make install-prebuilt)
```

Configure the test target.

```console
$ mockingbird install \
  --target iOSMockingbirdExample-CarthageTests \
  --source iOSMockingbirdExample-Carthage
```

Finally, download the starter supporting source files into your project root.

```console
$ mockingbird download starter-pack
```

### Run Tests

Open the Xcode project.

```console
$ open iOSMockingbirdExample-Carthage.xcodeproj
```

Take a peek at the example test and sources and then run the tests (⌘+U).

- [`TreeTests.swift`](iOSMockingbirdExample-CarthageTests/TreeTests.swift)
- [`Tree.swift`](iOSMockingbirdExample-Carthage/Tree.swift)
- [`Bird.swift`](iOSMockingbirdExample-Carthage/Bird.swift)

Bonus: 
- [`.mockingbird-ignore`](iOSMockingbirdExample-Carthage/.mockingbird-ignore)
- [`.gitignore`](.gitignore)
