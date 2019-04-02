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
        return Summary.genericFor(prefix: prefix, now: count, old: other?.count) {
            return abs($1 - $0)
        }
    }
}
