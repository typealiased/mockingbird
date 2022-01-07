# Thunk Pruning

Exclude unused types from generating mocks.

## Overview

To improve compilation times for large projects, Mockingbird only generates mocking code (known as thunks) for types used in tests. Unused types can either produce stubs or no code at all depending on the pruning level.

| Level | Description |
| --- | --- |
| `disable` | Always generate full thunks regardless of usage in tests. |
| `stub` | Generate partial definitions filled with `fatalError`. |
| `omit` | Don’t generate any definitions for unused types. |

### Dependency Injection

Usage is determined by statically analyzing test target sources for calls to `mock(SomeType.self)`, which may not work out of the box for projects that indirectly synthesize types such as through Objective-C based dependency injection.

- **Option 1:** Explicitly reference each indirectly synthesized type in your tests, e.g. `_ = mock(SomeType.self)`. References can be placed anywhere in the test target sources, such as in the `setUp` method of a test case or in a single file.
- **Option 2:** Disable pruning entirely by setting the prune level with `--prune disable`. Note that this may increase compilation times for large projects.
