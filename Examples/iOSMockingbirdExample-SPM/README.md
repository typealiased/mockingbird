# Mockingbird Swift Package Manager Example

A minimal example of [Mockingbird](https://github.com/birdrides/mockingbird) integrated into an Xcode project using Swift Package Manager’s Xcode integration.

Having issues setting up Mockingbird? Join the [Slack channel](https://slofile.com/slack/birdopensource) or [file an issue](https://github.com/birdrides/mockingbird/issues/new/choose).

## Tutorial

### 1. Add Dependency

1. File > Swift Packages > Add Package Dependency…
2. Enter `https://github.com/birdrides/mockingbird` for the repository URL and click Next
3. Choose “Up to Next Minor” for the version and click Next
4. Select your test target under “Add to Target” and click Finish

### 2. Install Mockingbird

Initialize the package dependency and install the CLI.

```console
$ xcodebuild -resolvePackageDependencies
$ DERIVED_DATA=$(xcodebuild -showBuildSettings | pcregrep -o1 'OBJROOT = (/.*)/Build')
$ (cd "${DERIVED_DATA}/SourcePackages/checkouts/mockingbird" && make install-prebuilt)
```

### 3. Configure Test Target

Download the starter supporting source files into your project root.

```console
$ mockingbird download starter-pack
```

Then configure the test target.

```console
$ mockingbird install \
  --target iOSMockingbirdExample-SPMTests \
  --source iOSMockingbirdExample-SPM
```

### 4. Run Tests

Open the Xcode project.

```console
$ open iOSMockingbirdExample-SPM.xcodeproj
```

Take a peek at the example test and sources and then run the tests (⌘+U):

- [`TreeTests.swift`](iOSMockingbirdExample-SPM/TreeTests.swift)
- [`Tree.swift`](iOSMockingbirdExample-SPM/Tree.swift)
- [`Bird.swift`](iOSMockingbirdExample-SPM/Bird.swift)

Bonus: 
- [`.mockingbird-ignore`](iOSMockingbirdExample-SPM/.mockingbird-ignore)
- [`.gitignore`](.gitignore)
