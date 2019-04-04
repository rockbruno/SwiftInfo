import Foundation

public struct LongestTestDurationProvider: InfoProvider {

    public static let identifier: String = "longest_test_duration"

    public let description: String = "Longest Test Duration"
    public let name: String
    public let durationInt: Int

    public var duration: Float {
        return Float(durationInt) / 1000
    }

    public init(name: String, durationInt: Int) {
        self.name = name
        self.durationInt = durationInt
    }

    public static func extract(fromApi api: SwiftInfo) throws -> LongestTestDurationProvider {
        let testLog = api.fileUtils.testLog
        let data = testLog.match(regex: "Test.*passed.*seconds\\)")
        let formatted = data.map { a -> (String, Float) in
            let components = a.components(separatedBy: "'")
            let name = components[1]
            let durationString = String(components
                                        .last?
                                        .components(separatedBy: " seconds")
                                        .first?
                                        .dropFirst()
                                        .dropFirst() ?? "")
            guard let duration = Float(durationString) else {
                fail("Failed to extract test durations.")
            }
            return (name, duration)
        }
        guard let longest = formatted.max(by: { $0.1 < $1.1 }) else {
            fail("Couldn't determine the longest test because no tests were found!")
        }
        return LongestTestDurationProvider(name: longest.0,
                                           durationInt: Int(longest.1 * 1000))
    }

    public func summary(comparingWith other: LongestTestDurationProvider?) -> Summary {
        var prefix = "⏰ Longest Test: \(name) (\(duration))"
        let style: Summary.Style
        if let other = other, other.durationInt != durationInt {
            prefix += " - previously \(other.name) (\(duration))"
            style = other.durationInt > durationInt ? .positive : .negative
        } else {
            style = .neutral
        }
        return Summary(text: prefix, style: style)
    }
}
