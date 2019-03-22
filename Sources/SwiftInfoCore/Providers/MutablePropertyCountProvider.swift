import Foundation

public struct MutablePropertyCountProvider: InfoProvider {

    public let identifier: String = "mutable_property_count"
    public let description: String = "Mutable Property Count"

    public func run() throws -> Info {
        return Info(dictionary: ["count": 20])
    }

    public init() {}
}
