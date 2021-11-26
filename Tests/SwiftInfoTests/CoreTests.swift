import XCTest
@testable import SwiftInfoCore

final class CoreTests: XCTestCase {
    func testFullRun() {
        let api = SwiftInfo.mock()
        let outputPath = "SwiftInfo-output/SwiftInfoOutput.json"
        XCTAssertNil(api.mockFileManager.stringContents(atPath: outputPath))
        var currentOutput = [String: Any]()
        currentOutput["data"] = [
            [
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
        api.save(output: output, timestamp: 0)
        var expectedOutput = currentOutput
        let dataArray = expectedOutput["data"] as! [[String: Any]]
        let newDataArray: [[String: Any]] = [[
            "swiftinfo_run_project_info": [
                "buildNumber": "1",
                "configuration": "Mock-Debug",
                "description": "Mock 1.0 (1) - Mock-Debug",
                "target": "Mock",
                "versionString": "1.0",
                "xcodeproj": "Mock.xcproject",
                "timestamp": 0
            ],
            "mock_provider": [
                "data": [
                    "value": 10,
                    "description": "Fake provider for testing purposes"
                ],
                "summary": [
                    "text": "Old: 5, New: 10",
                    "color": "#757575",
                    "numericValue": 0,
                    "stringValue": "a"
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
        api.save(output: output, timestamp: 0)
        let expectedOutput: [String: Any] = [
            "data": [[
            "swiftinfo_run_project_info": [
                "buildNumber": "1",
                "configuration": "Mock-Debug",
                "description": "Mock 1.0 (1) - Mock-Debug",
                "target": "Mock",
                "versionString": "1.0",
                "xcodeproj": "Mock.xcproject",
                "timestamp": 0
            ],
            "mock_provider": [
                "data": [
                    "value": 10,
                    "description": "Fake provider for testing purposes"
                ],
                "summary": [
                    "text": "10",
                    "color": "#757575",
                    "numericValue": 0,
                    "stringValue": "a"
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

    public struct Args {}
    public typealias Arguments = Args

    static let identifier: String = "mock_provider"
    var description: String { "Fake provider for testing purposes" }
    let value: Int

    static func extract(fromApi api: SwiftInfo, args: Args?) throws -> MockInfoProvider {
        return MockInfoProvider(value: 10)
    }

    func summary(comparingWith other: MockInfoProvider?, args: Args?) -> Summary {
        guard let other = other else {
            return Summary(text: "\(value)", style: .neutral, numericValue: 0, stringValue: "a")
        }
        return Summary(text: "Old: \(other.value), New: \(value)", style: .neutral, numericValue: 0, stringValue: "a")
    }
}
