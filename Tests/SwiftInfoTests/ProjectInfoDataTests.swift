import XCTest
@testable import SwiftInfoCore

final class ProjectInfoDataTests: XCTestCase {
    func testVersionComesFromPlist() {
        let fileManager = MockFileManager()
        let fileOpener = MockFileOpener(mockFM: fileManager)
        let fileUtils = FileUtils(fileManager: fileManager, fileOpener: fileOpener)
        fileManager.add(file: "./Infofile.swift", contents: "")
        let projectInfo = ProjectInfo(xcodeproj: "Mock.xcproject",
                                      target: "Mock",
                                      configuration: "Mock-Debug",
                                      fileUtils: fileUtils,
                                      plistExtractor: MockPlistExtractor())
        let plist = NSDictionary(dictionary: ["CFBundleShortVersionString": "1.11",
                                              "CFBundleVersion": "123"])
        fileManager.add(plist: plist, file: "./Info.plist")
        XCTAssertEqual(try? projectInfo.getVersionString(), "1.11")
        XCTAssertEqual(try? projectInfo.getBuildNumber(), "123")
    }

    func testVersionWasManuallyProvided() {
        let fileManager = MockFileManager()
        let fileOpener = MockFileOpener(mockFM: fileManager)
        let fileUtils = FileUtils(fileManager: fileManager, fileOpener: fileOpener)
        fileManager.add(file: "./Infofile.swift", contents: "")
        let projectInfo = ProjectInfo(xcodeproj: "Mock.xcproject",
                                      target: "Mock",
                                      configuration: "Mock-Debug",
                                      versionString: "2.3",
                                      buildNumber: "90",
                                      fileUtils: fileUtils,
                                      plistExtractor: MockPlistExtractor())
        let plist = NSDictionary(dictionary: ["CFBundleShortVersionString": "1.11",
                                              "CFBundleVersion": "123"])
        fileManager.add(plist: plist, file: "./Info.plist")
        XCTAssertEqual(try? projectInfo.getVersionString(), "2.3")
        XCTAssertEqual(try? projectInfo.getBuildNumber(), "90")
    }
}
