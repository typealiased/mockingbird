# Default Values and Global Options

Values inferred from the environment and working directory.

### Global Options

| Flag | Description |
| --- | --- |
| `--verbose` | Log all errors, warnings, and debug messages. |
| `--quiet` | Only log error messages. |
| `--version` | Show the version. |
| `-h, --help` | Show help information. |

### Default Values

#### project

Mockingbird first checks the environment variable `PROJECT_FILE_PATH` set by the Xcode build context and then performs a shallow search of the current working directory for an `.xcodeproj` file. If multiple `.xcodeproj` files exist then you must explicitly provide a project file path.

#### srcroot

Mockingbird checks the environment variables `SRCROOT` and `SOURCE_ROOT` set by the Xcode build context and then falls back to the directory containing the `.xcodeproj` project file. Note that source root is ignored when using JSON project descriptions.

#### outputs

Mockingbird generates mocks into the directory `$(SRCROOT)/MockingbirdMocks` with the file name `$(PRODUCT_MODULE_NAME)Mocks-$(TEST_TARGET_NAME).generated.swift`.

#### support

Mockingbird recursively looks for <doc:Supporting-Source-Files> in the directory `$(SRCROOT)/MockingbirdSupport`.

#### testbundle

Mockingbird checks the environment variables `TARGET_NAME` and `TARGETNAME` set by the Xcode build context and verifies that it refers to a valid Swift unit test target. The test bundle option must be set when using a <doc:JSON-Project-Description> in order to enable thunk stubs.

#### generator

Mockingbird uses the current executable path and attempts to make it relative to the project’s `SRCROOT` or derived data. To improve portability across development environments, avoid linking executables outside of project-specific directories.

#### url

Mockingbird uses the GitHub release artifacts located at `https://github.com/birdrides/mockingbird/releases/download`. Note that asset bundles are versioned by release.
