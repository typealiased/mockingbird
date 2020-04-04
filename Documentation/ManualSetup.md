# Manual Setup

## Generate on Test Target Compilation

This is the recommended approach and is what `mockingbird install` does under the hood. In most cases you
should be using the installer, but please [file an issue](https://github.com/birdrides/mockingbird/issues/new/choose) if
you have a specific use case that the installer doesn’t handle.

### Add Generate Mocks Build Phase

First, add a new Run Script Phase to your unit test target before the Compile Sources phase. Specify the source
targets that should generate mocks as arguments and include other
[generator options](https://github.com/birdrides/mockingbird#generate) as needed.

```bash
# Specify the source targets that should generate mocks
mockingbird generate --targets Bird BirdManagers
```

### Include Generated Mock Files

Run any test to generate the initial `.generated.swift` mock files. By default, Mockingbird will output mock files
for each source target into the `$(SRCROOT)/MockingbirdMocks` directory. Add all generated mock files to your
unit test target sources. 

### Enforce Build Phase Ordering

This step is optional but highly recommended. For parallelized builds, Xcode will run the generate mocks build phase
asynchronously to compiling the unit test target. This can lead to a race condition and build failures if source
compilation starts before the mock files are generated.

To guarantee that mock generation happens before source compilation, add a new Run Script Phase to your unit test
target before the generate mocks Run Script Phase.

```bash
# Simple cache buster
echo $RANDOM > '/tmp/mockingbird-cache-buster'
```

In the cache buster Run Script Phase output files and the generate mocks Run Script Phase input files add
`/tmp/mockingbird-cache-buster`.

Finally, in the generate mocks Run Script Phase output files add each generated mock file. For example:

- `$(SRCROOT)/MockingbirdMocks/BirdMocks.generated.swift`
- `$(SRCROOT)/MockingbirdMocks/BirdManagersMocks.generated.swift`

## Generate on Source Target Compilation

This is the easier of the two manual integration methods, but might cause slower builds for non test targets.

First, add new Run Script Phases to each source target that should generate mocks. Include other
[generator options](https://github.com/birdrides/mockingbird#generate) as needed.

```bash
# Generate mocks for a source target
mockingbird generate
```

Build each source target to generate the `.generated.swift` mock files. By default, Mockingbird will output mock
files for each source target into the `$(SRCROOT)/MockingbirdMocks` directory. Add all generated mock files to
your unit test target sources.
