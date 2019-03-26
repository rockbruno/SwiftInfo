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
        let results = buildLog.match(regex: "\n.*warning:.*\n")
        let count = Set(results).count
        return WarningCountProvider(count: count)
    }

    public func summary(comparingWith other: WarningCountProvider?) -> Summary {
        let prefix = "⚠️ Warning count"
        guard let other = other else {
            return Summary(text: prefix + ": \(count)", style: .neutral)
        }
        guard count != other.count else {
            return Summary(text: prefix + ": Unchanged. (\(count))", style: .neutral)
        }
        let modifier: String
        let style: Summary.Style
        if count > other.count {
            modifier = "*grew*"
            style = .negative
        } else {
            modifier = "was *reduced*"
            style = .positive
        }
        let difference = abs(other.count - count)
        let text = prefix + " \(modifier) by \(difference) (\(count))"
        return Summary(text: text, style: style)
    }
}
