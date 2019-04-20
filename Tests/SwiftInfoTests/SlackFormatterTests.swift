import XCTest
@testable import SwiftInfoCore

final class SlackFormatterTests: XCTestCase {
    func testFormatter() {
        let swiftInfo = SwiftInfo.mock()
        let summaries = [Summary(text: "A", style: .positive)]
        let output = Output(rawDictionary: [:], summaries: summaries, errors: [])
        let formatted = SlackFormatter().format(output: output, projectInfo: swiftInfo.projectInfo)
        let dictionary = NSDictionary(dictionary: formatted)
        let expected: [String: Any] =
            [
                "attachments": [["color": "#36a64f","text": "A"]],
                "text": "SwiftInfo results for Mock 1.0 (1) - Mock-Debug:"
        ]
        XCTAssertEqual(dictionary, NSDictionary(dictionary: expected))
    }

    func testFormatterWithError() {
        let swiftInfo = SwiftInfo.mock()
        let summaries = [Summary(text: "A", style: .positive)]
        let output = Output(rawDictionary: [:], summaries: summaries, errors: ["abc", "cde"])
        let formatted = SlackFormatter().format(output: output, projectInfo: swiftInfo.projectInfo)
        let dictionary = NSDictionary(dictionary: formatted)
        let expected: [String: Any] =
            [
             "attachments": [["color": "#36a64f","text": "A"]],
             "text": "SwiftInfo results for Mock 1.0 (1) - Mock-Debug:\nErrors:\nabc\ncde"
            ]
        XCTAssertEqual(dictionary, NSDictionary(dictionary: expected))
    }
}
