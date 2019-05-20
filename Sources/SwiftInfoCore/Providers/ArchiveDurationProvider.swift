import Foundation

public struct ArchiveDurationProvider: InfoProvider {

    public struct Args {}
    public typealias Arguments = Args

    public static let identifier: String = "archive_time"

    public let description: String = "🚚 Time to Build and Archive"
    public let timeInt: Int

    public init(timeInt: Int) {
        self.timeInt = timeInt
    }

    public static func extract(fromApi api: SwiftInfo, args: Args?) throws -> ArchiveDurationProvider {
        let buildLog = try api.fileUtils.buildLog()
        let durationString = buildLog.match(regex: #"(?<=\*\* ARCHIVE SUCCEEDED \*\* \[).*?(?= sec)"#).first
        guard let duration = Float(durationString ?? "") else {
            throw error("Total archive time (ARCHIVE SUCCEEDED) not found in the logs. Did the archive fail?")
        }
        return ArchiveDurationProvider(timeInt: Int(duration * 1000))
    }

    public func summary(comparingWith other: ArchiveDurationProvider?, args: Args?) -> Summary {
        let prefix = description
        let numberFormatter: ((Int) -> Float) = { value in
            return Float(value) / 1000
        }
        let stringFormatter: ((Int) -> String) = { value in
            return "\(numberFormatter(value)) secs"
        }
        return Summary.genericFor(prefix: prefix,
                                  now: timeInt,
                                  old: other?.timeInt,
                                  increaseIsBad: true,
                                  stringValueFormatter: stringFormatter,
                                  numericValueFormatter: numberFormatter) {
            return abs($1 - $0)
        }
    }
}
