import Foundation

public struct FileUtils {
    public static let supportedInfofilePaths = ["./", "../", "../../", "../../../"]
    public static var buildLogFilePath = ""
    public static var testLogFilePath = ""

    public let outputFileName = "SwiftInfoOutput.json"

    public var testLog: String? {
        let url = URL(fileURLWithPath: FileUtils.testLogFilePath)
        return try? String(contentsOf: url)
    }

    public var buildLog: String? {
        let url = URL(fileURLWithPath: FileUtils.buildLogFilePath)
        return try? String(contentsOf: url)
    }

    public var outputJson: [[String: Any]] {
        guard let data = try? Data(contentsOf: outputFileFolderURL()) else {
            return []
        }
        let object = try? JSONSerialization.jsonObject(with: data, options: [])
        let json = object as? [String: Any]
        return json?["data"] as? [[String: Any]] ?? []
    }

    public var lastOutput: Output {
        let last = outputJson.first ?? [:]
        return Output(rawDictionary: last)
    }

    public init() {}

    public func infofileFolder() -> String? {
        return FileUtils.supportedInfofilePaths.first {
            FileManager.default.fileExists(atPath: $0 + "Infofile.swift")
        }
    }

    public func outputFileFolderPath() -> String {
        return (infofileFolder() ?? "") + "SwiftInfo-output/"
    }

    public func outputFileFolderURL() -> URL {
        return URL(fileURLWithPath: outputFileFolderPath() + outputFileName)
    }

    public func toolFolder() -> String? {
        guard let executionPath = ProcessInfo.processInfo.arguments.first else {
            return nil
        }
        return URL(string: executionPath)?.deletingLastPathComponent().absoluteString
    }

    public func save(output: [[String: Any]]) throws {
        let dictionary = ["data": output]
        let json = try JSONSerialization.data(withJSONObject: dictionary, options: [.prettyPrinted])
        try? FileManager.default.createDirectory(atPath: outputFileFolderPath(),
                                                 withIntermediateDirectories: true,
                                                 attributes: nil)
        try json.write(to: outputFileFolderURL())
    }
}
