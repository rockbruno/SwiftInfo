import Foundation

/// Time it took to build and run all tests.
/// Requirements: Test logs.
public struct TotalTestDurationProvider: InfoProvider {
    public struct Args {}
    public typealias Arguments = Args

    public static let identifier: String = "total_test_duration"

    public var description: String { "🛏 Time to Build and Run Tests" }
    public let durationInt: Int

    public init(durationInt: Int) {
        self.durationInt = durationInt
    }

    public static func extract(fromApi api: SwiftInfo, args _: Args?) throws -> TotalTestDurationProvider {
        let testLog = try api.fileUtils.testLog()
        let durationString = testLog.match(regex: #"(?<=\*\* TEST SUCCEEDED \*\* \[).*?(?= sec)"#).first
        guard let duration = Float(durationString ?? "") else {
            throw error("Total test duration (TEST SUCCEEDED) not found in the logs. Did the tests fail?")
        }
        return TotalTestDurationProvider(durationInt: Int(duration * 1000))
    }

    public func summary(comparingWith other: TotalTestDurationProvider?, args _: Args?) -> Summary {
        let prefix = description
        let numberFormatter: ((Int) -> Float) = { value in
            Float(value) / 1000
        }
        let stringFormatter: ((Int) -> String) = { value in
            "\(numberFormatter(value)) secs"
        }
        return Summary.genericFor(prefix: prefix,
                                  now: durationInt,
                                  old: other?.durationInt,
                                  increaseIsBad: true,
                                  stringValueFormatter: stringFormatter,
                                  numericValueFormatter: numberFormatter)
    }
}
