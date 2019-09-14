# Codesigning
Both the zipped binary and installer should be code signed with a Bird Rides, Inc. (P2T4T6R4SL) certificate.

The explicit [designated requirement](https://developer.apple.com/library/archive/technotes/tn2206/_index.html#//apple_ref/doc/uid/DTS40007919-CH1-TNTAG4) 
for verifying the zipped CLI binary is stored under `Codesigning/MockingbirdCli.dr`. This file should rarely change, and commits should be signed with a verified signature from a known contributor.

## Zipped Binary
If you use a dependency manager such as CocoaPods, Carthage, or Swift Package Manager, you will probably
run `make install-prebuilt` to install the CLI. This automatically downloads and verifies the CLI binary using 
the designated requirement file prior to installation.

For CocoaPods, `make install-prebuilt` is run whenever updating the framework with `pod install`.

If the command throws an error when verifying the CLI binary, you should 
[create an issue](https://github.com/birdrides/mockingbird/issues/new) and use the packaged installer instead.

## Installer
If you manually install the CLI using the packaged installer `MockingbirdCli.pkg`, you should verify that the 
installer was signed by Bird Rides, Inc. by clicking the lock icon in the upper-right corner. 

![CLI installer certificate](/Documentation/Assets/signed-cli-installer.png)
