import Foundation

public struct TestCountProvider: InfoProvider {
    public func run() throws -> Info {
        return Info(dictionary: ["count": 100])
    }

    public init() {}
}
