import Foundation

public struct TotalTestDurationProvider: InfoProvider {

    public struct Args {}
    public typealias Arguments = Args

    public static let identifier: String = "total_test_duration"

    public let description: String = "🛏 Time to Build and Run Tests"
    public let durationInt: Int

    public init(durationInt: Int) {
        self.durationInt = durationInt
    }

    public static func extract(fromApi api: SwiftInfo, args: Args?) throws -> TotalTestDurationProvider {
        let testLog = try api.fileUtils.testLog()
        let durationString = testLog.match(regex: #"(?<=\*\* TEST SUCCEEDED \*\* \[).*?(?= sec)"#).first
        guard let duration = Float(durationString ?? "") else {
            throw error("Total test duration (TEST SUCCEEDED) not found in the logs. Did the tests fail?")
        }
        return TotalTestDurationProvider(durationInt: Int(duration * 1000))
    }

    public func summary(comparingWith other: TotalTestDurationProvider?, args: Args?) -> Summary {
        let prefix = description
        let numberFormatter: ((Int) -> Float) = { value in
            return Float(value) / 1000
        }
        let stringFormatter: ((Int) -> String) = { value in
            return "\(numberFormatter(value)) secs"
        }
        return Summary.genericFor(prefix: prefix,
                                  now: durationInt,
                                  old: other?.durationInt,
                                  increaseIsBad: true,
                                  stringValueFormatter: stringFormatter,
                                  numericValueFormatter: numberFormatter) {
            return abs($1 - $0)
        }
    }
}
