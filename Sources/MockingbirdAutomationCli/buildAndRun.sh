#!/usr/bin/env bash
set -eu
cd "$(dirname "$0")/../.."

MKB_BUILD_EXECUTABLES=1 swift run automation "$@"
