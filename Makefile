TEMPORARY_FOLDER?=/tmp/MockingbirdCli.make.dst
PREFIX?=/usr/local

SWIFT_BUILD_FLAGS=--configuration release

EXECUTABLE_PATH=$(shell swift build $(SWIFT_BUILD_FLAGS) --show-bin-path)/mockingbird

FRAMEWORKS_FOLDER=/Library/Frameworks
BINARIES_FOLDER=/usr/local/bin
LICENSE_PATH="$(shell pwd)/LICENSE"
PKG_BUNDLE_IDENTIFIER=co.bird.mockingbird
PKG_IDENTITY_NAME=3rd Party Mac Developer Installer: Bird Rides, Inc. (P2T4T6R4SL)
ZIP_IDENTITY_NAME=3rd Party Mac Developer Application: Bird Rides, Inc. (P2T4T6R4SL)
TEAM_IDENTIFIER=P2T4T6R4SL
ZIP_FILENAME=MockingbirdCli.zip
CLI_FILENAME=mockingbird

OUTPUT_PACKAGE=MockingbirdCli.pkg
OUTPUT_ZIP=MockingbirdCli.zip

CLI_BUNDLE_PLIST=MockingbirdCli/Info.plist
VERSION_STRING=$(shell /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$(CLI_BUNDLE_PLIST)")

#GITHUB_REPO_URL=https://github.com/birdrides/mockingbird
#ZIP_RELEASE_URL=$(shell $(GITHUB_REPO_URL)/releases/download/$(VERSION_STRING)/$(ZIP_FILENAME))
ZIP_PRERELEASE_URL=https://bird-mockingbird.s3-us-west-1.amazonaws.com/MockingbirdCli.zip
SUCCESS_MSG=Verified the Mockingbird CLI binary
ERROR_MSG=FATAL ERROR: The downloaded Mockingbird CLI binary does not have the expected code signature!

.PHONY: all \
		clean \
		boostrap-carthage \
		build \
		carthage-update \
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

boostrap-carthage:
	(cd Mockingbird.xcodeproj/xcshareddata/xcschemes; \
		find . ! -name "MockingbirdFramework.xcscheme" ! -name "MockingbirdShared.xcscheme" -delete)

build:
	swift build $(SWIFT_BUILD_FLAGS)

download:
	curl -Lo "$(ZIP_FILENAME)" "$(ZIP_PRERELEASE_URL)"
	unzip -o "$(ZIP_FILENAME)" "$(CLI_FILENAME)"
	@codesign -dv "$(CLI_FILENAME)" 2>&1 | grep -q "TeamIdentifier=$(TEAM_IDENTIFIER)" \
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
	(cd "$(TEMPORARY_FOLDER)"; zip -yr - "$(CLI_FILENAME)" "LICENSE") > "$(OUTPUT_ZIP)"	

release: clean package zip
signed-release: clean signed-package signed-zip

get-version:
	@echo $(VERSION_STRING)

get-zip-sha256:
	@echo $(shell shasum --algorithm 256 "$(OUTPUT_ZIP)" | awk '{print $$1}')

%:
	@:
