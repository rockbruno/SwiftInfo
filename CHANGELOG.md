<!--

// Please add your own contribution below inside the Current Release section. The version numbers will be updated
// once we deploy a new version.
//
// These docs are aimed for us developers to make things easier to maintain, so don't worry
// about getting too technical here.

-->

## master

## 2.0.2
* Fixed some providers reporting wrong colors for the result - Bruno Rocha

## 2.0.1
* Fixed LongestTest's provider not working with non-legacy workspaces - Bruno Rocha

## 2.0.0
* Added support for arguments - Bruno Rocha
* Updated to Swift 5 - Bruno Rocha
* Improved CodeCoverageProvider and LinesOfCodeProvider - Bruno Rocha

## 1.2.0
* Added LinesOfCodeProvider - Bruno Rocha
* Slightly improved generic summary messages - Bruno Rocha

## 1.1.0
* Linked sourcekitd to allow extraction of code related metrics - Bruno Rocha
* Added OBJCFileCountProvider - Bruno Rocha
* Added LongestTestDurationProvider - Bruno Rocha
* Added TotalTestDurationProvider - Bruno Rocha
* Added LargestAssetCatalogProvider - Bruno Rocha
* Added TotalAssetCatalogsSizeProvider - Bruno Rocha

## 1.0.0
* Added Unit Tests - Bruno Rocha
* InfoProvider's `extract() -> Self` is now `extract(fromApi api: SwiftInfo) -> Self` - Bruno Rocha
* Revamped logs - Bruno Rocha

## 0.1.1
* Fixed dylib search paths by using `--driver-mode=swift` when running `swiftc` - Bruno Rocha

## 0.1.0
(Initial Release)
