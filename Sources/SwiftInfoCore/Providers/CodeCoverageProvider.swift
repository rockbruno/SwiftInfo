import Foundation

public struct CodeCoverageProvider: InfoProvider {

    public static let identifier: String = "code_coverage"
    static let tempFileName = "swiftinfo_codecov.txt"

    static var tempFile: URL {
        return URL(fileURLWithPath: "./\(tempFileName)")
    }

    public let description: String = "Code Coverage"
    public let percentageInt: Int

    public init(percentageInt: Int) {
        self.percentageInt = percentageInt
    }

    public static func extract(fromApi api: SwiftInfo) throws -> CodeCoverageProvider {
        let json = getCodeCoverageJson(api: api)
        let targets = json["targets"] as! [[String: Any]]
        guard let desiredTarget = targets.first(where: {
            let name = ($0["name"] as? String ?? "")
            return name.hasSuffix(".app")
        }) else {
            fail("Couldn't find .app target in code coverage report.")
        }
        let codeCoverage = desiredTarget["lineCoverage"] as! Double
        let rounded = Int(1000 * codeCoverage)
        return CodeCoverageProvider(percentageInt: rounded)
    }

    static func getCodeCoverageJson(api: SwiftInfo) -> [String: Any] {
        let testLog = api.fileUtils.testLog
        guard let reportFilePath = testLog.match(regex: "(?<=Generated coverage report: ).*").first else {
            fail("Couldn't find code coverage report, is it enabled?")
        }
        removeTemporaryFileIfNeeded()
        runShell("xcrun xccov view \(reportFilePath) --json > \(tempFileName)")
        let data = try! Data(contentsOf: tempFile)
        removeTemporaryFileIfNeeded()
        return try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    }

    static func removeTemporaryFileIfNeeded() {
        runShell("rm \(tempFile.path)")
    }

    static func runShell(_ command: String) {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", command]
        task.standardOutput = nil
        task.standardError = nil
        task.launch()
        task.waitUntilExit()
    }

    public func summary(comparingWith other: CodeCoverageProvider?) -> Summary {
        let prefix = "📊 Code Coverage"
        let formatter: ((Int) -> String) = { value in
            return "\(CodeCoverageProvider.toPercentage(percentageInt: value))"
        }
        return Summary.genericFor(prefix: prefix, now: percentageInt, old: other?.percentageInt, formatter: formatter) {
            return abs($1 - $0)
        }
    }

    static func toPercentage(percentageInt: Int) -> String {
        return "\(Double(percentageInt) / 10)%"
    }
}
