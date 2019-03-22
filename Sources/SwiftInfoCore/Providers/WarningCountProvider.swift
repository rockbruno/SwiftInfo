import Foundation

public struct WarningCountProvider: InfoProvider {

    public let identifier: String = "warning_count"
    public let description: String = "Warning Count"

    public func run() throws -> Info {
        guard let buildLog = FileUtils().buildLog else {
            print("No build log!")
            fatalError()
        }
        let results = buildLog.insensitiveMatch(regex: "\n.*warning:.*\n").map {
            String(buildLog[Range($0.range, in: buildLog)!])
        }
        let count = Set(results).count
        return Info(dictionary: ["count": count])
    }

    public init() {}
}
