---
name: Bug report
about: Create a report to help us improve Mockingbird
title: ''
labels: ''
assignees: andrewchang-bird

---

## New Issue Checklist

- [ ] I updated my Mockingbird framework and CLI to the latest version
- [ ] I searched for [existing GitHub issues](https://github.com/birdrides/mockingbird/issues)

## Description

Please provide a clear and concise description of the bug.

### Generator Bugs

Please provide the complete output when running Mockingbird CLI, including any options used.

```bash
$ mockingbird generate
```

If the generator produces code that is malformed or does not compile, please provide:
1. A minimal example of the original source
2. The actual mocking code generated
3. The expected mocking code that should be generated (or a description)

### Framework Bugs

Please provide a minimal example of your unit testing code, including any errors.

## Environment

* Mockingbird CLI version (`mockingbird version`)
* Xcode and macOS version (are you running a beta?)
* Swift version (`swift --version`)
* Installation method (CocoaPods, Carthage, from source, etc)
* Unit testing framework (XCTest, Quick + Nimble, etc)
* Does your project use `.mockingbird-ignore`?
