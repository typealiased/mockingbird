---
name: Generator Issue
about: Report a problem with the code generator
title: ''
labels: 'generator bug'
assignees: ''

---

## New Issue Checklist

- [ ] I updated the framework and generator to the latest version
- [ ] I searched the [existing GitHub issues](https://github.com/birdrides/mockingbird/issues) and list of [common problems](https://mockingbirdswift.com/common-problems)

## Overview

A summary of the issue.

## Example

If the generator produces code that is malformed or does not compile, please provide:

1. A minimal example of the original source
2. The actual mocking code generated

If the generator is not producing code or crashing, please provide the build logs.

## Expected Behavior

If needed, provide a short description of how it should work.

## Environment

* Mockingbird CLI version (`mockingbird version`)
* Xcode and Swift version (`swift --version`)
* Package manager (CocoaPods, Carthage, SPM project, SPM package)
* Unit testing framework (XCTest, Quick/Nimble)
* Custom configuration
  - [ ] Mockingbird ignore files
  - [ ] Supporting source files
