import Foundation

/// Sum of all test target's test count.
/// Requirements: Test logs (if building with Xcode) or Buck build log (if building with Buck)
public struct TestCountProvider: InfoProvider {
    public struct Args {
        /// The build system that was used to test the app.
        /// If Xcode was used, SwiftInfo will parse the `testLogFilePath` file,
        /// but if Buck was used, `buckLogFilePath` will be used instead.
        public let buildSystem: BuildSystem

        public init(buildSystem: BuildSystem = .xcode) {
            self.buildSystem = buildSystem
        }
    }

    public typealias Arguments = Args

    public static let identifier: String = "test_count"

    public var description: String { "🎯 Test Count" }
    public let count: Int

    public init(count: Int) {
        self.count = count
    }

    public static func extract(fromApi api: SwiftInfo, args: Args?) throws -> TestCountProvider {
        let count: Int
        if args?.buildSystem == .buck {
            count = try getCountFromBuck(api)
        } else {
            count = try getCountFromXcode(api)
        }
        guard count > 0 else {
            fail("Failing because 0 tests were found, and this is probably not intentional.")
        }
        return TestCountProvider(count: count)
    }

    static func getCountFromXcode(_ api: SwiftInfo) throws -> Int {
        let testLog = try api.fileUtils.testLog()
        return testLog.insensitiveMatch(regex: "Test Case '.*' passed").count +
            testLog.insensitiveMatch(regex: "Test Case '.*' failed").count
    }

    static func getCountFromBuck(_ api: SwiftInfo) throws -> Int {
        let buckLog = try api.fileUtils.buckLog()
        let regexString = "s *([0-9]*) Passed *([0-9]*) Skipped  *([0-9]*) Failed"
        let results = buckLog.matchResults(regex: regexString)
        let passed = results.compactMap { Int($0.captureGroup(1, originalString: buckLog)) }
        let skipped = results.compactMap { Int($0.captureGroup(2, originalString: buckLog)) }
        let failed = results.compactMap { Int($0.captureGroup(3, originalString: buckLog)) }
        return (passed + skipped + failed).reduce(0, +)
    }

    public func summary(comparingWith other: TestCountProvider?, args _: Args?) -> Summary {
        let prefix = description
        return Summary.genericFor(prefix: prefix, now: count, old: other?.count, increaseIsBad: false)
    }
}
