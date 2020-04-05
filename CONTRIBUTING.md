# Contributing

Thanks for taking the time to contribute! This document is currently a work in progress.

## Setup

Install required dependencies and configure the Xcode project.

```bash
$ make setup-project
```

## Project Structure

### MockingbirdCli

Frontend for the CLI which uses the argument parser from `SPMUtility`.

### MockingbirdGenerator

Performs code generation for a target.

1. Parse the Xcode project using `XcodeProj`, or used a cached representation of the Xcode project.
2. Extract the source files from the target and its dependencies.
3. Parse each extracted source file into a structure tree using `SourceKitten`.
4. Minimally process the top level types from each structure tree, converting them into a  `RawType`.
5. For each `RawType` coming from a target-defined source file, flatten the inheritance graph into a `MockableType`.
6. Send all `MockableType` objects to the generator to render using templates.

### MockingbirdFramework

The runtime testing framework that provides mocking, stubbing, and verification APIs.

### MockingbirdTestsHost

Defines types used in end-to-end tests.

### MockingbirdModuleTestsHost

Defines types which are imported by `MockingbirdTestsHost` and used for cross-module end-to-end tests. 

### MockingbirdTests

Handles end-to-end and unit tests. End-to-end tests use protocol conformance for asserting that generated mocks
contain the expected member declarations.
