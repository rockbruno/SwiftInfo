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
        return Summary.genericFor(prefix: prefix, now: count, old: other?.count) {
            return abs($1 - $0)
        }
    }
}
