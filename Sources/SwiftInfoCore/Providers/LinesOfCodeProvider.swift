import Foundation

public struct LinesOfCodeProvider: InfoProvider {

    public struct Args {
        public let targets: Set<String>
        public init(targets: Set<String>) {
            self.targets = targets
        }
    }

    public typealias Arguments = Args

    public static let identifier: String = "lines_of_code"

    public let description: String = "Executable Lines of Code"
    public let count: Int

    public init(count: Int) {
        self.count = count
    }

    public static func extract(fromApi api: SwiftInfo, args: Args?) throws -> LinesOfCodeProvider {
        let json = CodeCoverageProvider.getCodeCoverageJson(api: api)
        let targets = json["targets"] as? [[String: Any]] ?? []
        let count = targets.reduce(0) {
            let current = $0
            let target = $1
            guard let rawName = target["name"] as? String,
                  let name = rawName.components(separatedBy: ".").first else
            {
                fail("Failed to retrieve target name from xccov.")
            }
            guard args?.targets.contains(name) != false else {
                return current
            }
            guard let count = target["executableLines"] as? Int else {
                fail("Failed to retrieve the number of executable lines from xccov.")
            }
            return current + count
        }
        return LinesOfCodeProvider(count: count)
    }

    public func summary(comparingWith other: LinesOfCodeProvider?, args: Args?) -> Summary {
        let text = "💻 Executable Lines of Code"
        let summary = Summary.genericFor(prefix: text, now: count, old: other?.count) {
            return abs($1 - $0)
        }
        return Summary(text: summary.text, style: .neutral)
    }
}
