# Patches

These patches are used by release automation to apply Mockingbird-specific changes to the Swift-DocC and Swift-DocC-Render projects.

## Creating Patches

A few guidelines:

- Keep patches small and focused
- Commit short titles and include a list of what changed in the summary

```console
$ git checkout <branch>
$ git format-patch main --output-directory /path/to/patches
```

## Applying Patches

Apply the patches from the corresponding project repo. See the GitHub workflows for more examples.

```console
$ git apply /path/to/patches/*.patch
```
