TEMPORARY_FOLDER?=/tmp/Mockingbird.make.dst
PREFIX?=/usr/local
BUILD_TOOL?=xcodebuild

SIMULATOR_NAME='iphone11-mockingbird'
SIMULATOR_DEVICE_TYPE='com.apple.CoreSimulator.SimDeviceType.iPhone-11'
SIMULATOR_RUNTIME='com.apple.CoreSimulator.SimRuntime.iOS-13-3'

SWIFT_BUILD_FLAGS=--configuration release
XCODEBUILD_FLAGS=-project 'Mockingbird.xcodeproj' \
	-destination 'platform=OS X' \
	DSTROOT=$(TEMPORARY_FOLDER)

EXAMPLE_XCODEBUILD_FLAGS=DSTROOT=$(TEMPORARY_FOLDER)
EXAMPLE_COCOAPODS_XCODEBUILD_FLAGS=$(EXAMPLE_XCODEBUILD_FLAGS) \
	-workspace 'Examples/iOSMockingbirdExample-CocoaPods/iOSMockingbirdExample-CocoaPods.xcworkspace' \
	-scheme 'iOSMockingbirdExample-CocoaPods'
EXAMPLE_CARTHAGE_XCODEBUILD_FLAGS=$(EXAMPLE_XCODEBUILD_FLAGS) \
	-project 'Examples/iOSMockingbirdExample-Carthage/iOSMockingbirdExample-Carthage.xcodeproj' \
	-scheme 'iOSMockingbirdExample-Carthage'

EXECUTABLE_PATH=$(shell swift build $(SWIFT_BUILD_FLAGS) --show-bin-path)/mockingbird

FRAMEWORKS_FOLDER=/Library/Frameworks
BINARIES_FOLDER=$(PREFIX)/bin
LICENSE_PATH="$(shell pwd)/LICENSE"
PKG_BUNDLE_IDENTIFIER=co.bird.mockingbird
PKG_IDENTITY_NAME=3rd Party Mac Developer Installer: Bird Rides, Inc. (P2T4T6R4SL)
ZIP_IDENTITY_NAME=3rd Party Mac Developer Application: Bird Rides, Inc. (P2T4T6R4SL)
CLI_DESIGNATED_REQUIREMENT=Codesigning/MockingbirdCli.dr
ZIP_FILENAME=MockingbirdCli.zip
CLI_FILENAME=mockingbird

OUTPUT_PACKAGE=MockingbirdCli.pkg
OUTPUT_ZIP=MockingbirdCli.zip

CLI_BUNDLE_PLIST=MockingbirdCli/Info.plist
VERSION_STRING=$(shell /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$(CLI_BUNDLE_PLIST)")

GITHUB_REPO_URL=https://github.com/birdrides/mockingbird
ZIP_RELEASE_URL=$(GITHUB_REPO_URL)/releases/download/$(VERSION_STRING)/$(ZIP_FILENAME)
SUCCESS_MSG=Verified the Mockingbird CLI binary
ERROR_MSG=[ERROR] The downloaded Mockingbird CLI binary does not have the expected code signature! See <Codesigning/README.md>.

.PHONY: all \
		clean \
		clean-mocks \
		clean-xcode \
		setup-project \
		save-xcschemes \
		build \
		setup-cocoapods \
		test-cocoapods \
		test-carthage \
		test-examples \
		clean-cocoapods \
		clean-carthage \
		clean-test-examples \
		test \
		clean-test \
		install \
		uninstall \
		package \
		signed-package \
		zip \
		signed-zip \
		release \
		signed-release \
		get-version \
		get-zip-sha256

all: build

clean:
	rm -f "$(OUTPUT_PACKAGE)"
	rm -rf "$(TEMPORARY_FOLDER)"
	rm -f "$(OUTPUT_ZIP)"
	swift package clean

clean-mocks: clean
	rm -f MockingbirdMocks/*.generated.swift

clean-xcode: clean-mocks
	$(BUILD_TOOL) -scheme 'MockingbirdFramework' $(XCODEBUILD_FLAGS) clean
	$(BUILD_TOOL) -scheme 'MockingbirdTestsHost' $(XCODEBUILD_FLAGS) clean

setup-project:
	swift package resolve
	cp -rf Xcode/XCSchemes/*.xcscheme Mockingbird.xcodeproj/xcshareddata/xcschemes

save-xcschemes:
	cp -rf Mockingbird.xcodeproj/xcshareddata/xcschemes/*.xcscheme Xcode/XCSchemes

build:
	swift build $(SWIFT_BUILD_FLAGS) --product mockingbird

setup-cocoapods:
	(cd Examples/iOSMockingbirdExample-CocoaPods && pod install)
	(cd Examples/iOSMockingbirdExample-CocoaPods/Pods/MockingbirdFramework && make install-prebuilt)

setup-carthage:
	(cd Examples/iOSMockingbirdExample-Carthage && carthage update --platform ios)
	(cd Examples/iOSMockingbirdExample-Carthage/Carthage/Checkouts/mockingbird && make install-prebuilt)

test-cocoapods:
	$(eval DEVICE_UUID = $(shell xcrun simctl create $(SIMULATOR_NAME) $(SIMULATOR_DEVICE_TYPE) $(SIMULATOR_RUNTIME)))
	$(BUILD_TOOL) -destination "platform=iOS Simulator,id=$(DEVICE_UUID)" $(EXAMPLE_COCOAPODS_XCODEBUILD_FLAGS) test
	xcrun simctl delete $(DEVICE_UUID)

test-carthage:
	$(eval DEVICE_UUID = $(shell xcrun simctl create $(SIMULATOR_NAME) $(SIMULATOR_DEVICE_TYPE) $(SIMULATOR_RUNTIME)))
	$(BUILD_TOOL) -destination "platform=iOS Simulator,id=$(DEVICE_UUID)" $(EXAMPLE_CARTHAGE_XCODEBUILD_FLAGS) test
	xcrun simctl delete $(DEVICE_UUID)

test-examples: test-cocoapods test-carthage

clean-cocoapods:
	rm -f Examples/iOSMockingbirdExample-CocoaPods/MockingbirdMocks/*.generated.swift
	rm -f Examples/iOSMockingbirdExample-CocoaPods/Podfile.lock
	$(BUILD_TOOL) $(EXAMPLE_COCOAPODS_XCODEBUILD_FLAGS) clean

clean-carthage:
	rm -f Examples/iOSMockingbirdExample-Carthage/MockingbirdMocks/*.generated.swift
	rm -f Examples/iOSMockingbirdExample-Carthage/Cartfile.resolved
	$(BUILD_TOOL) $(EXAMPLE_CARTHAGE_XCODEBUILD_FLAGS) clean

clean-test-examples: clean-cocoapods clean-carthage test-examples

test:
	$(BUILD_TOOL) -scheme 'MockingbirdTests' $(XCODEBUILD_FLAGS) test

clean-test: clean-xcode test

download:
	curl -Lo "$(ZIP_FILENAME)" "$(ZIP_RELEASE_URL)"
	unzip -o "$(ZIP_FILENAME)" "$(CLI_FILENAME)"
	@codesign -v -R "$(CLI_DESIGNATED_REQUIREMENT)" "$(CLI_FILENAME)" \
		&& echo "$(SUCCESS_MSG)" \
		|| $$(echo "$(ERROR_MSG)" >&2; exit 1)
	chmod +x "$(CLI_FILENAME)"

install: build
	install -d "$(BINARIES_FOLDER)"
	install "$(EXECUTABLE_PATH)" "$(BINARIES_FOLDER)"

install-prebuilt: download
	install -d "$(BINARIES_FOLDER)"
	install "$(CLI_FILENAME)" "$(BINARIES_FOLDER)"

uninstall:
	rm -rf "$(FRAMEWORKS_FOLDER)/Mockingbird.framework"
	rm -f "$(BINARIES_FOLDER)/$(CLI_FILENAME)"

installables: build
	install -d "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)"
	install "$(EXECUTABLE_PATH)" "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)"

package: installables
	pkgbuild \
		--identifier "$(PKG_BUNDLE_IDENTIFIER)" \
		--install-location "/" \
		--root "$(TEMPORARY_FOLDER)" \
		--version "$(VERSION_STRING)" \
		"$(OUTPUT_PACKAGE)"

signed-package: installables
	pkgbuild \
		--identifier "$(PKG_BUNDLE_IDENTIFIER)" \
		--install-location "/" \
		--root "$(TEMPORARY_FOLDER)" \
		--version "$(VERSION_STRING)" \
		--sign "$(PKG_IDENTITY_NAME)" \
		"$(OUTPUT_PACKAGE)"

zip: installables
	cp -f "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)/$(CLI_FILENAME)" "$(TEMPORARY_FOLDER)"
	cp -f "$(LICENSE_PATH)" "$(TEMPORARY_FOLDER)"
	(cd "$(TEMPORARY_FOLDER)"; zip -yr - "$(CLI_FILENAME)" "LICENSE") > "$(OUTPUT_ZIP)"

signed-zip: installables
	cp -f "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)/$(CLI_FILENAME)" "$(TEMPORARY_FOLDER)"
	cp -f "$(LICENSE_PATH)" "$(TEMPORARY_FOLDER)"
	codesign --sign "$(ZIP_IDENTITY_NAME)" "$(TEMPORARY_FOLDER)/$(CLI_FILENAME)"
	codesign -d -r- "$(TEMPORARY_FOLDER)/$(CLI_FILENAME)" | cut -c 15- > "$(CLI_DESIGNATED_REQUIREMENT)"
	# Double-check that the signed binary satisfies the explicit designated requirements.
	codesign -v -R "$(CLI_DESIGNATED_REQUIREMENT)" "$(TEMPORARY_FOLDER)/$(CLI_FILENAME)"
	(cd "$(TEMPORARY_FOLDER)"; zip -yr - "$(CLI_FILENAME)" "LICENSE") > "$(OUTPUT_ZIP)"	

release: clean package zip
signed-release: clean signed-package signed-zip

get-version:
	@echo $(VERSION_STRING)

get-zip-sha256:
	@echo $(shell shasum --algorithm 256 "$(OUTPUT_ZIP)" | awk '{print $$1}')

%:
	@:
