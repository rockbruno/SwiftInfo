import Foundation

/// Number of targets in the build.
/// Requirements: Build logs.
public struct TargetCountProvider: InfoProvider {
    public struct Args {
        public enum Mode {
            case complainOnAdditions
            case complainOnRemovals
            case neutral
        }

        /// Determines how the summary message should treat target count changes.
        /// If no args are provided, .complainOnAdditions will be used.
        public let mode: Mode

        public init(mode: Mode) {
            self.mode = mode
        }
    }

    public typealias Arguments = Args

    public static let identifier: String = "target_count"

    public var description: String { "👶 Dependency Count" }
    public let count: Int

    public init(count: Int) {
        self.count = count
    }

    public static func extract(fromApi api: SwiftInfo, args _: Args?) throws -> TargetCountProvider {
        let buildLog = try api.fileUtils.buildLog()
        let modules = Set(buildLog.match(regex: "(?<=-module-name ).*?(?= )"))
        return TargetCountProvider(count: modules.count)
    }

    public func summary(comparingWith other: TargetCountProvider?, args: Args?) -> Summary {
        let prefix = description
        let summary = Summary.genericFor(prefix: prefix, now: count, old: other?.count, increaseIsBad: false)
        guard let old = other?.count, old != count else {
            return summary
        }
        let mode = args?.mode ?? .complainOnAdditions
        switch mode {
        case .complainOnRemovals:
            return summary
        case .neutral:
            return Summary(text: summary.text,
                           style: .neutral,
                           numericValue: summary.numericValue,
                           stringValue: summary.stringValue)
        case .complainOnAdditions:
            let style: Summary.Style = count > old ? .negative : .positive
            return Summary(text: summary.text,
                           style: style,
                           numericValue: summary.numericValue,
                           stringValue: summary.stringValue)
        }
    }
}
