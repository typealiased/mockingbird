#!/bin/bash

# Checkout latest Carthage dependencies.
carthage update --no-build

# Remove non-framework schemes for Mockingbird.
cd Carthage/Checkouts/mockingbird
make bootstrap-carthage
cd ../../../

# Build all dependencies.
carthage build
