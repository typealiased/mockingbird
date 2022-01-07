# Local Development

Build and run Mockingbird from source.

### Environment Setup

Clone the repo.

```console
$ git clone https://github.com/birdrides/mockingbird
$ cd mockingbird
```

Load the preset Xcode schemes. This step is optional but recommended.

```console
$ Sources/MockingbirdAutomationCli/buildAndRun.sh configure load
```

Open the Xcode project in Xcode 13.2 or later.

```console
$ open Mockingbird.xcodeproj
```

### Building from Source

Mockingbird products can be built from source using either Xcode or Swift Package Manager. The build automation script provides a straightforward way to build artifacts and optionally archive them for distribution.

#### Generator

Use the build automation script which outputs a binary into `.build/release/mockingbird`.

```console
$ Sources/MockingbirdAutomationCli/buildAndRun.sh build generator
```

You can also bundle the binary with the necessary libraries.

```console
$ Sources/MockingbirdAutomationCli/buildAndRun.sh build generator --archive mockingbird.zip
```

#### Framework

Use the build automation script which uses Carthage to create a fat XCFramework bundle containing all supported platforms.

```console
$ Sources/MockingbirdAutomationCli/buildAndRun.sh build framework
```

For quicker builds, you can specify the target platforms to build against.

```console
$ Sources/MockingbirdAutomationCli/buildAndRun.sh build framework --platforms iOS macOS
```
