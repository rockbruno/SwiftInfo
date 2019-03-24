import Foundation

public struct TargetCountProvider: InfoProvider {

    public static let identifier: String = "target_count"

    public let description: String = "Dependency Count"
    public let count: Int

    public init(count: Int) {
        self.count = count
    }

    public static func extract() throws -> TargetCountProvider {
        guard let buildLog = FileUtils().buildLog else {
            fail("No build log!")
        }
        let modules = Set(buildLog.match(regex: "(?<=-module-name ).*?(?= )"))
        return TargetCountProvider(count: modules.count)
    }

    public func summary(comparingWith other: TargetCountProvider?) -> String {
        let regularMessage = "Dependency Count: \(count)"
        guard let other = other else {
            return regularMessage
        }
        if count == other.count {
            return regularMessage
        }
        let difference = abs(other.count - count)
        let modifier = count > other.count ? "*grew*" : "was *reduced*"
        return "Dependency count \(modifier) by \(difference) (\(count))"
    }
}
