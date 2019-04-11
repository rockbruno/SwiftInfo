import Foundation

public struct TotalTestDurationProvider: InfoProvider {

    public struct Args {}
    public typealias Arguments = Args

    public static let identifier: String = "total_test_duration"

    public let description: String = "Total Test Duration"
    public let durationInt: Int

    public init(durationInt: Int) {
        self.durationInt = durationInt
    }

    public static func extract(fromApi api: SwiftInfo, args: Args?) throws -> TotalTestDurationProvider {
        let testLog = api.fileUtils.testLog
        let durationString = testLog.match(regex: "(?<=\\*\\* TEST SUCCEEDED \\*\\* \\[).*?(?= sec)").first
        guard let duration = Float(durationString ?? "") else {
            fail("Total test duration not found in logs.")
        }
        return TotalTestDurationProvider(durationInt: Int(duration * 1000))
    }

    public func summary(comparingWith other: TotalTestDurationProvider?, args: Args?) -> Summary {
        let prefix = "🛏 Total Test Duration"
        let formatter: ((Int) -> String) = { value in
            return "\(Float(value) / 1000) secs"
        }
        return Summary.genericFor(prefix: prefix, now: durationInt, old: other?.durationInt, formatter: formatter) {
            return abs($1 - $0)
        }
    }
}
