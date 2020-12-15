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
        fileUtils = FileUtils(fileManager: fileManager, fileOpener: fileOpener, path: "")
    }

    func testInfofileFinder() {
        XCTAssertNil(try? fileUtils.infofileFolder())
        fileManager.add(file: "../../Infofile.swift", contents: "")
        XCTAssertNotNil(try? fileUtils.infofileFolder())
        XCTAssertEqual(try! fileUtils.infofileFolder(), "../../")
    }

    func testBuildLogs() {
        fileManager.add(file: "./Infofile.swift", contents: "")
        let logPath = "builds/build.log"
        let contents = "MY LOG"
        XCTAssertNil((try? fileUtils.buildLog()))
        fileManager.add(file: logPath, contents: contents)
        XCTAssertNil((try? fileUtils.buildLog()))
        FileUtils.buildLogFilePath = logPath
        XCTAssertEqual((try? fileUtils.buildLog()), contents)
    }

    func testTestLogs() {
        fileManager.add(file: "./Infofile.swift", contents: "")
        let logPath = "builds/test.log"
        let contents = "MY TEST LOG"
        XCTAssertNil((try? fileUtils.testLog()))
        fileManager.add(file: logPath, contents: contents)
        XCTAssertNil((try? fileUtils.testLog()))
        FileUtils.testLogFilePath = logPath
        XCTAssertEqual((try? fileUtils.testLog()), contents)
    }

    func testLastOutput() {
        fileManager.add(file: "../../Infofile.swift", contents: "")
        XCTAssertEqual(try? fileUtils.outputFileFolder(), "../../SwiftInfo-output/")
        XCTAssertEqual(try? fileUtils.outputFileURL().relativePath, "../../SwiftInfo-output/SwiftInfoOutput.json")
        fileManager.add(file: "../../SwiftInfo-output/SwiftInfoOutput.json", contents: "{\"data\":[{\"a\": \"b\"}]}")
        let last = try? fileUtils.lastOutput()
        XCTAssertEqual((last?.rawDictionary["a"] as? String), "b")
    }

    func testSaveOutput() {
        fileManager.add(file: "../../Infofile.swift", contents: "")
        XCTAssertEqual(fileManager.createdDicts, [])
        let dict: [[String: Any]] = [["b": "c"]]
        try! fileUtils.save(output: dict)
        XCTAssertEqual(fileManager.createdDicts.contains(try! fileUtils.outputFileFolder()), true)
        let last = try! fileUtils.lastOutput()
        XCTAssertEqual((last.rawDictionary["b"] as? String), "c")
        XCTAssertNotNil(try! fileUtils.fullOutput()["data"])
    }
}
