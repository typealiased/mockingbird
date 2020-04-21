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

If the generator produces code that is malformed or does not compile, please provide:

1. A minimal example of the original source
2. The actual mocking code generated
3. The expected mocking code that should be generated (or a description)

If the generator is not producing code or crashing, please provide logging output from the Run Script Phase. See
[Debugging the generator](https://github.com/birdrides/mockingbird/wiki/Debugging-the-Generator) for more 
information.

```bash
$ mockingbird generate
```

### Framework Bugs

Please provide a minimal example of your testing code, including any errors.

## Environment

* Mockingbird CLI version (`mockingbird version`)
* Xcode and macOS version (are you running a beta?)
* Swift version (`swift --version`)
* Installation method (CocoaPods, Carthage, from source, etc)
* Unit testing framework (XCTest, Quick + Nimble, etc)
* Does your project use `.mockingbird-ignore`?
* Are you using [supporting source files](https://github.com/birdrides/mockingbird#supporting-source-files)?
