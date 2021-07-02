#!/bin/bash

set -eu

xcodeDeveloperDir="$(xcode-select -p)"
xcodeToolchainPath="${xcodeDeveloperDir}/Toolchains/XcodeDefault.xctoolchain"

# Set the cwd relative to the script.
cd "$(dirname "$0")"

# Update `lib_InternalSwiftSyntaxParser.dylib`.
cp "${xcodeToolchainPath}/usr/lib/swift/macosx/lib_InternalSwiftSyntaxParser.dylib" ./
