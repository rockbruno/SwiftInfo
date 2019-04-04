import Foundation

public struct WarningCountProvider: InfoProvider {

    public static let identifier: String = "warning_count"

    public let description: String = "Warning Count"
    public let count: Int

    public init(count: Int) {
        self.count = count
    }

    public static func extract(fromApi api: SwiftInfo) throws -> WarningCountProvider {
        let buildLog = api.fileUtils.buildLog
        let results = buildLog.match(regex: "(: warning:.*\n)|((warning:.*\n))")
        let count = Set(results).count
        return WarningCountProvider(count: count)
    }

    public func summary(comparingWith other: WarningCountProvider?) -> Summary {
        let prefix = "⚠️ Warning Count"
        return Summary.genericFor(prefix: prefix, now: count, old: other?.count) {
            return abs($1 - $0)
        }
    }
}
