# SPM Package Quick Start Guide

Integrate Mockingbird into a SwiftPM package.

## Overview

This guide is for SwiftPM packages with a `Package.swift` manifest. If you have an Xcode project that uses SwiftPM, please see the <doc:SPM-Project-QuickStart> instead.

### 1. Add the framework

Add Mockingbird as a package and test target dependency in your `Package.swift` manifest.

```swift
let package = Package(
  name: "MyPackage",
  dependencies: [
    .package(name: "Mockingbird", url: "https://github.com/birdrides/mockingbird.git", .upToNextMinor(from: "0.20.0")),
  ],
  targets: [
    .testTarget(name: "MyPackageTests", dependencies: ["Mockingbird"]),
  ]
)
```

In your package directory, initialize the dependency.

```console
$ swift package update Mockingbird
```

### 2. Create a script

Next, create a Bash script called `gen-mocks.sh` in the same directory as your package manifest. Copy the example below, making sure to change the lines marked with `FIXME`.

```bash
#!/bin/bash
set -eu
cd "$(dirname "$0")"
swift package describe --type json > project.json
.build/checkouts/mockingbird/mockingbird generate --project project.json \
  --output-dir Sources/MyPackageTests/MockingbirdMocks \  # FIXME: Where mocks should be generated.
  --testbundle MyPackageTests \                           # FIXME: Name of your test target.
  --targets MyPackage MyLibrary1 MyLibrary2               # FIXME: Specific modules or libraries that should be mocked.
```

Ensure that the script runs and generates mock files.

```console
$ chmod +x gen-mocks.sh
$ ./gen-mocks.sh
Generated file to MockingbirdMocks/MyPackageTests-MyPackage.generated.swift
Generated file to MockingbirdMocks/MyPackageTests-MyLibrary1.generated.swift
Generated file to MockingbirdMocks/MyPackageTests-MyLibrary2.generated.swift
```

### Recommended

Exclude generated files, binaries, and caches from source control to prevent merge conflicts.

```bash
# Generated
*.generated.swift

# Binaries
lib_InternalSwiftSyntaxParser.dylib

# Caches
.mockingbird/
```

## Need Help?

- [#mockingbird Slack channel](https://join.slack.com/t/birdopensource/shared_invite/zt-wogxij50-3ZM7F8ZxFXvPkE0j8xTtmw)
- [SwiftPM example package](https://github.com/birdrides/mockingbird/tree/master/Examples/SPMPackageExample)
- <doc:Common-Problems>
