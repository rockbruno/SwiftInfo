import Foundation

public struct TargetCountProvider: InfoProvider {

    public static let identifier: String = "target_count"

    public let description: String = "Dependency Count"
    public let count: Int

    public init(count: Int) {
        self.count = count
    }

    public static func extract(fromApi api: SwiftInfo) throws -> TargetCountProvider {
        let buildLog = api.fileUtils.buildLog
        let modules = Set(buildLog.match(regex: "(?<=-module-name ).*?(?= )"))
        return TargetCountProvider(count: modules.count)
    }

    public func summary(comparingWith other: TargetCountProvider?) -> Summary {
        let prefix = "👶 Dependency Count"
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
