# Carthage Quick Start Guide

Integrate Mockingbird into a Carthage Xcode project.

## Overview

Add the framework to your `Cartfile`.

```
github "birdrides/mockingbird" ~> 0.19
```

In your project directory, build the framework and [link it to your test target](https://github.com/birdrides/mockingbird/wiki/Linking-Test-Targets).

```console
$ carthage update --use-xcframeworks
```

Finally, configure the test target to generate mocks for specific modules or libraries.

```console
$ Carthage/Checkouts/mockingbird/mockingbird configure MyAppTests -- --targets MyApp MyLibrary1 MyLibrary2
```

> Tip: The configurator adds a build phase which calls the generator before each test run. You can pass [additional arguments](#foobar) to the generator after the configurator double-dash (`--`).

## Recommended

- [Exclude generated files from source control](https://github.com/birdrides/mockingbird/wiki/Integration-Tips#source-control-exclusion)

## Need Help?

- [Join the #mockingbird Slack channel](https://join.slack.com/t/birdopensource/shared_invite/zt-wogxij50-3ZM7F8ZxFXvPkE0j8xTtmw)
- [Search the troubleshooting guide for common issues](https://github.com/birdrides/mockingbird/wiki/Troubleshooting)
- [Check out the Carthage example project](https://github.com/birdrides/mockingbird/tree/master/Examples/CarthageExample)
