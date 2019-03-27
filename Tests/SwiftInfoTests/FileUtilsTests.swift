import XCTest
@testable import SwiftInfoCore

final class FileUtilsTests: XCTestCase {

    var fileManager: MockFileManager!
    var fileOpener: MockFileOpener!
    var fileUtils: FileUtils!

    override func setUp() {
        super.setUp()
        FileUtils.buildLogFilePath = ""
        FileUtils.testLogFilePath = ""
        fileManager = MockFileManager()
        fileOpener = MockFileOpener(mockFM: fileManager)
        fileUtils = FileUtils(fileManager: fileManager, fileOpener: fileOpener)
    }

    func testInfofileFinder() {
        XCTAssertNil(fileUtils._getInfofileFolder())
        fileManager.add(file: "../../Infofile.swift", contents: "")
        XCTAssertNotNil(fileUtils._getInfofileFolder())
        XCTAssertEqual(fileUtils.infofileFolder, "../../")
    }

    func testBuildLogs() {
        fileManager.add(file: "./Infofile.swift", contents: "")
        let logPath = "builds/build.log"
        let contents = "MY LOG"
        XCTAssertNil((try? fileUtils._getBuildLog()))
        fileManager.add(file: logPath, contents: contents)
        XCTAssertNil((try? fileUtils._getBuildLog()))
        FileUtils.buildLogFilePath = logPath
        XCTAssertEqual((try? fileUtils._getBuildLog()), contents)
    }

    func testTestLogs() {
        fileManager.add(file: "./Infofile.swift", contents: "")
        let logPath = "builds/test.log"
        let contents = "MY TEST LOG"
        XCTAssertNil((try? fileUtils._getTestLog()))
        fileManager.add(file: logPath, contents: contents)
        XCTAssertNil((try? fileUtils._getTestLog()))
        FileUtils.testLogFilePath = logPath
        XCTAssertEqual((try? fileUtils._getTestLog()), contents)
    }

    func testLastOutput() {
        fileManager.add(file: "../../Infofile.swift", contents: "")
        XCTAssertEqual(fileUtils.outputFileFolder, "../../SwiftInfo-output/")
        XCTAssertEqual(fileUtils.outputFileURL.relativePath, "../../SwiftInfo-output/SwiftInfoOutput.json")
        fileManager.add(file: "../../SwiftInfo-output/SwiftInfoOutput.json", contents: "{\"data\":[{\"a\": \"b\"}]}")
        let last = fileUtils.lastOutput
        XCTAssertEqual((last.rawDictionary["a"] as? String), "b")
    }

    func testSaveOutput() {
        fileManager.add(file: "../../Infofile.swift", contents: "")
        XCTAssertEqual(fileManager.createdDicts, [])
        let dict: [[String: Any]] = [["b": "c"]]
        try! fileUtils.save(output: dict)
        XCTAssertEqual(fileManager.createdDicts.contains(fileUtils.outputFileFolder), true)
        let last = fileUtils.lastOutput
        XCTAssertEqual((last.rawDictionary["b"] as? String), "c")
        XCTAssertNotNil(fileUtils.fullOutput["data"])
    }
}
