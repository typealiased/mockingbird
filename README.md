<p align="center">
  <img src="/Sources/Documentation/Mockingbird.docc/Resources/logo@3x.png" alt="Mockingbird - Swift Mocking Framework" width="150">
  <h1 align="center">Mockingbird</h1>
</p>

<p align="center">
  <a href="#quick-start"><img src="https://img.shields.io/badge/package-CocoaPods%20%7C%20Carthage%20%7C%20SwiftPM-4BC51D.svg" alt="Package managers"></a>
  <a href="https://github.com/birdrides/mockingbird/blob/master/LICENSE.md"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT licensed"></a>
  <a href="https://join.slack.com/t/birdopensource/shared_invite/zt-wogxij50-3ZM7F8ZxFXvPkE0j8xTtmw" rel="nofollow"><img src="https://img.shields.io/badge/slack-%23mockingbird-A417A6.svg" alt="#mockingbird Slack channel"></a>
</p>

Mockingbird makes it easy to mock, stub, and verify objects in Swift unit tests. You can test both Swift and Objective-C without writing any boilerplate or modifying production code.

## Documentation

Visit [MockingbirdSwift.com](https://mockingbirdswift.com) for quick start guides, walkthroughs, and API reference articles.

## Examples

Automatically generating mocks.

```console
$ mockingbird configure BirdTests -- --target Bird
```

Manually generating mocks.

```console
$ mockingbird generate --testbundle BirdTests --target Bird --output Mocks.generated.swift
```

Using Mockingbird in tests.

```swift
// Mocking
let bird = mock(Bird.self)

// Stubbing
given(bird.canFly).willReturn(true)

// Verification
verify(bird.fly()).wasCalled()
```

## Contributing

Please read the [contributing guide](/.github/CONTRIBUTING.md) to learn about reporting bugs, developing features, and submitting code changes.

## License

Mockingbird is [MIT licensed](/LICENSE.md). By contributing to Mockingbird, you agree that your contributions will be licensed under its MIT license.
