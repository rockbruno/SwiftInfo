import Foundation

public struct TestCountProvider: InfoProvider {

    public let identifier: String = "test_count"
    public let description: String = "Test Cases Count"

    public func run() throws -> Info {
        guard let testLog = FileUtils().testLog else {
            print("No test log!")
            fatalError()
        }
        let count = testLog.insensitiveMatch(regex: "Test Case '.*' passed").count +
                    testLog.insensitiveMatch(regex: "Test Case '.*' failed").count
        return Info(dictionary: ["count": count])
    }

    public init() {}
}
