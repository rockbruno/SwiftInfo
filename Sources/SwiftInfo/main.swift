import ArgumentParser
import Foundation
import SwiftInfoCore

let task = Process()

struct Swiftinfo: ParsableCommand {
    static var configuration = CommandConfiguration(
        abstract: "Swiftinfo 2.3.14",
        subcommands: []
    )

    /// Since we are using .unconditionalRemaining, --help doesnt work anymore.
    /// Thus, we added a manual flag here.
    @Flag(name: .shortAndLong, help: "Show help information.")
    var help = false

    @Flag(name: .shortAndLong, help: "Silences all logs.")
    var silent = false

    @Flag(name: .shortAndLong, help: "Logs additional details to the console.")
    var verbose = false

    @Flag(name: .shortAndLong, help: "Logs SourceKit requests to the console.")
    var printSourcekit = false

    @Argument(parsing: .unconditionalRemaining, help: "Any additional arguments that you would like your Infofile.swift to receive. These arguments can be retrieved in your Infofile through CommandLine's APIs to customize your runs.")
    var arguments: [String] = []

    mutating func run() throws {
        guard !help else {
            print(Swiftinfo.helpMessage())
            Swiftinfo.exit()
        }

        setupLogConfig()

        let fileUtils = FileUtils()
        let toolchainPath = getToolchainPath()

        log("Dylib Folder: \(fileUtils.toolFolder)", verbose: true)
        log("Infofile Path: \(try! fileUtils.infofileFolder())", verbose: true)
        log("Toolchain Path: \(toolchainPath)", verbose: true)

        let processInfoArgs = ProcessInfo.processInfo.arguments
        let args = Runner.getCoreSwiftCArguments(fileUtils: fileUtils,
                                                 toolchainPath: toolchainPath,
                                                 processInfoArgs: processInfoArgs)
            .joined(separator: " ")

        log("Swiftc Args: \(args)", verbose: true)

        task.launchPath = "/bin/bash"
        task.arguments = ["-c", args]
        task.standardOutput = FileHandle.standardOutput
        task.standardError = FileHandle.standardError

        task.terminationHandler = { t -> Void in
            Swiftinfo.exit()
        }

        task.launch()
    }

    private func getToolchainPath() -> String {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", "xcode-select -p"]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        guard let developer = String(data: data, encoding: .utf8), developer.isEmpty == false else {
            fail("Xcode toolchain path not found. (xcode-select -p)")
        }
        let oneLined = developer.replacingOccurrences(of: "\n", with: "")
        return oneLined + "/Toolchains/XcodeDefault.xctoolchain/usr/lib/sourcekitd.framework/sourcekitd"
    }

    private func setupLogConfig() {
        isInVerboseMode = verbose
        isInSilentMode = silent
        printSourceKitQueries = printSourcekit
    }
}

/////////
// Detect interruptions and use it to interrupt the sub process.
signal(SIGINT, SIG_IGN)
let source = DispatchSource.makeSignalSource(signal: SIGINT)
source.setEventHandler {
    task.interrupt()
    exit(SIGINT)
}

////////

source.resume()
Swiftinfo.main()
dispatchMain()
