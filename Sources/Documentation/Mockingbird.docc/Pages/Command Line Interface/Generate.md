# Generate Command Options

Generate mocks for a set of targets in a project.

## Overview

The generator uses your project’s source graph to discover, parse, and output mocked types.

### Examples

Generate mocks for `MyApp` and `MyLibrary`:

```console
$ mockingbird generate --targets MyApp MyLibrary
```

Only generate mocks for `MyApp` which are also used in `MyAppTests`:

```console
$ mockingbird generate --targets MyApp --testbundle MyAppTests
```

Only generate mocks for `ExternalFramework` which are also used in `MyAppTests`, given that the two targets are located in different Xcode projects:

```console
$ PROJECT_FILE_PATH=/path/to/MyApp.xcodeproj mockingbird generate \
    --project ExternalFramework.xcodeproj \
    --targets ExternalFramework \
    --testbundle MyAppTests
```

### Options

See <doc:Default-Values> for more information about inferred options.

| Option | Default Value | Description |
| --- | --- | --- |
| `-t, --targets` | **(required)** | List of target names to generate mocks for. |
| `-o, --outputs` | (inferred) | List of output file paths corresponding to each target. |
| `-p, --project` | (inferred) | Path to an Xcode project or a <doc:JSON-Project-Description>. |
| `--output-dir` | (inferred) | The directory where generated files should be output. |
| `--srcroot` | (inferred) | The directory containing your project’s source files. |
| `--support` | (inferred) | The directory containing <doc:Supporting-Source-Files>. |
| `--testbundle` | (inferred) | The name of the test bundle using the mocks. |
| `--header` | `nil` | Lines to show at the top of generated mock files. |
| `--condition` | `nil` | [Compilation condition](https://docs.swift.org/swift-book/ReferenceManual/Statements.html#ID538) to wrap all generated mocks in. |
| `--diagnostics` | `nil` | List of <doc:Generator-Diagnostics> to enable. |
| `--prune` | `"omit"` | The <doc:Thunk-Pruning> level for unreferenced types. |

### Flags

| Flag | Description |
| --- | --- |
| `--only-protocols` | Only generate mocks for protocols. |
| `--disable-swiftlint` | Disable all SwiftLint rules in generated mocks. |
| `--disable-cache` | Ignore cached mock information stored on disk. |
| `--disable-relaxed-linking` | Only search explicitly imported modules. |
