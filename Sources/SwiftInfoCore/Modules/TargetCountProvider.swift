import Foundation

public struct TargetCountProvider: InfoProvider {

    let lessIsBetter: Bool

    public func run() throws -> Info {
        return Info(dictionary: ["count": 5])
    }

    public init(lessIsBetter: Bool = true) {
        self.lessIsBetter = lessIsBetter
    }
}
