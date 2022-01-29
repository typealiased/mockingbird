# Carthage Quick Start Guide

Integrate Mockingbird into a Carthage Xcode project.

### 1. Add the framework

Add the framework to your `Cartfile`.

```
github "birdrides/mockingbird" ~> 0.20
```

In your project directory, build the framework and link it to your test target.

```console
$ carthage update --use-xcframeworks
```

### 2. Configure a test target

Configure a test target to automatically call the generator before each test run.

```console
$ Carthage/Checkouts/mockingbird/mockingbird configure MyAppTests -- --targets MyApp MyLibrary1 MyLibrary2
```

The `--targets` option after the floating double-dash tells the generator which source targets should be mocked. There are a number of options available such as only mocking protocols and disabling all SwiftLint rules:

```console
$ Carthage/Checkouts/mockingbird/mockingbird configure MyAppTests -- \
    --targets MyApp MyLibrary1 MyLibrary2
    --only-protocols \
    --disable-swiftlint
```

If you don’t want to add a build phase to a test target, you can also manually run the generator—but this isn’t the recommended workflow.

```console
$ Carthage/Checkouts/mockingbird/mockingbird generate \
    --testbundle MyAppTests \
    --targets MyApp MyLibrary1 MyLibrary2 \
    --output-dir /path/to/MyAppTests
```

See <doc:Generate> and <doc:Configure> for all available options.

### Recommended

Exclude generated files, binaries, and caches from source control to prevent merge conflicts.

```bash
# Generated
*.generated.swift

# Binaries
Carthage/Checkouts/mockingbird/bin/

# Caches
**/*.xcodeproj/MockingbirdCache/
```

### Need Help?

- [#mockingbird Slack channel](https://join.slack.com/t/birdopensource/shared_invite/zt-wogxij50-3ZM7F8ZxFXvPkE0j8xTtmw)
- [Carthage example project](https://github.com/birdrides/mockingbird/tree/master/Examples/CarthageExample)
- <doc:Common-Problems>
