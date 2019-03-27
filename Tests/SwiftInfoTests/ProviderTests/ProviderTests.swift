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
                         client: .init())
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
    }

    func testTestCount() {
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
}
