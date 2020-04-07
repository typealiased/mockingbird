TEMPORARY_FOLDER_ROOT?=/tmp
PREFIX?=/usr/local
BUILD_TOOL?=xcodebuild

# Prevent bad things from happening when cleaning the temporary folder.
TEMPORARY_FOLDER=$(TEMPORARY_FOLDER_ROOT)/Mockingbird.make.dst
TEMPORARY_INSTALLER_FOLDER=$(TEMPORARY_FOLDER)/install
XCODEBUILD_DERIVED_DATA=$(TEMPORARY_FOLDER)/xcodebuild/DerivedData/MockingbirdFramework

SIMULATOR_NAME=iphone11-mockingbird
SIMULATOR_DEVICE_TYPE=com.apple.CoreSimulator.SimDeviceType.iPhone-11
SIMULATOR_RUNTIME=com.apple.CoreSimulator.SimRuntime.iOS-13-3

SWIFT_BUILD_FLAGS=--configuration release
XCODEBUILD_FLAGS=-project 'Mockingbird.xcodeproj' DSTROOT=$(TEMPORARY_FOLDER)
XCODEBUILD_MACOS_FLAGS=$(XCODEBUILD_FLAGS) -destination 'platform=OS X'
XCODEBUILD_FRAMEWORK_FLAGS=$(XCODEBUILD_FLAGS) \
	-derivedDataPath "$(XCODEBUILD_DERIVED_DATA)" \
	ONLY_ACTIVE_ARCH=NO \
	DEFINES_MODULE=YES \
	STRIP_INSTALLED_PRODUCT=NO \
	SKIP_INSTALL=YES

EXAMPLE_XCODEBUILD_FLAGS=DSTROOT=$(TEMPORARY_FOLDER)
EXAMPLE_COCOAPODS_XCODEBUILD_FLAGS=$(EXAMPLE_XCODEBUILD_FLAGS) \
	-workspace 'Examples/iOSMockingbirdExample-CocoaPods/iOSMockingbirdExample-CocoaPods.xcworkspace' \
	-scheme 'iOSMockingbirdExample-CocoaPods'
EXAMPLE_CARTHAGE_XCODEBUILD_FLAGS=$(EXAMPLE_XCODEBUILD_FLAGS) \
	-project 'Examples/iOSMockingbirdExample-Carthage/iOSMockingbirdExample-Carthage.xcodeproj' \
	-scheme 'iOSMockingbirdExample-Carthage'

FRAMEWORKS_FOLDER=/Library/Frameworks
BINARIES_FOLDER=$(PREFIX)/bin

PKG_BUNDLE_IDENTIFIER=co.bird.mockingbird
PKG_IDENTITY_NAME=3rd Party Mac Developer Installer: Bird Rides, Inc. (P2T4T6R4SL)
ZIP_IDENTITY_NAME=3rd Party Mac Developer Application: Bird Rides, Inc. (P2T4T6R4SL)
CLI_DESIGNATED_REQUIREMENT=Codesigning/MockingbirdCli.dr
ZIP_FILENAME=Mockingbird.zip
CLI_FILENAME=mockingbird

FRAMEWORK_FILENAME=Mockingbird.framework

MACOS_FRAMEWORK_FILENAME=Mockingbird-macOS.framework
IPHONESIMULATOR_FRAMEWORK_FILENAME=Mockingbird-iOS.framework
APPLETVSIMULATOR_FRAMEWORK_FILENAME=Mockingbird-tvOS.framework

EXECUTABLE_PATH=$(shell swift build $(SWIFT_BUILD_FLAGS) --show-bin-path)/mockingbird

MACOS_FRAMEWORK_FOLDER=$(XCODEBUILD_DERIVED_DATA)/Build/Products/Release
MACOS_FRAMEWORK_PATH=$(MACOS_FRAMEWORK_FOLDER)/$(FRAMEWORK_FILENAME)

IPHONESIMULATOR_FRAMEWORK_FOLDER=$(XCODEBUILD_DERIVED_DATA)/Build/Products/Release-iphonesimulator
IPHONESIMULATOR_FRAMEWORK_PATH=$(IPHONESIMULATOR_FRAMEWORK_FOLDER)/$(FRAMEWORK_FILENAME)

APPLETVSIMULATOR_FRAMEWORK_FOLDER=$(XCODEBUILD_DERIVED_DATA)/Build/Products/Release-appletvsimulator
APPLETVSIMULATOR_FRAMEWORK_PATH=$(APPLETVSIMULATOR_FRAMEWORK_FOLDER)/$(FRAMEWORK_FILENAME)

LICENSE_FILENAME=LICENSE
LICENSE_PATH=$(shell pwd)/$(LICENSE_FILENAME)

INSTALLABLE_FILENAMES="$(CLI_FILENAME)" "$(MACOS_FRAMEWORK_FILENAME)" "$(IPHONESIMULATOR_FRAMEWORK_FILENAME)" "$(APPLETVSIMULATOR_FRAMEWORK_FILENAME)" "$(LICENSE_FILENAME)"

OUTPUT_PACKAGE=Mockingbird.pkg
OUTPUT_ZIP=Mockingbird.zip

CLI_BUNDLE_PLIST=MockingbirdCli/Info.plist
VERSION_STRING=$(shell /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$(CLI_BUNDLE_PLIST)")

GITHUB_REPO_URL=https://github.com/birdrides/mockingbird
ZIP_RELEASE_URL=$(GITHUB_REPO_URL)/releases/download/$(VERSION_STRING)/$(ZIP_FILENAME)
SUCCESS_MSG=Verified the Mockingbird CLI binary
ERROR_MSG=[ERROR] The downloaded Mockingbird CLI binary does not have the expected code signature! See <Codesigning/README.md>.

.PHONY: all \
		clean-mocks \
		clean-temporary-files \
		clean-xcode \
		clean-swift \
		clean-installables \
		clean \
		setup-project \
		save-xcschemes \
		build-cli \
		build-framework-macos \
		build-framework-iphonesimulator \
		build-framework-appletvsimulator \
		build-framework \
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
		install-prebuilt \
		uninstall \
		package \
		signed-package \
		prepare-zip \
		zip \
		signed-zip \
		release \
		signed-release \
		get-version \
		get-zip-sha256

all: build

clean-mocks:
	rm -f MockingbirdMocks/*.generated.swift

clean-temporary-files:
	rm -rf "$(TEMPORARY_FOLDER)"

clean-xcode: clean-temporary-files
	$(BUILD_TOOL) -scheme 'MockingbirdFramework' $(XCODEBUILD_MACOS_FLAGS) clean
	$(BUILD_TOOL) -scheme 'MockingbirdTestsHost' $(XCODEBUILD_MACOS_FLAGS) clean

clean-swift:
	swift package clean

clean-installables:
	rm -f "$(OUTPUT_PACKAGE)"
	rm -f "$(OUTPUT_ZIP)"

clean: clean-mocks clean-xcode clean-swift clean-installables

setup-project:
	swift package resolve
	cp -rf Xcode/XCSchemes/*.xcscheme Mockingbird.xcodeproj/xcshareddata/xcschemes

save-xcschemes:
	cp -rf Mockingbird.xcodeproj/xcshareddata/xcschemes/*.xcscheme Xcode/XCSchemes

build-cli:
	swift build $(SWIFT_BUILD_FLAGS) --product mockingbird

build-framework-macos:
	$(BUILD_TOOL) -scheme 'MockingbirdFramework' -configuration 'Release' -sdk macosx -arch x86_64 $(XCODEBUILD_FRAMEWORK_FLAGS)

build-framework-iphonesimulator:
	$(BUILD_TOOL) -scheme 'MockingbirdFramework' -configuration 'Release' -sdk iphonesimulator -arch x86_64 -arch i386 $(XCODEBUILD_FRAMEWORK_FLAGS)

build-framework-appletvsimulator:
	$(BUILD_TOOL) -scheme 'MockingbirdFramework' -configuration 'Release' -sdk appletvsimulator -arch arm64 $(XCODEBUILD_FRAMEWORK_FLAGS)

build-framework: build-framework-macos build-framework-iphonesimulator build-framework-appletvsimulator

build: build-cli build-framework

setup-cocoapods:
	(cd Examples/iOSMockingbirdExample-CocoaPods && pod install)
	(cd Examples/iOSMockingbirdExample-CocoaPods/Pods/MockingbirdFramework && make install-prebuilt)

setup-carthage:
	(cd Examples/iOSMockingbirdExample-Carthage && carthage update --platform ios)
	(cd Examples/iOSMockingbirdExample-Carthage/Carthage/Checkouts/mockingbird && make install-prebuilt)

test-cocoapods: setup-cocoapods
	$(eval DEVICE_UUID = $(shell xcrun simctl create "$(SIMULATOR_NAME)" "$(SIMULATOR_DEVICE_TYPE)" "$(SIMULATOR_RUNTIME)"))
	$(BUILD_TOOL) -destination "platform=iOS Simulator,id=$(DEVICE_UUID)" $(EXAMPLE_COCOAPODS_XCODEBUILD_FLAGS) test
	xcrun simctl delete "$(DEVICE_UUID)"

test-carthage: setup-carthage
	$(eval DEVICE_UUID = $(shell xcrun simctl create "$(SIMULATOR_NAME)" "$(SIMULATOR_DEVICE_TYPE)" "$(SIMULATOR_RUNTIME)"))
	$(BUILD_TOOL) -destination "platform=iOS Simulator,id=$(DEVICE_UUID)" $(EXAMPLE_CARTHAGE_XCODEBUILD_FLAGS) test
	xcrun simctl delete "$(DEVICE_UUID)"

test-examples: test-cocoapods test-carthage

clean-cocoapods: clean-temporary-files
	rm -f Examples/iOSMockingbirdExample-CocoaPods/MockingbirdMocks/*.generated.swift
	rm -f Examples/iOSMockingbirdExample-CocoaPods/Podfile.lock
	rm -rf Examples/iOSMockingbirdExample-CocoaPods/Pods
	$(BUILD_TOOL) $(EXAMPLE_COCOAPODS_XCODEBUILD_FLAGS) clean

clean-carthage: clean-temporary-files
	rm -f Examples/iOSMockingbirdExample-Carthage/MockingbirdMocks/*.generated.swift
	rm -f Examples/iOSMockingbirdExample-Carthage/Cartfile.resolved
	rm -rf Examples/iOSMockingbirdExample-Carthage/Carthage
	$(BUILD_TOOL) $(EXAMPLE_CARTHAGE_XCODEBUILD_FLAGS) clean

clean-test-examples: clean-cocoapods clean-carthage test-examples

test:
	$(BUILD_TOOL) -scheme 'MockingbirdTests' $(XCODEBUILD_MACOS_FLAGS) test

clean-test: clean test

download:
	curl -Lo "$(ZIP_FILENAME)" "$(ZIP_RELEASE_URL)"
	unzip -o "$(ZIP_FILENAME)" "$(CLI_FILENAME)"
	@codesign -v -R "$(CLI_DESIGNATED_REQUIREMENT)" "$(CLI_FILENAME)" \
		&& echo "$(SUCCESS_MSG)" \
		|| $$(echo "$(ERROR_MSG)" >&2; exit 1)
	chmod +x "$(CLI_FILENAME)"

install: build-cli
	install -d "$(BINARIES_FOLDER)"
	install "$(EXECUTABLE_PATH)" "$(BINARIES_FOLDER)"

install-prebuilt: download
	install -d "$(BINARIES_FOLDER)"
	install "$(CLI_FILENAME)" "$(BINARIES_FOLDER)"

uninstall:
	rm -f "$(BINARIES_FOLDER)/$(CLI_FILENAME)"
	rm -rf "$(FRAMEWORKS_FOLDER)/$(MACOS_FRAMEWORK_FILENAME)"
	rm -rf "$(FRAMEWORKS_FOLDER)/$(IPHONESIMULATOR_FRAMEWORK_PATH)"
	rm -rf "$(FRAMEWORKS_FOLDER)/$(APPLETVSIMULATOR_FRAMEWORK_PATH)"

installables: build
	install -d "$(TEMPORARY_INSTALLER_FOLDER)$(BINARIES_FOLDER)"
	install -d "$(TEMPORARY_INSTALLER_FOLDER)$(FRAMEWORKS_FOLDER)"

	install "$(EXECUTABLE_PATH)" "$(TEMPORARY_INSTALLER_FOLDER)$(BINARIES_FOLDER)"

	cp -rf "$(MACOS_FRAMEWORK_PATH)" "$(TEMPORARY_INSTALLER_FOLDER)$(FRAMEWORKS_FOLDER)/$(MACOS_FRAMEWORK_FILENAME)"
	cp -rf "$(IPHONESIMULATOR_FRAMEWORK_PATH)" "$(TEMPORARY_INSTALLER_FOLDER)$(FRAMEWORKS_FOLDER)/$(IPHONESIMULATOR_FRAMEWORK_FILENAME)"
	cp -rf "$(APPLETVSIMULATOR_FRAMEWORK_PATH)" "$(TEMPORARY_INSTALLER_FOLDER)$(FRAMEWORKS_FOLDER)/$(APPLETVSIMULATOR_FRAMEWORK_FILENAME)"

package: installables
	pkgbuild \
		--identifier "$(PKG_BUNDLE_IDENTIFIER)" \
		--install-location "/" \
		--root "$(TEMPORARY_INSTALLER_FOLDER)" \
		--version "$(VERSION_STRING)" \
		"$(OUTPUT_PACKAGE)"

signed-package: installables
	pkgbuild \
		--identifier "$(PKG_BUNDLE_IDENTIFIER)" \
		--install-location "/" \
		--root "$(TEMPORARY_INSTALLER_FOLDER)" \
		--version "$(VERSION_STRING)" \
		--sign "$(PKG_IDENTITY_NAME)" \
		"$(OUTPUT_PACKAGE)"

prepare-zip:
	cp -f "$(TEMPORARY_INSTALLER_FOLDER)$(BINARIES_FOLDER)/$(CLI_FILENAME)" "$(TEMPORARY_INSTALLER_FOLDER)"
	cp -rf "$(TEMPORARY_INSTALLER_FOLDER)$(FRAMEWORKS_FOLDER)/$(MACOS_FRAMEWORK_FILENAME)" "$(TEMPORARY_INSTALLER_FOLDER)"
	cp -rf "$(TEMPORARY_INSTALLER_FOLDER)$(FRAMEWORKS_FOLDER)/$(IPHONESIMULATOR_FRAMEWORK_FILENAME)" "$(TEMPORARY_INSTALLER_FOLDER)"
	cp -rf "$(TEMPORARY_INSTALLER_FOLDER)$(FRAMEWORKS_FOLDER)/$(APPLETVSIMULATOR_FRAMEWORK_FILENAME)" "$(TEMPORARY_INSTALLER_FOLDER)"
	cp -f "$(LICENSE_PATH)" "$(TEMPORARY_INSTALLER_FOLDER)"

zip: installables prepare-zip
	(cd "$(TEMPORARY_INSTALLER_FOLDER)"; zip -yr - $(INSTALLABLE_FILENAMES)) > "$(OUTPUT_ZIP)"

signed-zip: installables prepare-zip
	codesign --sign "$(ZIP_IDENTITY_NAME)" "$(TEMPORARY_INSTALLER_FOLDER)/$(CLI_FILENAME)"
	codesign -d -r- "$(TEMPORARY_INSTALLER_FOLDER)/$(CLI_FILENAME)" | cut -c 15- > "$(CLI_DESIGNATED_REQUIREMENT)"

	# Double-check that the cli satisfies the explicit designated requirements.
	codesign -v -R "$(CLI_DESIGNATED_REQUIREMENT)" "$(TEMPORARY_INSTALLER_FOLDER)/$(CLI_FILENAME)"

	(cd "$(TEMPORARY_INSTALLER_FOLDER)"; zip -yr - $(INSTALLABLE_FILENAMES)) > "$(OUTPUT_ZIP)"

release: clean package zip

signed-release: clean signed-package signed-zip

get-version:
	@echo $(VERSION_STRING)

get-zip-sha256:
	@echo $(shell shasum --algorithm 256 "$(OUTPUT_ZIP)" | awk '{print $$1}')

%:
	@:
