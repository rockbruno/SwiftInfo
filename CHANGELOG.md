<!--

// Please add your own contribution below inside the `master` section. The version numbers will be updated
// once we deploy a new version.
//
// These docs are aimed for us developers to make things easier to maintain, so don't worry
// about getting too technical here.

-->

## master

## 2.3.2
* ProjectInfo now allows you to manually specify a `versionNumber` and `buildNumber` in case your Info.plist doesn't have them (Buck iOS apps) - Bruno Rocha

## 2.3.1
* Adding support to danger-SwiftInfo - Bruno Rocha
* Making some failure messages better - Bruno Rocha

## 2.3.0
* Added support for installation via Homebrew. - [Cihat Gündüz](https://github.com/Dschee) (Issue [#17](https://github.com/rockbruno/SwiftInfo/issues/17), PR [#20](https://github.com/rockbruno/SwiftInfo/pull/20))

## 2.2.0
* Added LargestAssetProvider - [Bruno Rocha](https://github.com/rockbruno)
* Changed how SwiftInfo generates summary results to allow custom providers to make use of SwiftInfo-Reader - [Bruno Rocha](https://github.com/rockbruno)
* Small visual improvements to summaries - [Bruno Rocha](https://github.com/rockbruno)

## 2.1.0
* Added ArchiveTimeProvider - [Bruno Rocha](https://github.com/rockbruno)
* SwiftInfo will now continue executing even if a provider fails (the reasons are printed in the final summary) - [Bruno Rocha](https://github.com/rockbruno)
* Improvements to the durability of many providers and fixing minor bugs related to them - [Bruno Rocha](https://github.com/rockbruno)
* Fixed many providers silently failing if Xcode's new build system was active - [Bruno Rocha](https://github.com/rockbruno)
* Fixed many providers reporting empty results when they should have failed - [Bruno Rocha](https://github.com/rockbruno)

## 2.0.2
* Fixed some providers reporting wrong colors for the result - [Bruno Rocha](https://github.com/rockbruno)

## 2.0.1
* Fixed LongestTest's provider not working with non-legacy workspaces - [Bruno Rocha](https://github.com/rockbruno)

## 2.0.0
* Added support for arguments - [Bruno Rocha](https://github.com/rockbruno)
* Updated to Swift 5 - [Bruno Rocha](https://github.com/rockbruno)
* Improved CodeCoverageProvider and LinesOfCodeProvider - [Bruno Rocha](https://github.com/rockbruno)

## 1.2.0
* Added LinesOfCodeProvider - [Bruno Rocha](https://github.com/rockbruno)
* Slightly improved generic summary messages - [Bruno Rocha](https://github.com/rockbruno)

## 1.1.0
* Linked sourcekitd to allow extraction of code related metrics - [Bruno Rocha](https://github.com/rockbruno)
* Added OBJCFileCountProvider - [Bruno Rocha](https://github.com/rockbruno)
* Added LongestTestDurationProvider - [Bruno Rocha](https://github.com/rockbruno)
* Added TotalTestDurationProvider - [Bruno Rocha](https://github.com/rockbruno)
* Added LargestAssetCatalogProvider - [Bruno Rocha](https://github.com/rockbruno)
* Added TotalAssetCatalogsSizeProvider - [Bruno Rocha](https://github.com/rockbruno)

## 1.0.0
* Added Unit Tests - [Bruno Rocha](https://github.com/rockbruno)
* InfoProvider's `extract() -> Self` is now `extract(fromApi api: SwiftInfo) -> Self` - [Bruno Rocha](https://github.com/rockbruno)
* Revamped logs - [Bruno Rocha](https://github.com/rockbruno)

## 0.1.1
* Fixed dylib search paths by using `--driver-mode=swift` when running `swiftc` - [Bruno Rocha](https://github.com/rockbruno)

## 0.1.0
(Initial Release)
