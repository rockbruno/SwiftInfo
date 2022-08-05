import Foundation

/// Number of warnings in a build.
/// Requirements: Build logs.
public struct WarningCountProvider: InfoProvider {
    public struct Args {}
    public typealias Arguments = Args

    public static let identifier: String = "warning_count"

    public var description: String { "⚠️ Warning Count" }
    public let count: Int

    public init(count: Int) {
        self.count = count
    }

    public static func extract(fromApi api: SwiftInfo, args _: Args?) throws -> WarningCountProvider {
        let buildLog = try api.fileUtils.buildLog()
        let results = buildLog.match(regex: "(: warning:.*\n)|((warning:.*\n))")
        let count = Set(results).count
        return WarningCountProvider(count: count)
    }

    public func summary(comparingWith other: WarningCountProvider?, args _: Args?) -> Summary {
        let prefix = description
        return Summary.genericFor(prefix: prefix, now: count, old: other?.count, increaseIsBad: true)
    }
}
