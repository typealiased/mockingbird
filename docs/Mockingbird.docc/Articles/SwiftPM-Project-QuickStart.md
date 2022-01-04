# SwiftPM Quick Start Guide - Xcode Project

Integrate Mockingbird into a SwiftPM Xcode project.

## Overview

Add the framework to your project:

1. Navigate to **File › Add Packages…** and enter `https://github.com/birdrides/mockingbird`
2. Change **Dependency Rule** to “Up to Next Minor Version” and enter `0.19.0`
3. Click **Add Package**
4. Select your test target and click **Add Package**

In your project directory, resolve the derived data path. This can take a few moments.

```console
$ DERIVED_DATA="$(xcodebuild -showBuildSettings | sed -n 's|.*BUILD_ROOT = \(.*\)/Build/.*|\1|p'
```

Finally, configure the test target to generate mocks for specific modules or libraries.

```console
$ "${DERIVED_DATA}/SourcePackages/checkouts/mockingbird/mockingbird" configure MyPackageTests -- --targets MyPackage MyLibrary1 MyLibrary2
```

> Tip: The configurator adds a build phase which calls the generator before each test run. You can pass [additional arguments](#foobar) to the generator after the configurator double-dash (`--`).

## Recommended

- [Exclude generated files from source control](https://github.com/birdrides/mockingbird/wiki/Integration-Tips#source-control-exclusion)

## Need Help?

- [Join the #mockingbird Slack channel](https://join.slack.com/t/birdopensource/shared_invite/zt-wogxij50-3ZM7F8ZxFXvPkE0j8xTtmw)
- [Search the troubleshooting guide for common issues](https://github.com/birdrides/mockingbird/wiki/Troubleshooting)
- [Check out the SPM Xcode project example](https://github.com/birdrides/mockingbird/tree/master/Examples/SPMProjectExample)
