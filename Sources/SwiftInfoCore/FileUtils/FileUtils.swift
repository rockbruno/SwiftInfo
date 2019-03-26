import Foundation

public struct FileUtils {
    public static let supportedInfofilePaths = ["./", "../", "../../", "../../../"]
    public static var buildLogFilePath = ""
    public static var testLogFilePath = ""

    public let outputFileName = "SwiftInfoOutput.json"
    public let infofileName = "Infofile.swift"

    public let fileManager: FileManager
    public let fileOpener: FileOpener

    public init(fileManager: FileManager = .default,
                fileOpener: FileOpener = .init()) {
        self.fileManager = fileManager
        self.fileOpener = fileOpener
    }

    public var toolFolder: String {
        guard let executionPath = ProcessInfo.processInfo.arguments.first,
              let url = URL(string: executionPath)?.deletingLastPathComponent().absoluteString else
        {
            fail("Couldn't determine the folder that's running SwiftInfo.")
        }
        return url
    }

    func _getInfofileFolder() -> String? {
        return FileUtils.supportedInfofilePaths.first {
            fileManager.fileExists(atPath: $0 + infofileName)
        }
    }

    public var infofileFolder: String {
        guard let folder = _getInfofileFolder() else {
            fail("Infofile.swift not found.")
        }
        return folder
    }

    func _getTestLog() throws -> String {
        let folder = infofileFolder
        let url = URL(fileURLWithPath: folder + FileUtils.testLogFilePath)
        return try fileOpener.stringContents(ofUrl: url)
    }

    public var testLog: String {
        do {
            let testLog = try _getTestLog()
            return testLog
        } catch {
            fail("""
                Test log not found!
                Expected path: \(FileUtils.testLogFilePath)
                Thrown error: \(error.localizedDescription)
                """)
        }
    }

    func _getBuildLog() throws -> String {
        let folder = infofileFolder
        let url = URL(fileURLWithPath: folder + FileUtils.buildLogFilePath)
        return try fileOpener.stringContents(ofUrl: url)
    }

    public var buildLog: String {
        do {
            let testLog = try _getTestLog()
            return testLog
        } catch {
            fail("""
                Build log not found!
                Expected path: \(FileUtils.buildLogFilePath)
                Thrown error: \(error.localizedDescription)
                """)
        }
    }

    public var outputFileFolder: String {
        return infofileFolder + "SwiftInfo-output/"
    }

    public var outputFileURL: URL {
        return URL(fileURLWithPath: outputFileFolder + outputFileName)
    }

    public var fullOutput: [String: Any] {
        guard let data = try? fileOpener.dataContents(ofUrl: outputFileURL) else {
            return [:]
        }
        let object = try? JSONSerialization.jsonObject(with: data, options: [])
        return object as? [String: Any] ?? [:]
    }

    public var outputArray: [[String: Any]] {
        return (fullOutput["data"] as? [[String: Any]]) ?? []
    }

    public var lastOutput: Output {
        return Output(rawDictionary: outputArray.first ?? [:], summaries: [])
    }

    public func save(output: [[String: Any]]) throws {
        let path = outputFileURL
        log("Path to save: \(path.absoluteString)", verbose: true)
        let dictionary = ["data": output]
        let json = try JSONSerialization.data(withJSONObject: dictionary, options: [.prettyPrinted])
        try? fileManager.createDirectory(atPath: outputFileFolder,
                                         withIntermediateDirectories: true,
                                         attributes: nil)
        try fileOpener.write(data: json, toUrl: path)
    }
}
