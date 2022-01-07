# CocoaPods Quick Start Guide

Integrate Mockingbird into a CocoaPods Xcode project.

### 1. Add the framework

Add the framework to a test target in your `Podfile`, making sure to include the `use_frameworks!` option.

```ruby
target 'MyAppTests' do
  use_frameworks!
  pod 'MockingbirdFramework', '~> 0.19'
end
```

In your project directory, initialize the pod.

```console
$ pod install
```

### 2. Configure the test target

Configure the test target to automatically call the generator before each test run.

```console
$ Pods/MockingbirdFramework/mockingbird configure MyAppTests -- --targets MyApp MyLibrary1 MyLibrary2
```

The `--targets` option after the floating double-dash tells the generator which source targets should be mocked. There are a number of options available such as only mocking protocols and disabling all SwiftLint rules:

```console
$ Pods/MockingbirdFramework/mockingbird configure MyAppTests -- \
    --targets MyApp MyLibrary1 MyLibrary2
    --only-protocols \
    --disable-swiftlint
```

If you don’t want to add a build phase to the test target, you can also manually run the generator—but this isn’t the recommended workflow.

```console
$ Pods/MockingbirdFramework/mockingbird generate \
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
Pods/MockingbirdFramework/mockingbird/bin/

# Caches
**/*.xcodeproj/MockingbirdCache/
```

### Need Help?

- [#mockingbird Slack channel](https://join.slack.com/t/birdopensource/shared_invite/zt-wogxij50-3ZM7F8ZxFXvPkE0j8xTtmw)
- [CocoaPods example project](https://github.com/birdrides/mockingbird/tree/master/Examples/CocoaPodsExample)
- <doc:Common-Problems>
