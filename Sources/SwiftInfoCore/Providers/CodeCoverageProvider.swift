import Foundation

public struct CodeCoverageProvider: InfoProvider {

    public struct Args {
        /// If provided, only these targets will be considered
        /// when calculating the result. The contents should be the name
        /// of the generated frameworks. For example, For MyLib.framework and MyApp.app,
        /// `targets` should be ["MyLib", "MyApp"].
        /// If no args are provided, only the coverage of the main .app will be considered.
        public let targets: Set<String>

        public init(targets: Set<String>) {
            self.targets = targets
        }
    }

    public typealias Arguments = Args

    public static let identifier: String = "code_coverage"
    static let tempFileName = "swiftinfo_codecov.txt"

    static var tempFile: URL {
        return URL(fileURLWithPath: "./\(tempFileName)")
    }

    public let description: String = "📊 Code Coverage"
    public let percentageInt: Int

    public init(percentageInt: Int) {
        self.percentageInt = percentageInt
    }

    public static func extract(fromApi api: SwiftInfo, args: Args?) throws -> CodeCoverageProvider {
        if args == nil {
            log("No targets provided, getting code coverage of the main .apps", verbose: true)
        }
        let json = try getCodeCoverageJson(api: api)
        let targets = json["targets"] as? [[String: Any]] ?? []
        let desiredTargets = try targets.filter {
            guard let rawName = $0["name"] as? String else {
                throw error("Failed to retrieve target name from xccov.")
            }
            if let targets = args?.targets,
               let name = rawName.components(separatedBy: ".").first
            {
                log("Getting code coverage of \(rawName)", verbose: true)
                let use = targets.contains(name)
                if use == false {
                    log("Skipping, as \(rawName) was not included in the args.", verbose: true)
                }
                return use
            } else {
                return rawName.hasSuffix(".app")
            }
        }
        guard desiredTargets.isEmpty == false else {
            throw error("Couldn't find the desired targets in the code coverage report.")
        }
        let lineData = try desiredTargets.map { target -> (Int, Int) in
            guard let lines = target["executableLines"] as? Int,
                  let covered = target["coveredLines"] as? Int else
            {
                throw error("One of the found targets was missing the coverage data!")
            }
            return (lines, covered)
        }.reduce((0, 0), {
            return ($0.0 + $1.0, $0.1 + $1.1)
        })
        let coverage = Double(lineData.1) / Double(lineData.0)
        let rounded = Int(1000 * coverage)
        return CodeCoverageProvider(percentageInt: rounded)
    }

    public static func getCodeCoverageJson(api: SwiftInfo) throws -> [String: Any] {
        let testLog = try api.fileUtils.testLog()
        guard let reportFilePath = testLog.match(regex: "(?<=Generated coverage report: ).*").first else {
            throw error("Couldn't find code coverage report path in the logs, is it enabled?")
        }
        removeTemporaryFileIfNeeded()
        let command = "xcrun xccov view \(reportFilePath) --json > \(tempFileName)"
        log("Processing code coverage report: \(command)", verbose: true)
        runShell(command)
        do {
            let data = try Data(contentsOf: tempFile)
            removeTemporaryFileIfNeeded()
            guard let object = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] else
            {
                throw error("xccov failed to generate a coverage JSON. Was the report file deleted?")
            }
            return object
        } catch {
            let message = "Failed to read \(tempFile)! Error: \(error.localizedDescription)"
            throw self.error(message)
        }
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

    public func summary(comparingWith other: CodeCoverageProvider?, args: Args?) -> Summary {
        let prefix = description
        let numberFormatter: ((Int) -> Float) = { value in
            return Float(value) / 10
        }
        let stringFormatter: ((Int) -> String) = { value in
            return "\(numberFormatter(value))%"
        }
        return Summary.genericFor(prefix: prefix,
                                  now: percentageInt,
                                  old: other?.percentageInt,
                                  increaseIsBad: false,
                                  stringValueFormatter: stringFormatter,
                                  numericValueFormatter: numberFormatter) {
            return abs($1 - $0)
        }
    }

    static func toPercentage(percentageInt: Int) -> Float {
        return Float(percentageInt / 10)
    }
}
