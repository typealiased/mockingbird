# Excluding Files

Exclude problematic sources from being parsed by the generator.

## Overview

You can use a `.mockingbird-ignore` file to exclude specific files, directories, or path patterns from being processed by Mockingbird. This is useful to prevent malformed or unparsable source files from crashing the generator. Most of the time you shouldn’t need to use a Mockingbird ignore file and can set the <doc:Thunk-Pruning> level to `omit`.

### Schema

The Mockingbird ignore file follows the same format and directory-level scoping as [`.gitignore`](https://git-scm.com/docs/gitignore#_pattern_format). It supports negation and comments in addition to pattern-based file matching.

### Examples

Ignore specific source files.

```bash
MyClass.swift
MyProtocol.swift
```

Ignore specific directories.

```bash
TopLevelDirectory/
Path/To/Another/Directory/
```

Ignore multiple files based on a pattern.

```bash
*.generated.swift
Foo/**/*Bar.swift
```

Ignore all files in a directory except for one.

```bash
TopLevelDirectory/
!TopLevelDirectory/IncludeMe.swift
```
