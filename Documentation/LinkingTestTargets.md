# Linking Test Targets

In your test target’s build phases you should:

1. Add Mockingbird to the **Link Binary With Libraries** build phase.
2. Add a new **Copy Files** phase that includes Mockingbird with the destination set to `Frameworks`.

![Test target build phases](Assets/test-target-build-phases.png)
