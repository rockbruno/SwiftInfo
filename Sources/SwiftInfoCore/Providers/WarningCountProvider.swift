import Foundation

public struct WarningCountProvider: InfoProvider {

    public static let identifier: String = "warning_count"

    public let description: String = "Warning Count"
    public let count: Int

    public init(count: Int) {
        self.count = count
    }

    public static func extract() throws -> WarningCountProvider {
        guard let buildLog = FileUtils().buildLog else {
            fail("No build log!")
        }
        let results = buildLog.match(regex: "\n.*warning:.*\n")
        let count = Set(results).count
        return WarningCountProvider(count: count)
    }

    public func summary(comparingWith other: WarningCountProvider?) -> String {
        let regularMessage = "Warning count: \(count)"
        guard let other = other else {
            return regularMessage
        }
        if count == other.count {
            return regularMessage
        }
        let difference = abs(other.count - count)
        let modifier = count > other.count ? "*grew*" : "was *reduced*"
        return "Warning count \(modifier) by \(difference) (\(count))"
    }
}
