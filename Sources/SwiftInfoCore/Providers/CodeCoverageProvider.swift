import Foundation

public struct CodeCoverageProvider: InfoProvider {

    public let identifier: String = "code_coverage"
    public let description: String = "Code Coverage"

    public func run() throws -> Info {
        return Info(dictionary: ["coverage": 80])
    }

    public init() {}
}
