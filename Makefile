TEMPORARY_FOLDER_ROOT?=/tmp
PREFIX?=/usr/local
BIN_DIR?=$(PREFIX)/bin
BUILD_TOOL?=xcodebuild
VERIFY_SIGNATURES?=1
AC_USERNAME?=
AC_PASSWORD?=
PKG_IDENTITY?=Developer ID Installer: Bird Rides, Inc. (P2T4T6R4SL)
BIN_IDENTITY?=Developer ID Application: Bird Rides, Inc. (P2T4T6R4SL)
MKB_INSTALLABLE?=0
MKB_VERSION?=$(shell /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$(CLI_BUNDLE_PLIST)")
REPO_URL?=https://github.com/birdrides/mockingbird
ARTIFACTS_URL?=$(REPO_URL)/releases/download
ZIP_RELEASE_URL?=$(ARTIFACTS_URL)/$(MKB_VERSION)/$(ZIP_FILENAME)

# The `DSTROOT` must be kept seperate when running xcodebuild outside of Xcode.
TEMPORARY_FOLDER=$(TEMPORARY_FOLDER_ROOT)/Mockingbird.make.dst
TEMPORARY_INSTALLER_FOLDER=$(TEMPORARY_FOLDER)/install
XCODEBUILD_DERIVED_DATA=$(TEMPORARY_FOLDER)/xcodebuild/DerivedData/MockingbirdFramework
XCODE_PATH=$(shell xcode-select --print-path)
DEFAULT_XCODE_RPATH=$(XCODE_PATH)/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/macosx

SIMULATOR_NAME=iphone11-mockingbird
SIMULATOR_DEVICE_TYPE=com.apple.CoreSimulator.SimDeviceType.iPhone-11
SIMULATOR_RUNTIME=$(shell xcrun simctl list runtimes | pcregrep -o1 '(com\.apple\.CoreSimulator\.SimRuntime\.iOS\-.*)')

# Needs to be kept in sync with `LoadDylib.swift` and `build-framework-cli.yml`.
$(eval MKB_INSTALLABLE_FLAG = $(shell [[ $(MKB_INSTALLABLE) -eq 1 ]] && echo '-Xswiftc -DMKB_INSTALLABLE' || echo ''))

SWIFT_BUILD_ENV=MKB_BUILD_CLI=1
SWIFT_BUILD_FLAGS=--configuration release -Xlinker -weak-l_InternalSwiftSyntaxParser $(MKB_INSTALLABLE_FLAG)

# CLI build configuration.
XCODEBUILD_FLAGS=-project 'Mockingbird.xcodeproj' DSTROOT=$(TEMPORARY_FOLDER)
XCODEBUILD_MACOS_FLAGS=$(XCODEBUILD_FLAGS) -destination 'platform=OS X'
XCODEBUILD_FRAMEWORK_FLAGS=$(XCODEBUILD_FLAGS) \
	-derivedDataPath "$(XCODEBUILD_DERIVED_DATA)" \
	ONLY_ACTIVE_ARCH=NO \
	DEFINES_MODULE=YES \
	STRIP_INSTALLED_PRODUCT=NO \
	SKIP_INSTALL=YES

# Example project build configuration.
EXAMPLE_XCODEBUILD_FLAGS=DSTROOT=$(TEMPORARY_FOLDER)
EXAMPLE_COCOAPODS_XCODEBUILD_FLAGS=$(EXAMPLE_XCODEBUILD_FLAGS) \
	-workspace 'Examples/iOSMockingbirdExample-CocoaPods/iOSMockingbirdExample-CocoaPods.xcworkspace' \
	-scheme 'iOSMockingbirdExample-CocoaPods'
EXAMPLE_CARTHAGE_XCODEBUILD_FLAGS=$(EXAMPLE_XCODEBUILD_FLAGS) \
	-project 'Examples/iOSMockingbirdExample-Carthage/iOSMockingbirdExample-Carthage.xcodeproj' \
	-scheme 'iOSMockingbirdExample-Carthage'
EXAMPLE_SPM_XCODEBUILD_FLAGS=$(EXAMPLE_XCODEBUILD_FLAGS) \
	-project 'Examples/iOSMockingbirdExample-SPM/iOSMockingbirdExample-SPM.xcodeproj' \
	-scheme 'iOSMockingbirdExample-SPM'

PKG_BUNDLE_IDENTIFIER=co.bird.mockingbird
CLI_DESIGNATED_REQUIREMENT=Codesigning/MockingbirdCli.dr
CLI_FILENAME=mockingbird
CLI_BUNDLE_PLIST=Sources/MockingbirdCli/Info.plist

# Needs to be kept in sync with the launcher.
$(eval ZIP_FILENAME = $(shell [[ $(MKB_INSTALLABLE) -eq 1 ]] && echo 'Mockingbird-installable.zip' || echo 'Mockingbird.zip'))

FRAMEWORK_FILENAME=Mockingbird.framework
MACOS_FRAMEWORK_FILENAME=Mockingbird-macOS.framework
IPHONESIMULATOR_FRAMEWORK_FILENAME=Mockingbird-iOS.framework
APPLETVSIMULATOR_FRAMEWORK_FILENAME=Mockingbird-tvOS.framework

EXECUTABLE_PATH=$(shell $(SWIFT_BUILD_ENV) swift build $(SWIFT_BUILD_FLAGS) --show-bin-path)/mockingbird

MACOS_FRAMEWORK_FOLDER=$(XCODEBUILD_DERIVED_DATA)/Build/Products/Release
MACOS_FRAMEWORK_PATH=$(MACOS_FRAMEWORK_FOLDER)/$(FRAMEWORK_FILENAME)

IPHONESIMULATOR_FRAMEWORK_FOLDER=$(XCODEBUILD_DERIVED_DATA)/Build/Products/Release-iphonesimulator
IPHONESIMULATOR_FRAMEWORK_PATH=$(IPHONESIMULATOR_FRAMEWORK_FOLDER)/$(FRAMEWORK_FILENAME)

APPLETVSIMULATOR_FRAMEWORK_FOLDER=$(XCODEBUILD_DERIVED_DATA)/Build/Products/Release-appletvsimulator
APPLETVSIMULATOR_FRAMEWORK_PATH=$(APPLETVSIMULATOR_FRAMEWORK_FOLDER)/$(FRAMEWORK_FILENAME)

LICENSE_FILENAME=LICENSE
LICENSE_PATH=$(shell pwd)/$(LICENSE_FILENAME)

INSTALLABLE_FILENAMES="$(CLI_FILENAME)" \
	"$(MACOS_FRAMEWORK_FILENAME)" \
	"$(IPHONESIMULATOR_FRAMEWORK_FILENAME)" \
	"$(APPLETVSIMULATOR_FRAMEWORK_FILENAME)" \
	"$(LICENSE_FILENAME)"

STARTER_PACK_FOLDER=MockingbirdSupport

OUTPUT_PACKAGE=Mockingbird.pkg
OUTPUT_ZIP=Mockingbird.zip
OUTPUT_STARTER_PACK_ZIP=MockingbirdSupport.zip
OUTPUT_DOCS_FOLDER=docs/$(MKB_VERSION)

SUCCESS_MSG=✅ Verified the CLI binary code signature
ERROR_MSG=❌ The CLI binary is not signed with the expected code signature! (Set VERIFY_SIGNATURES=0 to ignore this error.)

REDIRECT_DOCS_PAGE=<!DOCTYPE html><html><head><meta http-equiv="refresh" content="0;url=/mockingbird/$(MKB_VERSION)/"></head></html>

.PHONY: all
all: build

.PHONY: clean-mocks
clean-mocks:
	rm -f Tests/MockingbirdTests/Mocks/*.generated.swift
	rm -f Mockingbird.xcodeproj/MockingbirdCache/*.lock

.PHONY: clean-temporary-files
clean-temporary-files:
	rm -rf "$(TEMPORARY_FOLDER)"

.PHONY: clean-xcode
clean-xcode: clean-temporary-files
	$(BUILD_TOOL) -scheme 'MockingbirdFramework' $(XCODEBUILD_MACOS_FLAGS) clean
	$(BUILD_TOOL) -scheme 'MockingbirdTestsHost' $(XCODEBUILD_MACOS_FLAGS) clean

.PHONY: clean-swift
clean-swift:
	swift package clean

.PHONY: clean-installables
clean-installables:
	rm -f "$(OUTPUT_PACKAGE)"
	rm -f "$(OUTPUT_ZIP)"

.PHONY: clean-dylibs
clean-dylibs:
	rm -f Sources/MockingbirdCli/Libraries/*.generated.swift

.PHONY: clean
clean: clean-mocks clean-xcode clean-swift clean-installables clean-dylibs

.PHONY: setup-project
setup-project:
	cp -rf .xcode/xcschemes/*.xcscheme Mockingbird.xcodeproj/xcshareddata/xcschemes

.PHONY: bootstrap
bootstrap: setup-project

.PHONY: save-xcschemes
save-xcschemes:
	cp -rf Mockingbird.xcodeproj/xcshareddata/xcschemes/*.xcscheme .xcode/xcschemes

.PHONY: print-debug-info
print-debug-info:
	@echo "Mockingbird version: $(MKB_VERSION)"
	@echo "Installable build variant: $(MKB_INSTALLABLE)"
	@echo "Installation prefix: $(PREFIX)"
	@echo "Binary directory: $(BIN_DIR)"
	@echo "Temporary folder: $(TEMPORARY_FOLDER)"
	@echo "Mockingbird rpath: /tmp/mockingbird/$(MKB_VERSION)/libs"
	@echo "Mockingbird rpath: /var/tmp/mockingbird/$(MKB_VERSION)/libs"
	@echo "Build tool: $(BUILD_TOOL)"
	$(eval XCODE_PATH_VAR = $(XCODE_PATH))
	@echo "Xcode path: $(XCODE_PATH_VAR)"
	@echo "Built CLI path: $(EXECUTABLE_PATH)"
	$(eval CURRENT_REV = $(shell git rev-parse HEAD))
	@echo "Current revision: $(CURRENT_REV)"
	$(eval SWIFT_VERSION = $(shell swift --version))
	@echo "Swift version: $(SWIFT_VERSION)"
	$(eval XCODEBUILD_VERSION = $(shell xcodebuild -version))
	@echo "Xcodebuild version: $(XCODEBUILD_VERSION)"
	@echo "Swift build flags: $(SWIFT_BUILD_FLAGS)"
	@echo "Swift build env: $(SWIFT_BUILD_ENV)"
	@echo "Simulator runtime: $(SIMULATOR_RUNTIME)"
	@echo "Zip release URL: $(ZIP_RELEASE_URL)"

.PHONY: generate-embedded-dylibs
generate-embedded-dylibs:
	Sources/MockingbirdCli/Scripts/generate-resource-file.sh \
		Sources/MockingbirdCli/Libraries/lib_InternalSwiftSyntaxParser.dylib \
		Sources/MockingbirdCli/Libraries/SwiftSyntaxParserDylib.generated.swift \
		'swiftSyntaxParserDylib'

.PHONY: build-cli
build-cli: generate-embedded-dylibs
	$(SWIFT_BUILD_ENV) swift build $(SWIFT_BUILD_FLAGS) --product mockingbird
	$(eval RPATH = $(DEFAULT_XCODE_RPATH))
	install_name_tool -delete_rpath "$(RPATH)" "$(EXECUTABLE_PATH)"
	install_name_tool -add_rpath '@executable_path' "$(EXECUTABLE_PATH)"
	install_name_tool -add_rpath "/var/tmp/mockingbird/$(MKB_VERSION)/libs" "$(EXECUTABLE_PATH)"
	install_name_tool -add_rpath "/tmp/mockingbird/$(MKB_VERSION)/libs" "$(EXECUTABLE_PATH)"

.PHONY: build-framework-macos
build-framework-macos:
	$(BUILD_TOOL) -scheme 'MockingbirdFramework' -configuration 'Release' -sdk macosx -arch x86_64 $(XCODEBUILD_FRAMEWORK_FLAGS)

.PHONY: build-framework-iphonesimulator
build-framework-iphonesimulator:
	$(BUILD_TOOL) -scheme 'MockingbirdFramework' -configuration 'Release' -sdk iphonesimulator -arch x86_64 $(XCODEBUILD_FRAMEWORK_FLAGS)

.PHONY: build-framework-appletvsimulator
build-framework-appletvsimulator:
	$(BUILD_TOOL) -scheme 'MockingbirdFramework' -configuration 'Release' -sdk appletvsimulator -arch arm64 $(XCODEBUILD_FRAMEWORK_FLAGS)

.PHONY: build-framework
build-framework: build-framework-macos build-framework-iphonesimulator build-framework-appletvsimulator

.PHONY: build
build: build-cli build-framework

.PHONY: setup-cocoapods
setup-cocoapods:
	(cd Examples/iOSMockingbirdExample-CocoaPods && pod install)
	(cd Examples/iOSMockingbirdExample-CocoaPods/Pods/MockingbirdFramework && make install-prebuilt)

.PHONY: setup-carthage
setup-carthage:
	(cd Examples/iOSMockingbirdExample-Carthage && carthage update --use-xcframeworks --platform ios)
	(cd Examples/iOSMockingbirdExample-Carthage/Carthage/Checkouts/mockingbird && make install-prebuilt)

.PHONY: setup-spm
setup-spm:
	(cd Examples/iOSMockingbirdExample-SPM && xcodebuild -resolvePackageDependencies)
	$(eval DERIVED_DATA = $(shell xcodebuild -project Examples/iOSMockingbirdExample-SPM/iOSMockingbirdExample-SPM.xcodeproj -showBuildSettings | pcregrep -o1 'OBJROOT = (/.*)/Build'))
	(cd $(DERIVED_DATA)/SourcePackages/checkouts/mockingbird && make install-prebuilt)

.PHONY: test-cocoapods
test-cocoapods: setup-cocoapods
	$(eval DEVICE_UUID = $(shell xcrun simctl create "$(SIMULATOR_NAME)" "$(SIMULATOR_DEVICE_TYPE)" "$(SIMULATOR_RUNTIME)"))
	$(BUILD_TOOL) -destination "platform=iOS Simulator,id=$(DEVICE_UUID)" $(EXAMPLE_COCOAPODS_XCODEBUILD_FLAGS) test
	xcrun simctl delete "$(DEVICE_UUID)"

.PHONY: test-carthage
test-carthage: setup-carthage
	$(eval DEVICE_UUID = $(shell xcrun simctl create "$(SIMULATOR_NAME)" "$(SIMULATOR_DEVICE_TYPE)" "$(SIMULATOR_RUNTIME)"))
	$(BUILD_TOOL) -destination "platform=iOS Simulator,id=$(DEVICE_UUID)" $(EXAMPLE_CARTHAGE_XCODEBUILD_FLAGS) test
	xcrun simctl delete "$(DEVICE_UUID)"

.PHONY: test-spm
test-spm: setup-spm
	$(eval DEVICE_UUID = $(shell xcrun simctl create "$(SIMULATOR_NAME)" "$(SIMULATOR_DEVICE_TYPE)" "$(SIMULATOR_RUNTIME)"))
	$(BUILD_TOOL) -destination "platform=iOS Simulator,id=$(DEVICE_UUID)" $(EXAMPLE_SPM_XCODEBUILD_FLAGS) test
	xcrun simctl delete "$(DEVICE_UUID)"

.PHONY: test-examples
test-examples: test-cocoapods test-carthage test-spm

.PHONY: clean-cocoapods
clean-cocoapods: clean-temporary-files
	rm -f Examples/iOSMockingbirdExample-CocoaPods/MockingbirdMocks/*.generated.swift
	rm -f Examples/iOSMockingbirdExample-CocoaPods/iOSMockingbirdExample-CocoaPods.xcodeproj/MockingbirdCache/*.lock
	rm -f Examples/iOSMockingbirdExample-CocoaPods/Podfile.lock
	rm -rf Examples/iOSMockingbirdExample-CocoaPods/Pods
	$(BUILD_TOOL) $(EXAMPLE_COCOAPODS_XCODEBUILD_FLAGS) clean

.PHONY: clean-carthage
clean-carthage: clean-temporary-files
	rm -f Examples/iOSMockingbirdExample-Carthage/MockingbirdMocks/*.generated.swift
	rm -f Examples/iOSMockingbirdExample-Carthage/iOSMockingbirdExample-Carthage.xcodeproj/MockingbirdCache/*.lock
	rm -f Examples/iOSMockingbirdExample-Carthage/Cartfile.resolved
	rm -rf Examples/iOSMockingbirdExample-Carthage/Carthage
	$(BUILD_TOOL) $(EXAMPLE_CARTHAGE_XCODEBUILD_FLAGS) clean

.PHONY: clean-spm
clean-spm: clean-temporary-files
	rm -f Examples/iOSMockingbirdExample-SPM/MockingbirdMocks/*.generated.swift
	rm -f Examples/iOSMockingbirdExample-SPM/iOSMockingbirdExample-SPM.xcodeproj/MockingbirdCache/*.lock
	rm -f Examples/iOSMockingbirdExample-SPM/iOSMockingbirdExample-SPM.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved
	$(BUILD_TOOL) $(EXAMPLE_SPM_XCODEBUILD_FLAGS) clean

.PHONY: clean-test-examples
clean-test-examples: clean-cocoapods clean-carthage clean-spm test-examples

.PHONY: test
test:
	$(BUILD_TOOL) -scheme 'MockingbirdTests' $(XCODEBUILD_MACOS_FLAGS) test

.PHONY: clean-test
clean-test: clean test

.PHONY: test-flaky
test-flaky:
	$(BUILD_TOOL) -scheme 'MockingbirdTests' $(XCODEBUILD_MACOS_FLAGS) test
	mv -f Tests/MockingbirdTests/Mocks/MockingbirdTestsHostMocks.generated.swift \
		Tests/MockingbirdTests/Mocks/MockingbirdTestsHostMocks.tmp.generated.swift

	set -e
	for i in {1..4}; do \
		$(BUILD_TOOL) -scheme 'MockingbirdTests' $(XCODEBUILD_MACOS_FLAGS) test; \
		diff Tests/MockingbirdTests/Mocks/MockingbirdTestsHostMocks.generated.swift \
			Tests/MockingbirdTests/Mocks/MockingbirdTestsHostMocks.tmp.generated.swift; \
		[[ $$? == 0 ]] && echo "[Test $$i completed]" || exit 1; \
	done

.PHONY: setup-swiftdoc
setup-swiftdoc:
	(cd docs/swift-doc && make install)

.PHONY: clean-docs
clean-docs:
	rm -rf "$(OUTPUT_DOCS_FOLDER)"
	rm -rf docs/latest
	rm -f docs/index.html

docs/latest:
	mkdir $@

docs/index.html docs/latest/index.html: | docs/latest
	echo '$(REDIRECT_DOCS_PAGE)' > $@

.PHONY: docs
docs: clean-docs setup-swiftdoc docs/index.html docs/latest/index.html
	/usr/local/bin/swift-doc generate \
		Sources/MockingbirdFramework \
		--module-name Mockingbird \
		--version "$(MKB_VERSION)" \
		--output "$(OUTPUT_DOCS_FOLDER)" \
		--format html \
		--base-url "/mockingbird/$(MKB_VERSION)"
	cp -f docs/swift-doc/Resources/all.min.css "$(OUTPUT_DOCS_FOLDER)/all.css"

.PHONY: download
download:
	$(eval CURL_AUTH_HEADER = $(shell [[ -z "${GH_ACCESS_TOKEN}" ]] || echo '-H "Authorization: token' ${GH_ACCESS_TOKEN}'"'))
	curl $(CURL_AUTH_HEADER) --progress-bar -Lo "$(ZIP_FILENAME)" "$(ZIP_RELEASE_URL)"
	mkdir -p "$(BIN_DIR)"
	unzip -o "$(ZIP_FILENAME)" "$(CLI_FILENAME)" -d "$(BIN_DIR)"
	chmod +x "$(BIN_DIR)/$(CLI_FILENAME)"
	@if [[ $(VERIFY_SIGNATURES) -eq 1 ]]; then $(MAKE) verify; fi

.PHONY: verify
verify:
	@codesign -v -R "$(CLI_DESIGNATED_REQUIREMENT)" "$(BIN_DIR)/$(CLI_FILENAME)" \
		&& echo "$(SUCCESS_MSG)" \
		|| $$(echo "$(ERROR_MSG)" >&2; exit 1)

.PHONY: install
install: build-cli
	install -d "$(BIN_DIR)"
	install "$(EXECUTABLE_PATH)" "$(BIN_DIR)"

.PHONY: install-prebuilt
install-prebuilt: download
	install -d "$(BIN_DIR)"
	install "$(BIN_DIR)/$(CLI_FILENAME)" "$(BIN_DIR)"

.PHONY: uninstall
uninstall:
	rm -f "$(BIN_DIR)/$(CLI_FILENAME)"

.PHONY: installables
installables: build
	install -d "$(TEMPORARY_INSTALLER_FOLDER)$(BIN_DIR)"
	install "$(EXECUTABLE_PATH)" "$(TEMPORARY_INSTALLER_FOLDER)$(BIN_DIR)"

.PHONY: bundle-artifacts
bundle-artifacts:
	mkdir -p "$(TEMPORARY_INSTALLER_FOLDER)$(BIN_DIR)"
	cp -f "$(EXECUTABLE_PATH)" "$(TEMPORARY_INSTALLER_FOLDER)$(BIN_DIR)"

.PHONY: signed-installables
signed-installables: build bundle-artifacts
	codesign --sign "$(BIN_IDENTITY)" -v --timestamp --options runtime \
		"$(TEMPORARY_INSTALLER_FOLDER)$(BIN_DIR)/$(CLI_FILENAME)"

.PHONY: package
package: installables
	pkgbuild \
		--identifier "$(PKG_BUNDLE_IDENTIFIER)" \
		--install-location "/" \
		--root "$(TEMPORARY_INSTALLER_FOLDER)" \
		--version "$(MKB_VERSION)" \
		"$(OUTPUT_PACKAGE)"

.PHONY: signed-package
signed-package: signed-installables
	pkgbuild \
		--identifier "$(PKG_BUNDLE_IDENTIFIER)" \
		--install-location "/" \
		--root "$(TEMPORARY_INSTALLER_FOLDER)" \
		--version "$(MKB_VERSION)" \
		--sign "$(PKG_IDENTITY)" \
		"$(OUTPUT_PACKAGE)"
	@[[ -z "$(AC_USERNAME)" ]] || xcrun altool \
		--notarize-app \
		--primary-bundle-id "$(PKG_BUNDLE_IDENTIFIER).pkg" \
		--username "$(AC_USERNAME)" \
		--password "$(AC_PASSWORD)" \
		--file "$(OUTPUT_PACKAGE)"

.PHONY: stapled-package
stapled-package:
	xcrun stapler staple "$(OUTPUT_PACKAGE)"

.PHONY: prepare-zip
prepare-zip:
	cp -f "$(TEMPORARY_INSTALLER_FOLDER)$(BIN_DIR)/$(CLI_FILENAME)" "$(TEMPORARY_INSTALLER_FOLDER)"
	cp -f "$(LICENSE_PATH)" "$(TEMPORARY_INSTALLER_FOLDER)"

.PHONY: archive
archive:
	(cd "$(TEMPORARY_INSTALLER_FOLDER)"; zip -yr - $(INSTALLABLE_FILENAMES)) > "$(OUTPUT_ZIP)"

.PHONY: zip
zip: installables prepare-zip archive

.PHONY: signed-zip
signed-zip: signed-installables prepare-zip archive
	# Generate designated requirement.
	codesign -d -r- "$(TEMPORARY_INSTALLER_FOLDER)/$(CLI_FILENAME)" | cut -c 15- > "$(CLI_DESIGNATED_REQUIREMENT)"
	codesign -vvv -R "$(CLI_DESIGNATED_REQUIREMENT)" "$(TEMPORARY_INSTALLER_FOLDER)/$(CLI_FILENAME)"

	@[[ -z "$(AC_USERNAME)" ]] || xcrun altool \
		--notarize-app \
		--primary-bundle-id "$(PKG_BUNDLE_IDENTIFIER).zip" \
		--username "$(AC_USERNAME)" \
		--password "$(AC_PASSWORD)" \
		--file "$(OUTPUT_ZIP)"

.PHONY: starter-pack-zip
starter-pack-zip:
	(cd Sources; zip -yr - $(STARTER_PACK_FOLDER)) > "$(OUTPUT_STARTER_PACK_ZIP)"

.PHONY: release
release: package zip starter-pack-zip

.PHONY: signed-release
signed-release: signed-package signed-zip starter-pack-zip

.PHONY: get-version
get-version:
	@echo $(MKB_VERSION)

.PHONY: get-zip-sha256
get-zip-sha256:
	@echo $(shell shasum --algorithm 256 "$(OUTPUT_ZIP)" | awk '{print $$1}')

get-repo-url:
	@echo $(REPO_URL)

get-release-url:
	@echo $(ZIP_RELEASE_URL)

%:
	@:
