import Foundation

/// Time it took to build and archive the app.
/// Requirements: Build logs of a successful xcodebuild archive.
/// You must also have Xcode's ShowBuildOperationDuration enabled.
/// (run in the Terminal: `defaults write com.apple.dt.Xcode ShowBuildOperationDuration YES` to enable it)
public struct ArchiveDurationProvider: InfoProvider {
    public struct Args {}
    public typealias Arguments = Args

    public static let identifier: String = "archive_time"

    public var description: String { "🚚 Time to Build and Archive" }
    public let timeInt: Int

    public init(timeInt: Int) {
        self.timeInt = timeInt
    }

    public static func extract(fromApi api: SwiftInfo, args _: Args?) throws -> ArchiveDurationProvider {
        let buildLog = try api.fileUtils.buildLog()
        let durationString = buildLog.match(regex: #"(?<=\*\* ARCHIVE SUCCEEDED \*\* \[).*?(?= sec)"#).first
        guard let duration = Float(durationString ?? "") else {
            throw error("Total archive time (ARCHIVE SUCCEEDED) not found in the logs. Did the archive fail?")
        }
        return ArchiveDurationProvider(timeInt: Int(duration * 1000))
    }

    public func summary(comparingWith other: ArchiveDurationProvider?, args _: Args?) -> Summary {
        let prefix = description
        let numberFormatter: ((Int) -> Float) = { value in
            Float(value) / 1000
        }
        let stringFormatter: ((Int) -> String) = { value in
            "\(numberFormatter(value)) secs"
        }
        return Summary.genericFor(prefix: prefix,
                                  now: timeInt,
                                  old: other?.timeInt,
                                  increaseIsBad: true,
                                  stringValueFormatter: stringFormatter,
                                  numericValueFormatter: numberFormatter)
    }
}
