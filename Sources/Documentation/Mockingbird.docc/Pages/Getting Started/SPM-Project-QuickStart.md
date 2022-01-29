# SPM Project Quick Start Guide

Integrate Mockingbird into a SwiftPM Xcode project.

## Overview

This guide is for Xcode projects that use SwiftPM to manage dependencies. If you have a SwiftPM package, please see the <doc:SPM-Package-QuickStart> instead.

### 1. Add the framework

Add the framework to your Xcode project:

1. Navigate to **File › Add Packages…** and enter “https://github.com/birdrides/mockingbird”
2. Change **Dependency Rule** to **Up to Next Minor Version** and enter “0.20.0”
3. Click **Add Package**
4. Select your test target and click **Add Package**

### 2. Configure the test target

In your project directory, resolve the derived data path. This can take a few moments.

```console
$ DERIVED_DATA="$(xcodebuild -showBuildSettings | sed -n 's|.*BUILD_ROOT = \(.*\)/Build/.*|\1|p')"
```

Configure the test target to automatically call the generator before each test run.

```console
$ "${DERIVED_DATA}/SourcePackages/checkouts/mockingbird/mockingbird" configure MyAppTests -- --targets MyApp MyLibrary1 MyLibrary2
```

The `--targets` option after the floating double-dash tells the generator which source targets should be mocked. There are a number of options available such as only mocking protocols and disabling all SwiftLint rules:

```console
$ "${DERIVED_DATA}/SourcePackages/checkouts/mockingbird/mockingbird" configure MyAppTests -- \
    --targets MyApp MyLibrary1 MyLibrary2
    --only-protocols \
    --disable-swiftlint
```

If you don’t want to add a build phase to the test target, you can also manually run the generator—but this isn’t the recommended workflow.

```console
$ "${DERIVED_DATA}/SourcePackages/checkouts/mockingbird/mockingbird" generate \
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

# Caches
**/*.xcodeproj/MockingbirdCache/
```

### Need Help?

- [#mockingbird Slack channel](https://join.slack.com/t/birdopensource/shared_invite/zt-wogxij50-3ZM7F8ZxFXvPkE0j8xTtmw)
- [SwiftPM example project](https://github.com/birdrides/mockingbird/tree/master/Examples/SPMProjectExample)
- <doc:Common-Problems>
