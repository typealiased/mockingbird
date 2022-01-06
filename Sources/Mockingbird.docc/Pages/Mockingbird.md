# ``Mockingbird``

A *Swifty* mocking framework for Swift and Objective-C.

## Overview

Mockingbird makes it easy to mock, stub, and verify objects in Swift unit tests. You can test both Swift and Objective-C without writing any boilerplate or modifying production code.

![Mockingbird hero](hero)

Mockingbird’s syntax takes inspiration from (OC)Mockito but was designed to be “Swifty” in terms of type safety, expressiveness, and readability. In addition to the basics, it provides functionality for advanced features such as creating partial mocks, verifying the order of calls, and testing asynchronous code.

Conceptually, Mockingbird uses codegen to statically mock Swift types at compile time and `NSProxy` to dynamically mock Objective-C types at run time. Although the approach is similar to other frameworks that augment Swift’s limited introspection capabilities with codegen, there are a few key differences:

- Generating mocks takes seconds instead of minutes on large Swift codebases.
- Stubbing and verification failures appear inline and don’t abort the entire test run.
- Production code is kept separate from tests and never modified with annotations.
- Xcode projects can be used as the source of truth to automatically determine source files.

See the <doc:Feature-Comparison> and <doc:Known-Limitations>.

### Example

```swift
// Mocking
let bird = mock(Bird.self)

// Stubbing
given(bird.canFly).willReturn(true)

// Verification
verify(bird.fly()).wasCalled()
```

### Who Uses Mockingbird?

Mockingbird powers thousands of tests at companies including [Meta](https://meta.com), [Amazon](https://amazon.com), [Twilio](https://twilio.com), [Blockchain](https://blockchain.com), and [Bird](https://bird.co). Using Mockingbird to improve your testing workflow? We’d love to hear your feedback on the [#mockingbird Slack channel](https://join.slack.com/t/birdopensource/shared_invite/zt-wogxij50-3ZM7F8ZxFXvPkE0j8xTtmw).

### Alternatives

- [Cuckoo](https://github.com/Brightify/Cuckoo)
- [SwiftyMocky](https://github.com/MakeAWishFoundation/SwiftyMocky)

## Topics

### Getting Started

- <doc:CocoaPods-QuickStart>
- <doc:Carthage-QuickStart>
- <doc:SPM-Project-QuickStart>
- <doc:SPM-Package-QuickStart>

### Essentials

- <doc:Mocking>
- <doc:Stubbing>
- <doc:Verification>
- <doc:Matching-Arguments>

### Command Line Interface

- <doc:Generate>
- <doc:Configure>
- <doc:Default-Values>
- <doc:JSON-Project-Description>
- <doc:Thunk-Pruning>

### Advanced Topics

- <doc:Mocking-External-Types>
- <doc:Supporting-Source-Files>
- <doc:Excluding-Files>

### Troubleshooting

- <doc:Common-Problems>
- <doc:Debugging-the-Generator>
- <doc:Generator-Diagnostics>

### Meta

- <doc:Known-Limitations>
- <doc:Feature-Comparison>
- <doc:Local-Development>
- <doc:Internal>
