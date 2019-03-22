import Foundation

public struct TargetCountProvider: InfoProvider {

    public let identifier: String = "target_count"
    public let description: String = "Dependency Count"

    let lessIsBetter: Bool

    public func run() throws -> Info {
        return Info(dictionary: ["count": 5])
    }

    public init(lessIsBetter: Bool = true) {
        self.lessIsBetter = lessIsBetter
    }
}
