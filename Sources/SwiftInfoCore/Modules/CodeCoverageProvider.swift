import Foundation

public struct CodeCoverageProvider: InfoProvider {
    public func run() throws -> Info {
        return Info(dictionary: ["coverage": 80])
    }

    public init() {}
}
