import Foundation

public struct FileUtils {
    public static let supportedInfofilePaths = ["./", "../", "../../", "../../../"]
    public static var buildLogFilePath = ""
    public static var testLogFilePath = ""

    public let outputFileName = "SwiftInfoOutput.json"

    public var testLog: String {
        let folder = infofileFolder()
        let url = URL(fileURLWithPath: folder + FileUtils.testLogFilePath)
        do {
            return try String(contentsOf: url)
        } catch {
            fail("""
            Build log not found!
            Expected path: \(FileUtils.testLogFilePath)
            Thrown error: \(error.localizedDescription)
            """)
        }
    }

    public var buildLog: String {
        let folder = infofileFolder()
        let url = URL(fileURLWithPath: folder + FileUtils.buildLogFilePath)
        do {
            return try String(contentsOf: url)
        } catch {
            fail("""
                Build log not found!
                Expected path: \(FileUtils.buildLogFilePath)
                Thrown error: \(error.localizedDescription)
            """)
        }
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
        return Output(rawDictionary: last, summaries: [])
    }

    public init() {}

    public func infofileFolder() -> String {
        let path = FileUtils.supportedInfofilePaths.first {
            FileManager.default.fileExists(atPath: $0 + "Infofile.swift")
        }
        guard let result = path else {
            fail("Infofile.swift not found.")
        }
        return result
    }

    public func outputFileFolderPath() -> String {
        return infofileFolder() + "SwiftInfo-output/"
    }

    public func outputFileFolderURL() -> URL {
        return URL(fileURLWithPath: outputFileFolderPath() + outputFileName)
    }

    public func toolFolder() -> String {
        guard let executionPath = ProcessInfo.processInfo.arguments.first,
              let url = URL(string: executionPath)?.deletingLastPathComponent().absoluteString else {
            fail("Couldn't determine the folder that's running SwiftInfo.")
        }
        return url
    }

    public func save(output: [[String: Any]]) throws {
        let path = outputFileFolderURL()
        log("Path to save: \(path.absoluteString)", verbose: true)
        let dictionary = ["data": output]
        let json = try JSONSerialization.data(withJSONObject: dictionary, options: [.prettyPrinted])
        try? FileManager.default.createDirectory(atPath: outputFileFolderPath(),
                                                 withIntermediateDirectories: true,
                                                 attributes: nil)
        try json.write(to: path)
    }
}
