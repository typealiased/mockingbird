# Codesigning Requirements

Binary products are code signed as part of the build pipeline and verified against a designated requirement when downloaded from the prebuilt release artifacts. For auditability, requirements should be kept in source form with relevant comments and only updated via signed commits.

## Making Changes

You must have a registered Apple developer account to code sign

```console
$ export MKB_BUILD_TYPE=2 swift sh Scripts/BuildArtifact.swift cli --sign <identity>
```


## Supporting Links
- [macOS Code Signing In Depth](https://developer.apple.com/library/archive/technotes/tn2206/_index.html)
- [Code Signing Requirement Language](https://developer.apple.com/library/archive/documentation/Security/Conceptual/CodeSigningGuide/RequirementLang/RequirementLang.html)
