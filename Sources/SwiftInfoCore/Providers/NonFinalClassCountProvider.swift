import Foundation

public struct NonFinalClassCountProvider: InfoProvider {

    public let identifier: String = "non_final_class_count"
    public let description: String = "Non-final Class Count"

    public func run() throws -> Info {
        return Info(dictionary: ["count": 20])
    }

    public init() {}
}
