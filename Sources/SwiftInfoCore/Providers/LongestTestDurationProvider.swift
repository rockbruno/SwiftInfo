import Foundation

public struct LongestTestDurationProvider: InfoProvider {

    public struct Args {}
    public typealias Arguments = Args

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

    public static func extract(fromApi api: SwiftInfo, args: Args?) throws -> LongestTestDurationProvider {
        let testLog = api.fileUtils.testLog
        let data = testLog.match(regex: #"Test.* seconds\)"#)
        let formatted = data
                        .filter { $0.contains(" passed ") }
                        .map { str -> (String, Float) in
            let components = str.components(separatedBy: "'")
            let name = components[1]
            let secondsPart = components.last
            let timePart = secondsPart?.components(separatedBy: " seconds") ?? []
            let time = timePart[timePart.count - 2].components(separatedBy: "(").last
            guard let duration = Float(time ?? "") else {
                fail("Failed to extract test duration from this line: \(str).")
            }
            return (name, duration)
        }
        guard let longest = formatted.max(by: { $0.1 < $1.1 }) else {
            fail("Couldn't determine the longest test because no tests were found!")
        }
        return LongestTestDurationProvider(name: longest.0,
                                           durationInt: Int(longest.1 * 1000))
    }

    public func summary(comparingWith other: LongestTestDurationProvider?, args: Args?) -> Summary {
        var prefix = "⏰ Longest Test: \(name) (\(duration) secs)"
        let style: Summary.Style
        if let other = other, other.durationInt != durationInt {
            prefix += " - previously \(other.name) (\(duration) secs)"
            style = other.durationInt > durationInt ? .positive : .negative
        } else {
            style = .neutral
        }
        return Summary(text: prefix, style: style)
    }
}
