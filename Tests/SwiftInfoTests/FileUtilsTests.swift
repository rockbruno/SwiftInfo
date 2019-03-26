import XCTest
@testable import SwiftInfoCore

final class FileUtilsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        FileUtils.buildLogFilePath = ""
        FileUtils.testLogFilePath = ""
    }

    func testInfofileFinder() {
        let fm = MockFileManager()
        let fileUtils = FileUtils(fileManager: fm)
        XCTAssert(fileUtils._getInfofileFolder() == nil)
        fm.add(file: "../../Infofile.swift", contents: "")
        XCTAssert(fileUtils._getInfofileFolder() != nil)
        XCTAssert(fileUtils.infofileFolder == "../../")
    }

    func testBuildLogs() {
        let fm = MockFileManager()
        let fileOpener = MockFileOpener(mockFM: fm)
        let fileUtils = FileUtils(fileManager: fm, fileOpener: fileOpener)
        fm.add(file: "./Infofile.swift", contents: "")
        let logPath = "builds/build.log"
        let contents = "MY LOG"
        XCTAssert((try? fileUtils._getBuildLog()) == nil)
        fm.add(file: logPath, contents: contents)
        XCTAssert((try? fileUtils._getBuildLog()) == nil)
        FileUtils.buildLogFilePath = logPath
        XCTAssert((try? fileUtils._getBuildLog()) == contents)
    }

    func testTestLogs() {
        let fm = MockFileManager()
        let fileOpener = MockFileOpener(mockFM: fm)
        let fileUtils = FileUtils(fileManager: fm, fileOpener: fileOpener)
        fm.add(file: "./Infofile.swift", contents: "")
        let logPath = "builds/test.log"
        let contents = "MY TEST LOG"
        XCTAssert((try? fileUtils._getTestLog()) == nil)
        fm.add(file: logPath, contents: contents)
        XCTAssert((try? fileUtils._getTestLog()) == nil)
        FileUtils.testLogFilePath = logPath
        XCTAssert((try? fileUtils._getTestLog()) == contents)
    }

    func testLastOutput() {
        let fm = MockFileManager()
        let fileOpener = MockFileOpener(mockFM: fm)
        let fileUtils = FileUtils(fileManager: fm, fileOpener: fileOpener)
        fm.add(file: "../../Infofile.swift", contents: "")
        XCTAssert(fileUtils.outputFileFolder == "../../SwiftInfo-output/")
        XCTAssert(fileUtils.outputFileURL.relativePath == "../../SwiftInfo-output/SwiftInfoOutput.json")
        fm.add(file: "../../SwiftInfo-output/SwiftInfoOutput.json", contents: "{\"data\":[{\"a\": \"b\"}]}")
        let last = fileUtils.lastOutput
        XCTAssert((last.rawDictionary["a"] as? String) == "b")
    }

    func testSaveOutput() {
        let fm = MockFileManager()
        let fileOpener = MockFileOpener(mockFM: fm)
        let fileUtils = FileUtils(fileManager: fm, fileOpener: fileOpener)
        fm.add(file: "../../Infofile.swift", contents: "")
        XCTAssert(fm.createdDicts == [])
        let dict: [[String: Any]] = [["b": "c"]]
        try! fileUtils.save(output: dict)
        XCTAssert(fm.createdDicts.contains(fileUtils.outputFileFolder))
        let last = fileUtils.lastOutput
        XCTAssert((last.rawDictionary["b"] as? String) == "c")
        XCTAssert(fileUtils.fullOutput["data"] != nil)
    }
}
