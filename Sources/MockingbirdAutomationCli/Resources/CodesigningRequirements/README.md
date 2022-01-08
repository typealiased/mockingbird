# Codesigning Requirements

Binary products are code signed as part of the build pipeline and verified against a designated requirement when downloaded from the prebuilt release artifacts. For auditability, requirements should be kept in source form with relevant comments and only updated via signed commits.

## Making Changes

There are a few prerequisites to testing the code signing flow:

1. An active Apple developer account.
2. A “Developer ID Application” certificate in your keychain with its corresponding private key. Running `security find-identity` should list the identity.
3. [swift sh](https://github.com/mxcl/swift-sh) installed.

Once your environment is set up, simply modify a requirements file and run the `BuildArtifact` script with `--sign` to validate your changes.

```console
$ Sources/MockingbirdAutomation/buildAndRun.sh build cli --sign <identity>
```

## Supporting Links

- [macOS Code Signing In Depth](https://developer.apple.com/library/archive/technotes/tn2206/_index.html)
- [Code Signing Requirement Language](https://developer.apple.com/library/archive/documentation/Security/Conceptual/CodeSigningGuide/RequirementLang/RequirementLang.html)
