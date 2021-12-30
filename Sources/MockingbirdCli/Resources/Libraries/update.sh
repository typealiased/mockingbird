#!/bin/bash

set -eu

readonly xcodeDeveloperDir="$(xcrun xcode-select -p)"
readonly xcodeToolchainPath="${xcodeDeveloperDir}/Toolchains/XcodeDefault.xctoolchain"

# Set the cwd relative to the script.
cd "$(dirname "$0")"

# Update `lib_InternalSwiftSyntaxParser.dylib`.
cp "${xcodeToolchainPath}/usr/lib/swift/macosx/lib_InternalSwiftSyntaxParser.dylib" ./
