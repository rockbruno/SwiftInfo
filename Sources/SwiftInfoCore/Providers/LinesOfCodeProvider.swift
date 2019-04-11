import Foundation

public struct LinesOfCodeProvider: InfoProvider {

    public static let identifier: String = "lines_of_code"

    public let description: String = "Executable Lines of Code"
    public let count: Int

    public init(count: Int) {
        self.count = count
    }

    public static func extract(fromApi api: SwiftInfo) throws -> LinesOfCodeProvider {
        let json = CodeCoverageProvider.getCodeCoverageJson(api: api)
        guard let count = json["executableLines"] as? Int else {
            fail("Failed to retrieve the number of executable lines from xccov.")
        }
        return LinesOfCodeProvider(count: count)
    }

    public func summary(comparingWith other: LinesOfCodeProvider?) -> Summary {
        let text = "💻 Executable Lines of Code"
        let summary = Summary.genericFor(prefix: text, now: count, old: other?.count) {
            return abs($1 - $0)
        }
        return Summary(text: summary.text, style: .neutral)
    }
}
