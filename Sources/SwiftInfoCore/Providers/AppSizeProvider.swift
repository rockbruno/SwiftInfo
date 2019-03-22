import Foundation

public struct AppSizeProvider: InfoProvider {

    public let identifier: String = "app_size"
    public let description: String = "App Size"

    public func run() throws -> Info {
        return Info(dictionary: ["size": 200])
    }

    public init() {}
}
