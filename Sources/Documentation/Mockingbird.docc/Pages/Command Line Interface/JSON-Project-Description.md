# JSON Project Description

Generate mocks without an Xcode project.

## Overview

By default, Mockingbird uses the source graph defined by your Xcode project as the source of truth for modules and their dependencies. Although this works well for most cases, build environments that don’t rely on Xcode projects such as SwiftPM packages, Buck, and Bazel require direct access to the source graph.

You can use JSON project descriptions as a way to define available modules and their corresponding sources files and dependencies. Project descriptions should contain both source and test targets in order to use <doc:Thunk-Pruning>.

### Schema

JSON project descriptions are compatible with `swift package describe --type json` and can be used to generate mocks for SwiftPM packages.

```swift
struct ProjectDescription {
  let targets: [Target]
}

struct Target {
  let name: String            // The name of the target
  let type: TargetType        // Either `library` or `test`
  let path: String            // Path to the target’s source root
  let dependencies: [String]  // List of dependency target names
  let sources: [String]       // List of source file paths relative to `path`

  enum TargetType {
    case library              // A Swift source target
    case test                 // A Swift unit test target
  }
}
```

### Example

```json
{
  "targets": [
    {
      "name": "MyLibrary",
      "type": "library",
      "path": "/path/to/MyLibrary",
      "dependencies": [],
      "sources": [
        "SourceFileA.swift",
        "SourceFileB.swift"
      ]
    },
    {
      "name": "MyOtherLibrary",
      "type": "library",
      "path": "/path/to/MyOtherLibrary",
      "dependencies": [
        "MyLibrary"
      ],
      "sources": [
        "SourceFileA.swift",
        "SourceFileB.swift"
      ]
    },
    {
      "name": "MyLibraryTests",
      "type": "test",
      "path": "/path/to/MyLibraryTests",
      "dependencies": [
        "MyLibrary"
      ],
      "sources": [
        "SourceFileA.swift",
        "SourceFileB.swift"
      ]
    }
  ]
}
```
