import Foundation

public struct AppSizeProvider: InfoProvider {
    public func run() throws -> Info {
        return Info(dictionary: ["size": 200])
    }

    public init() {}
}
