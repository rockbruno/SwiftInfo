import XCTest
@testable import SwiftInfoCore

extension SwiftInfo {
    static func mock() -> SwiftInfo {
        let fileManager = MockFileManager()
        let fileOpener = MockFileOpener(mockFM: fileManager)
        let fileUtils = FileUtils(fileManager: fileManager, fileOpener: fileOpener)
        fileManager.add(file: "./Infofile.swift", contents: "")
        let projectInfo = ProjectInfo(xcodeproj: "Mock.xcproject",
                                      target: "Mock",
                                      configuration: "Mock-Debug",
                                      fileUtils: fileUtils,
                                      plistExtractor: MockPlistExtractor())
        let plist = NSDictionary(dictionary: ["CFBundleShortVersionString": "1.0",
                                              "CFBundleVersion": "1"])
        fileManager.add(plist: plist, file: "./Info.plist")
        return SwiftInfo(projectInfo: projectInfo,
                         fileUtils: fileUtils,
                         slackFormatter: .init(),
                         client: .init(),
                         sourceKit: MockSourceKit())
    }

    var mockFileManager: MockFileManager {
        return fileUtils.fileManager as! MockFileManager
    }
}

final class ProviderTests: XCTestCase {

    var api: SwiftInfo!

    override func setUp() {
        super.setUp()
        api = SwiftInfo.mock()
        FileUtils.buildLogFilePath = ""
        FileUtils.testLogFilePath = ""
    }

    func testIPASize() {
        let path = "./build/App.ipa"
        api.mockFileManager.add(file: path, contents: "")
        api.mockFileManager.add(attributes: [.size: UInt64(5000)], file: path)
        let extracted = try! IPASizeProvider.extract(fromApi: api)
        XCTAssertEqual(extracted.size, 5000)
    }

    func testWarningCount() {
        FileUtils.buildLogFilePath = "./build.log"
        let log =
"""
aaaaaaaa
mockmockmock
:global: warning: A warning
:global: warning: Another warning
warning: Also a warning warning: This one is not
     warning: Another one
:global: warning: A warning
      :global: warning: A warning
The above two are not warnings because they are repeated.
"""
        api.mockFileManager.add(file: "build.log", contents: log)
        let extracted = try! WarningCountProvider.extract(fromApi: api)
        XCTAssertEqual(extracted.count, 4)
    }

    func testTargetCount() {
        FileUtils.buildLogFilePath = "./build.log"
        let log =
"""
ahfgvnvnrjrjjffj fjjnf nhfjfjfj nfnfnf -module-name MyMock nbvbfhuff fjjf ahfgvnvnrjrjjffj fjjnf nhfjfjfj nfnfnf -module-name MyMock nbvbfhuff fjjf
ahfgvnvnrjrjjffj fjjnf nhfjfjfj nfnfnf -module-name MyMock2 nbvbfhuff fjjf
-module-name MyMock3 fnbvvb
"""
        api.mockFileManager.add(file: "build.log", contents: log)
        let extracted = try! TargetCountProvider.extract(fromApi: api)
        XCTAssertEqual(extracted.count, 3)
        XCTAssertEqual(
            extracted.summary(comparingWith: TargetCountProvider(count: 2),
                              args: nil).color,
            Summary.Style.negative.hexColor
        )
        XCTAssertEqual(
            extracted.summary(comparingWith: TargetCountProvider(count: 2),
                              args: .init(mode: .complainOnAdditions)).color,
            Summary.Style.negative.hexColor
        )
        XCTAssertEqual(
            extracted.summary(comparingWith: TargetCountProvider(count: 2),
                              args: .init(mode: .complainOnRemovals)).color,
            Summary.Style.positive.hexColor
        )
        XCTAssertEqual(
            extracted.summary(comparingWith: TargetCountProvider(count: 2),
                              args: .init(mode: .neutral)).color,
            Summary.Style.neutral.hexColor
        )
        XCTAssertEqual(
            extracted.summary(comparingWith: TargetCountProvider(count: 3),
                              args: .init(mode: .complainOnAdditions)).color,
            Summary.Style.neutral.hexColor
        )
    }

    func testTestCountXcode() {
        FileUtils.testLogFilePath = "./test.log"
        let log =
"""
aaa
--- Test Case 'a' started ---
--- Test Case 'a' passed ---
--- Test Case 'b' failed ---
--- test case 'c' passed ---
--- Test CASE 'd' passed ---
--- test Case 'e' failed ---
aaa
"""
        api.mockFileManager.add(file: "test.log", contents: log)
        let extracted = try! TestCountProvider.extract(fromApi: api)
        XCTAssertEqual(extracted.count, 5)
    }

    func testTestCountBuck() {
        FileUtils.buckLogFilePath = "./buck.log"
        let log =
        """
PASS    <100ms  4 Passed   0 Skipped   0 Failed   CorporatePaymentChoicesWorkerSpec
PASS    <100ms  3 Passed   0 Skipped   0 Failed   CrossSellingAnalyticSpec
PASS     525ms 12 Passed   0 Skipped   0 Failed   CrossSellingCarouselCellSpec
PASS    <100ms  4 Passed   0 Skipped   0 Failed   CrossSellingItemManagerProtocolSpec
PASS    <100ms  3 Passed   0 Skipped   0 Failed   CrossSellingRemoteConfigSpec
PASS    <100ms  3 Passed   0 Skipped   0 Failed   CrossSellingWokerSpec
PASS    <100ms  3 Passed   0 Skipped   0 Failed   CustomerRequestModelSpec
PASS    <100ms 10 Passed   0 Skipped   0 Failed   CustomizationManagerTests
PASS    <100ms  5 Passed   0 Skipped   0 Failed   DateExtensionsSpec
PASS    <100ms  6 Passed   0 Skipped   0 Failed   DateStrategyFactorySpec
"""
        api.mockFileManager.add(file: "buck.log", contents: log)
        let extracted = try! TestCountProvider.extract(fromApi: api, args: .init(buildSystem: .buck))
        XCTAssertEqual(extracted.count, 53)
    }

    func testObjcCount() {
        FileUtils.buildLogFilePath = "./build.log"
        let log =
        """
CompileC bla SDWebImage/SDWebImage/UIView+WebCacheOperation.m normal armv7
CompileC bla SDWebImage/SDWebImage/UIView+WebCacheOperation.m normal armv7
CompileC bla SDWebImage/SDWebImage/UIView+WebCacheOperation2.m normal armv7
CompileC bla SDWebImage/SDWebImage/UIView+WebCacheOperation3.m normal armv7
CpHeader SDWebImage/a.h normal armv7
CpHeader SDWebImage/a2.h normal armv7
CpHeader SDWebImage/a3.h normal armv7
"""
        api.mockFileManager.add(file: "build.log", contents: log)
        let extracted = try! OBJCFileCountProvider.extract(fromApi: api)
        XCTAssertEqual(extracted.count, 6)
    }

    func testLongestTest() {
        FileUtils.testLogFilePath = "./test.log"
        let log =
        """
Test suite 'DeviceRequestTests' started on 'Clone 1 of iPhone 5s - Rapiddo.app (13627)'
Test case 'DeviceRequestTests.testEventNameFormatter()' passed on 'Clone 1 of iPhone 5s - Rapiddo.app (13627)' (0.001 seconds)
Test suite 'FareEstimateTests' started on 'Clone 1 of iPhone 5s - Rapiddo.app (13627)'
Test case 'FareEstimateTests.testJsonDecoder()' passed on 'Clone 1 of iPhone 5s - Rapiddo.app (13627)' (0.464 seconds)
Test case 'FareEstimateTests.testJsonDecoder()' failed on 'Clone 1 of iPhone 5s - Rapiddo.app (13627)' (1000.464 seconds)
Test Case '-[UnitTests.AccountTagsWorkerTests Account_Tags_Worker__Fetching_tags__Try_to_get_tags_when_user_is_not_logged_in]' passed (0.013 seconds).
Test suite 'CartItemTests' started on 'Clone 1 of iPhone 5s - Rapiddo.app (13627)'
Test case 'CartItemTests.testPriceLogic()' passed on 'Clone 1 of iPhone 5s - Rapiddo.app (13627)' (0.001 seconds)
"""
        api.mockFileManager.add(file: "test.log", contents: log)
        let extracted = try! LongestTestDurationProvider.extract(fromApi: api)
        XCTAssertEqual(extracted.durationInt, 464)
    }

    func testTotalTestDuration() {
        FileUtils.testLogFilePath = "./test.log"
        let log =
        """
Test suite 'DeviceRequestTests' started on 'Clone 1 of iPhone 5s - Rapiddo.app (13627)'
Test case 'DeviceRequestTests.testEventNameFormatter()' passed on 'Clone 1 of iPhone 5s - Rapiddo.app (13627)' (0.001 seconds)
Test suite 'FareEstimateTests' started on 'Clone 1 of iPhone 5s - Rapiddo.app (13627)'
Test case 'FareEstimateTests.testJsonDecoder()' passed on 'Clone 1 of iPhone 5s - Rapiddo.app (13627)' (0.464 seconds)
Test case 'FareEstimateTests.testJsonDecoder()' failed on 'Clone 1 of iPhone 5s - Rapiddo.app (13627)' (1000.464 seconds)
Test Case '-[UnitTests.AccountTagsWorkerTests Account_Tags_Worker__Fetching_tags__Try_to_get_tags_when_user_is_not_logged_in]' passed (0.013 seconds).
Test suite 'CartItemTests' started on 'Clone 1 of iPhone 5s - Rapiddo.app (13627)'
Test case 'CartItemTests.testPriceLogic()' passed on 'Clone 1 of iPhone 5s - Rapiddo.app (13627)' (0.001 seconds)
Generating coverage data...
Generated coverage report: /Users/bruno.rocha/Library/Developer/Xcode/DerivedData/Rapiddo-cbobntbmchyaczezxxpesrevoisy/Logs/Test/Run-Marketplace-2019.03.25_12-55-36--0300.xcresult/2_Test/action.xccovreport
** TEST SUCCEEDED ** [37.368 sec]
"""
        api.mockFileManager.add(file: "test.log", contents: log)
        let extracted = try! TotalTestDurationProvider.extract(fromApi: api)
        XCTAssertEqual(extracted.durationInt, 37368)
    }

    func testArchiveTime() {
        FileUtils.buildLogFilePath = "./build.log"
        let log =
        """
Touch /Users/bruno.rocha/Library/Developer/Xcode/DerivedData/Rapiddo-cbobntbmchyaczezxxpesrevoisy/Build/Intermediates.noindex/ArchiveIntermediates/Marketplace-AppStore/InstallationBuildProductsLocation/Applications/Rapiddo.app (in target: Rapiddo)
    cd /Users/bruno.rocha/Desktop/MovileRepos/rapiddo-vision-ios
    /usr/bin/touch -c /Users/bruno.rocha/Library/Developer/Xcode/DerivedData/Rapiddo-cbobntbmchyaczezxxpesrevoisy/Build/Intermediates.noindex/ArchiveIntermediates/Marketplace-AppStore/InstallationBuildProductsLocation/Applications/Rapiddo.app

** ARCHIVE SUCCEEDED ** [309.407 sec]
"""
        api.mockFileManager.add(file: "build.log", contents: log)
        let extracted = try! ArchiveDurationProvider.extract(fromApi: api)
        XCTAssertEqual(extracted.timeInt, 309407)
    }

    func testCoverageExtraction() {
        var log = """
        Generating coverage data...
        Generated coverage report: /Users/bla/action.xccovreport
        ** TEST SUCCEEDED ** [37.368 sec]
        """
        XCTAssertEqual("/Users/bla/action.xccovreport",
                       CodeCoverageProvider.getCodeCoverageLegacyJsonPath(fromLogs: log))
        log = """
        Test session results, code coverage, and logs:
            /Users/bla/action.xcresult

        ** TEST SUCCEEDED ** [9.756 sec]
        """
        XCTAssertEqual("/Users/bla/action.xcresult",
                       CodeCoverageProvider.getCodeCoverageXcode11JsonPath(fromLogs: log))
    }

    func testAssetCatalogPaths() {
        FileUtils.buildLogFilePath = "./build.log"
        let log =
            """
        CompileAssetCatalog /tmp/sandbox/58b30f5722d5c60100e34a03/ci/Build/Intermediates.noindex/ArchiveIntermediates/rogerluan-env/IntermediateBuildFilesPath/UninstalledProducts/iphoneos/Stripe_Stripe.bundle /tmp/sandbox/58b30f5722d5c60100e34a03/ci/SourcePackages/checkouts/stripe-ios/Stripe/Resources/Images/Stripe.xcassets (in target 'Stripe_Stripe' from project 'Stripe')
        CompileAssetCatalog /tmp/sandbox/58b30f5722d5c60100e34a03/ci/Build/Intermediates.noindex/ArchiveIntermediates/rogerluan-env/IntermediateBuildFilesPath/UninstalledProducts/iphoneos/rogerluan.appex /tmp/sandbox/workspace/rogerluan-sticker-pack/Stickers.xcassets (in target 'rogerluan-sticker-pack' from project 'rogerluans-product')
        CompileAssetCatalog /tmp/sandbox/58b30f5722d5c60100e34a03/ci/Build/Intermediates.noindex/ArchiveIntermediates/rogerluan-env/IntermediateBuildFilesPath/UninstalledProducts/iphoneos/rogerluanCore.framework /tmp/sandbox/workspace/rogerluan-core-ios/rogerluan-core/Colors.xcassets (in target 'rogerluanCore' from project 'Pods')
        CompileAssetCatalog /tmp/sandbox/58b30f5722d5c60100e34a03/ci/Build/Intermediates.noindex/ArchiveIntermediates/rogerluan-env/IntermediateBuildFilesPath/UninstalledProducts/iphoneos/rogerluan-function-widget.appex /tmp/sandbox/workspace/rogerluan-function-widget/Icons.xcassets /tmp/sandbox/workspace/rogerluans-product/Colors.xcassets (in target 'rogerluan-function-widget' from project 'rogerluans-product')
        CompileAssetCatalog /tmp/sandbox/58b30f5722d5c60100e34a03/ci/Build/Intermediates.noindex/ArchiveIntermediates/rogerluan-env/IntermediateBuildFilesPath/UninstalledProducts/iphoneos/rogerluan-share-plugin.appex /tmp/sandbox/workspace/rogerluans-product/Original Icons.xcassets /tmp/sandbox/workspace/rogerluan-share-plugin/Assets.xcassets /tmp/sandbox/workspace/rogerluans-product/Icons.xcassets /tmp/sandbox/workspace/rogerluans-product/SharedIcons.xcassets /tmp/sandbox/workspace/rogerluans-product/Colors.xcassets /tmp/sandbox/workspace/rogerluans-product/SharedImages.xcassets (in target 'rogerluan-share-plugin' from project 'rogerluans-product')
        CompileAssetCatalog /tmp/sandbox/58b30f5722d5c60100e34a03/ci/Build/Intermediates.noindex/ArchiveIntermediates/rogerluan-env/InstallationBuildProductsLocation/Applications/rogerluan.app /tmp/sandbox/workspace/rogerluans-product/AppIcon.xcassets /tmp/sandbox/workspace/rogerluans-product/Original Icons.xcassets /tmp/sandbox/workspace/rogerluans-product/Images.xcassets /tmp/sandbox/workspace/rogerluans-product/SharedImages.xcassets /tmp/sandbox/workspace/rogerluans-product/Icons.xcassets /tmp/sandbox/workspace/rogerluans-product/SharedIcons.xcassets /tmp/sandbox/workspace/rogerluans-product/Colors.xcassets (in target 'rogerluans-product' from project 'rogerluans-product')
        """
        api.mockFileManager.add(file: "build.log", contents: log)
        let paths = try! TotalAssetCatalogsSizeProvider.allCatalogsPaths(api: api)
        XCTAssertEqual(paths.count, 12)
    }
}
