# Debugging the Generator

Debug the generator using the built-in diagnostic tools.

### 1. Examine the build logs

Open the Xcode report navigator and select the entry for the most recent test run.

![Xcode report navigator](report-navigator)

Check for any errors or warnings in the build log for the test target build phase named “Generate Mockingbird Mocks.”

![Build log error message](build-log)

### 2. Increase the logging verbosity

Configure the test target with `--verbose` and `--diagnostics all` after the double-dash to output full debugging information into the build log. See <doc:Configure> for examples.

### 3. Attach a debugger

You can always attach a debugger to the generator if the build logs don’t contain the necessary information. Set up a <doc:Local-Development> environment and configure the `MockingbirdCli` scheme (⌘<) with the same launch arguments and working directory as configured build phase.

![MockingbirdCli launch arguments](launch-args)
