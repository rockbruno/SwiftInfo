import Foundation

public struct FileUtils {
    public static let supportedInfofilePaths = ["./", "../", "../../", "../../../"]
    public static var buildLogFilePath = ""
    public static var testLogFilePath = ""
    public static var buckLogFilePath = ""

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
        guard let executablePath = ProcessInfo.processInfo.arguments.first else {
            fail("Couldn't determine the folder that's running SwiftInfo.")
        }

        let executableUrl = URL(fileURLWithPath: executablePath)
        if let isAliasFile = try! executableUrl.resourceValues(forKeys: [URLResourceKey.isAliasFileKey]).isAliasFile, isAliasFile {
            return try! URL(resolvingAliasFileAt: executableUrl).deletingLastPathComponent().path
        } else {
            return executableUrl.deletingLastPathComponent().path
        }
    }

    public func infofileFolder() throws -> String {
        guard let path = FileUtils.supportedInfofilePaths.first(where: {
            fileManager.fileExists(atPath: $0 + infofileName)
        }) else {
            throw SwiftInfoError.generic("Infofile.swift not found.")
        }
        return path
    }

    public func testLog() throws -> String {
        let folder = try infofileFolder()
        let url = URL(fileURLWithPath: folder + FileUtils.testLogFilePath)
        do {
            return try fileOpener.stringContents(ofUrl: url)
        } catch {
            throw SwiftInfoError.generic("""
                Test log not found!
                Expected path: \(FileUtils.testLogFilePath)
                Thrown error: \(error.localizedDescription)
            """)
        }
    }

    public func buckLog() throws -> String {
        let folder = try infofileFolder()
        let url = URL(fileURLWithPath: folder + FileUtils.buckLogFilePath)
        do {
            return try fileOpener.stringContents(ofUrl: url)
        } catch {
            throw SwiftInfoError.generic("""
                Buck's log not found!
                Expected path: \(FileUtils.buckLogFilePath)
                Thrown error: \(error.localizedDescription)
            """)
        }
    }

    public func buildLog() throws -> String {
        let folder = try infofileFolder()
        let url = URL(fileURLWithPath: folder + FileUtils.buildLogFilePath)
        do {
            return try fileOpener.stringContents(ofUrl: url)
        } catch {
            throw SwiftInfoError.generic("""
                Build log not found!
                Expected path: \(FileUtils.buildLogFilePath)
                Thrown error: \(error.localizedDescription)
            """)
        }
    }

    public func outputFileFolder() throws -> String {
        return (try infofileFolder()) + "SwiftInfo-output/"
    }

    public func outputFileURL() throws -> URL {
        return URL(fileURLWithPath: (try outputFileFolder()) + outputFileName)
    }

    public func fullOutput() throws -> [String: Any] {
        guard let data = try? fileOpener.dataContents(ofUrl: (try outputFileURL())) else {
            return [:]
        }
        let object = try JSONSerialization.jsonObject(with: data, options: [])
        return object as? [String: Any] ?? [:]
    }

    public func outputArray() throws -> [[String: Any]] {
        return ((try fullOutput())["data"] as? [[String: Any]]) ?? []
    }

    public func lastOutput() throws -> Output {
        let array = try outputArray()
        return Output(rawDictionary: array.first ?? [:], summaries: [], errors: [])
    }

    public func save(output: [[String: Any]]) throws {
        let path = try outputFileURL()
        log("Path to save: \(path.absoluteString)", verbose: true)
        let dictionary = ["data": output]
        let json = try JSONSerialization.data(withJSONObject: dictionary, options: [.prettyPrinted])
        try? fileManager.createDirectory(atPath: (try outputFileFolder()),
                                         withIntermediateDirectories: true,
                                         attributes: nil)
        try fileOpener.write(data: json, toUrl: path)
    }
}

public enum SwiftInfoError: Error, LocalizedError {
    case generic(String)

    public var errorDescription: String? {
        switch self {
        case let .generic(message):
            return message
        }
    }
}
