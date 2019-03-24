import Foundation

public struct TestCountProvider: InfoProvider {

    public static let identifier: String = "test_count"

    public let description: String = "Test Cases Count"
    public let count: Int

    public init(count: Int) {
        self.count = count
    }

    public static func extract() throws -> TestCountProvider {
        guard let testLog = FileUtils().testLog else {
            fail("No test log!")
        }
        let count = testLog.insensitiveMatch(regex: "Test Case '.*' passed").count +
                    testLog.insensitiveMatch(regex: "Test Case '.*' failed").count
        return TestCountProvider(count: count)
    }

    public func summary(comparingWith other: TestCountProvider?) -> String {
        let regularMessage = "Test Count: \(count)"
        guard let other = other else {
            return regularMessage
        }
        if count == other.count {
            return regularMessage
        }
        let difference = abs(other.count - count)
        let modifier = count > other.count ? "*grew*" : "was *reduced*"
        return "Test count \(modifier) by \(difference) (\(count))"
    }
}
