import Foundation

public struct TestCountProvider: InfoProvider {

    public struct Args {}
    public typealias Arguments = Args

    public static let identifier: String = "test_count"

    public let description: String = "🎯 Test Count"
    public let count: Int

    public init(count: Int) {
        self.count = count
    }

    public static func extract(fromApi api: SwiftInfo, args: Args?) throws -> TestCountProvider {
        let testLog = try api.fileUtils.testLog()
        let count = testLog.insensitiveMatch(regex: "Test Case '.*' passed").count +
                    testLog.insensitiveMatch(regex: "Test Case '.*' failed").count
        guard count > 0 else {
            fail("Failing because 0 tests were found, and this is probably not intentional.")
        }
        return TestCountProvider(count: count)
    }

    public func summary(comparingWith other: TestCountProvider?, args: Args?) -> Summary {
        let prefix = description
        return Summary.genericFor(prefix: prefix, now: count, old: other?.count, increaseIsBad: false) {
            return abs($1 - $0)
        }
    }
}
