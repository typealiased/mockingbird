# Configure Command Options

Configure a test target to generate mocks.

## Overview

Configuring a test target adds a build phase that calls the generator before each test run.

### Examples

Configure `MyAppTests` to generate mocks for `MyApp` and `MyLibrary`:

```console
$ mockingbird configure MyAppTests -- --targets MyApp MyLibrary
```

Configure `MyAppTests` to only generate protocol mocks for `MyApp`:

```console
$ mockingbird configure MyAppTests -- --targets MyApp --only-protocols
```

Configure `MyAppTests` to generate mocks for `ExternalFramework` given that the two targets are located in different Xcode projects:

```console
$ mockingbird configure MyAppTests \
    --project /path/to/MyApp.xcodeproj \
    --srcproject /path/to/ExternalFramework.xcodeproj \
    -- \
    --targets ExternalFramework
```

### Options

See <doc:Default-Values> for more information about inferred options.

| Option | Default Value | Description |
| --- | --- | --- |
| `-p, --project` | (inferred) | Path to an Xcode project. |
| `--srcproject` | (inferred) | Path to the Xcode project with source modules. |
| `--generator` | (inferred) | Path to the Mockingbird generator executable. |
| `--url` | (inferred) | The base URL hosting downloadable asset bundles. |

### Flags

| Flag | Description |
| --- | --- |
| `--preserve-existing` | Keep previously added Mockingbird build phases. |
