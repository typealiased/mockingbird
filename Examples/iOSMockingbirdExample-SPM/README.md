# Mockingbird Swift Package Manager Example

A minimal example of [Mockingbird](https://github.com/birdrides/mockingbird) integrated into an Xcode project using
Swift Package Manager’s Xcode integration.

Having issues setting up Mockingbird? Join the [Slack channel](https://slofile.com/slack/birdopensource) or
[file an issue](https://github.com/birdrides/mockingbird/issues/new/choose).

## Tutorial

### Create the Xcode Project

Open Xcode and create an iOS Single View App with the name `iOSMockingbirdExample-SPM`. Make sure that the
checkbox labeled “Include Unit Tests” is selected.

### Configure Dependencies

1. File > Swift Packages > Add Package Dependency…
2. Enter `https://github.com/birdrides/mockingbird.git` for the repository URL and click Next
3. Make sure “Up to Next Major” is selected for the version and click Next
4. Select your test target for the Mockingbird library product and click Finish

### Install Mockingbird

Install the CLI from the checked out Mockingbird repository in derived data. 

```bash
$ xcodebuild -resolvePackageDependencies
$ DERIVED_DATA=$(xcodebuild -showBuildSettings | grep -m1 'BUILD_DIR' | grep -o '\/.*' | dirname $(xargs dirname))
$ (cd "${DERIVED_DATA}/SourcePackages/checkouts/mockingbird" && make install-prebuilt)
```

### Configure Test Target

Configure the test target by using the CLI.

```bash
$ mockingbird install \
  --target iOSMockingbirdExample-SPMTests \
  --source iOSMockingbirdExample-SPM
```

Finally, download the starter supporting source files into your project root.

```bash
$ mockingbird download starter-pack
```

### Run Tests

Open the Xcode project.

```bash
$ open iOSMockingbirdExample-SPM.xcodeproj
```

Take a peek at the example test and sources and then run the tests (⌘+U):

- [`TreeTests.swift`](iOSMockingbirdExample-SPM/TreeTests.swift)
- [`Tree.swift`](iOSMockingbirdExample-SPM/Tree.swift)
- [`Bird.swift`](iOSMockingbirdExample-SPM/Bird.swift)

Bonus: 
- [`.mockingbird-ignore`](iOSMockingbirdExample-SPM/.mockingbird-ignore)
- [`.gitignore`](.gitignore)
