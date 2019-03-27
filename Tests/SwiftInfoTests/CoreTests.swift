import XCTest
@testable import SwiftInfoCore

final class CoreTests: XCTestCase {
    func testSwiftCArgs() {
        let api = SwiftInfo.mock()
        let exampleRun = ["swiftinfo", "-v", "-s"]
        let args = Runner.getCoreSwiftCArguments(fileUtils: api.fileUtils,
                                                 processInfoArgs: exampleRun)
        let executionPath = ProcessInfo.processInfo.arguments.first!
        let toolFolder = URL(string: executionPath)!.deletingLastPathComponent().absoluteString
        XCTAssertEqual(args, ["swiftc", "--driver-mode=swift", "-L", toolFolder, "-I", toolFolder, "-lSwiftInfoCore", "./Infofile.swift", "-v", "-s"])
    }

    func testFullRun() {
        let api = SwiftInfo.mock()
        let outputPath = "SwiftInfo-output/SwiftInfoOutput.json"
        XCTAssertNil(api.mockFileManager.stringContents(atPath: outputPath))
        var currentOutput = [String: Any]()
        currentOutput["data"] = [
            [
                "swiftinfo_run_description_key": "Mock 1.0 (1) - Mock-Debug",
                "mock_provider": [
                    "data": [
                        "value": 5,
                        "description": "Fake provider for testing purposes"
                    ],
                    "summary": [
                        "text": "-",
                        "color": "#757575"
                    ]
                ]
            ]
        ]
        let currentOutputData = try! JSONSerialization.data(withJSONObject: currentOutput,
                                                            options: [])
        let currentOutputString = String(data: currentOutputData, encoding: .utf8)!
        api.mockFileManager.add(file: outputPath, contents: currentOutputString)
        XCTAssertEqual(api.mockFileManager.stringContents(atPath: outputPath),
                       currentOutputString)
        let output = api.extract(MockInfoProvider.self)
        api.save(output: output)
        var expectedOutput = currentOutput
        let dataArray = expectedOutput["data"] as! [[String: Any]]
        let newDataArray: [[String: Any]] = [[
            "swiftinfo_run_description_key": "Mock 1.0 (1) - Mock-Debug",
            "mock_provider": [
                "data": [
                    "value": 10,
                    "description": "Fake provider for testing purposes"
                ],
                "summary": [
                    "text": "Old: 5, New: 10",
                    "color": "#757575"
                ]
            ]
        ]] + dataArray
        expectedOutput["data"] = newDataArray
        let newOutputData = api.mockFileManager.dataContents(atPath: outputPath)!
        let newOutput = try! JSONSerialization.jsonObject(with: newOutputData, options: []) as! [String: Any]
        XCTAssertEqual(NSDictionary(dictionary: expectedOutput),
                       NSDictionary(dictionary: newOutput))
    }

    func testFullRunWithEmptyOutput() {
        let api = SwiftInfo.mock()
        let outputPath = "SwiftInfo-output/SwiftInfoOutput.json"
        XCTAssertNil(api.mockFileManager.stringContents(atPath: outputPath))
        let output = api.extract(MockInfoProvider.self)
        api.save(output: output)
        let expectedOutput: [String: Any] = [
            "data": [[
            "swiftinfo_run_description_key": "Mock 1.0 (1) - Mock-Debug",
            "mock_provider": [
                "data": [
                    "value": 10,
                    "description": "Fake provider for testing purposes"
                ],
                "summary": [
                    "text": "10",
                    "color": "#757575"
                ]
            ]
            ]]
        ]
        let newOutputData = api.mockFileManager.dataContents(atPath: outputPath)!
        let newOutput = try! JSONSerialization.jsonObject(with: newOutputData, options: []) as! [String: Any]
        XCTAssertEqual(NSDictionary(dictionary: expectedOutput),
                       NSDictionary(dictionary: newOutput))
    }
}

struct MockInfoProvider: InfoProvider {

    static let identifier: String = "mock_provider"
    let description: String = "Fake provider for testing purposes"
    let value: Int

    static func extract(fromApi api: SwiftInfo) throws -> MockInfoProvider {
        return MockInfoProvider(value: 10)
    }

    func summary(comparingWith other: MockInfoProvider?) -> Summary {
        guard let other = other else {
            return Summary(text: "\(value)", style: .neutral)
        }
        return Summary(text: "Old: \(other.value), New: \(value)", style: .neutral)
    }
}
