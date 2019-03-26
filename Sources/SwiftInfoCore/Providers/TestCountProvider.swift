import Foundation

public struct TestCountProvider: InfoProvider {

    public static let identifier: String = "test_count"

    public let description: String = "Test Cases Count"
    public let count: Int

    public init(count: Int) {
        self.count = count
    }

    public static func extract(fromApi api: SwiftInfo) throws -> TestCountProvider {
        let testLog = api.fileUtils.testLog
        let count = testLog.insensitiveMatch(regex: "Test Case '.*' passed").count +
                    testLog.insensitiveMatch(regex: "Test Case '.*' failed").count
        return TestCountProvider(count: count)
    }

    public func summary(comparingWith other: TestCountProvider?) -> Summary {
        let prefix = "🎯 Test Count"
        guard let other = other else {
            return Summary(text: prefix + ": \(count)", style: .neutral)
        }
        guard count != other.count else {
            return Summary(text: prefix + ": Unchanged. (\(count))", style: .neutral)
        }
        let modifier: String
        let style: Summary.Style
        if count > other.count {
            modifier = "*grew*"
            style = .positive
        } else {
            modifier = "was *reduced*"
            style = .negative
        }
        let difference = abs(other.count - count)
        let text = prefix + " \(modifier) by \(difference) (\(count))"
        return Summary(text: text, style: style)
    }
}
