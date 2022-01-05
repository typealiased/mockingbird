# CocoaPods Quick Start Guide

Integrate Mockingbird into a CocoaPods Xcode project.

## Overview

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

Finally, configure the test target to generate mocks for specific modules or libraries.

```console
$ Pods/MockingbirdFramework/mockingbird configure MyAppTests -- --targets MyApp MyLibrary1 MyLibrary2
```

> Tip: The configurator adds a build phase which calls the generator before each test run. You can pass [additional arguments](#foobar) to the generator after the configurator double-dash (`--`).

## Recommended

- [Exclude generated files from source control](https://github.com/birdrides/mockingbird/wiki/Integration-Tips#source-control-exclusion)

## Need Help?

- [Join the #mockingbird Slack channel](https://join.slack.com/t/birdopensource/shared_invite/zt-wogxij50-3ZM7F8ZxFXvPkE0j8xTtmw)
- [Search the troubleshooting guide for common issues](https://github.com/birdrides/mockingbird/wiki/Troubleshooting)
- [Check out the CocoaPods example project](https://github.com/birdrides/mockingbird/tree/master/Examples/CocoaPodsExample)
