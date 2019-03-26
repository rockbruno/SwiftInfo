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
        let testLog = api.fileUtils.testLog
        guard let reportFilePath = testLog.match(regex: "(?<=Generated coverage report: ).*").first else {
            fail("Couldn't find code coverage report, is it enabled?")
        }
        let shell = api.shell
        removeTemporaryFile()
        _ = shell.run(supressOutput: true, "xcrun xccov view \(reportFilePath) --json > \(tempFileName)")
        let data = try! Data(contentsOf: tempFile)
        removeTemporaryFile()
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
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

    static func removeTemporaryFile() {
        _ = Shell().run(supressOutput: true, "rm \(tempFile.path)")
    }

    public func summary(comparingWith other: CodeCoverageProvider?) -> Summary {
        let prefix = "📊 Code Coverage"
        let percentage = toPercentage(percentageInt: percentageInt)
        guard let other = other else {
            return Summary(text: prefix + ": \(percentage)", style: .neutral)
        }
        guard percentageInt != other.percentageInt else {
            return Summary(text: prefix + ": Unchanged. (\(percentage))", style: .neutral)
        }
        let modifier: String
        let style: Summary.Style
        if percentageInt > other.percentageInt {
            modifier = "*grew*"
            style = .positive
        } else {
            modifier = "was *reduced*"
            style = .negative
        }
        let differenceInt = abs(other.percentageInt - percentageInt)
        let differencePercentage = toPercentage(percentageInt: differenceInt)
        let text = prefix + " \(modifier) by \(percentage) (\(differencePercentage))"
        return Summary(text: text, style: style)
    }

    func toPercentage(percentageInt: Int) -> String {
        return "\(Double(percentageInt) / 10)%"
    }
}
