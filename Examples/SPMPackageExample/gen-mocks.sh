#!/bin/bash
set -eu
cd "$(dirname "$0")"
swift package describe --type json > project.json
.build/checkouts/mockingbird/mockingbird generate --project project.json \
  --outputs Tests/SPMPackageExampleTests/MockingbirdMocks/SPMPackageExampleMocks.generated.swift \
  --testbundle SPMPackageExampleTests \
  --targets SPMPackageExample
