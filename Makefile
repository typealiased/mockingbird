TEMPORARY_FOLDER?=/tmp/Mockingbird.dst
PREFIX?=/usr/local

SWIFT_BUILD_FLAGS=--configuration release

EXECUTABLE_PATH=$(shell swift build $(SWIFT_BUILD_FLAGS) --show-bin-path)/mockingbird

FRAMEWORKS_FOLDER=/Library/Frameworks
BINARIES_FOLDER=/usr/local/bin

OUTPUT_PACKAGE=Mockingbird.pkg

CLI_BUNDLE_PLIST=MockingbirdCli/Info.plist
VERSION_STRING=$(shell /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$(CLI_BUNDLE_PLIST)")

.PHONY: all clean bootstrap build install package uninstall

all: build

clean:
	rm -f "$(OUTPUT_PACKAGE)"
	rm -rf "$(TEMPORARY_FOLDER)"
	swift package clean

bootstrap:
	carthage update --platform mac --cache-builds

build:
	swift build $(SWIFT_BUILD_FLAGS)

install: build
	install -d "$(BINARIES_FOLDER)"
	install "$(EXECUTABLE_PATH)" "$(BINARIES_FOLDER)"

uninstall:
	rm -rf "$(FRAMEWORKS_FOLDER)/Mockingbird.framework"
	rm -f "$(BINARIES_FOLDER)/mockingbird"

installables: build
	install -d "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)"
	install "$(EXECUTABLE_PATH)" "$(TEMPORARY_FOLDER)$(BINARIES_FOLDER)"

package: installables
	pkgbuild \
		--identifier "co.bird.mockingbird" \
		--install-location "/" \
		--root "$(TEMPORARY_FOLDER)" \
		--version "$(VERSION_STRING)" \
		"$(OUTPUT_PACKAGE)"

release: clean package

%:
	@:
