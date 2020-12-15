import ArgumentParser
import Foundation
import SwiftInfoCore

let task = Process()

struct SwiftInfo: ParsableCommand {

    @Flag(name: .long, help: "return current version of `SwiftInfo`")
    var version = false

    @Flag(name: .shortAndLong, help: "silent all logs")
    var silent = false

    @Flag(name: .shortAndLong, help: "logs all details to console")
    var verbose = false

    @Flag(name: .long, help: "is in pull request mode")
    var pullRequest = false

    @Flag(name: .long, help: "print source kit")
    var sourceKit = false

    @Argument(help: "One or more user related Swiftc Args")
    var arguments: [String] = []

    mutating func run() throws {
        setupLogConfig()
        if version {
            log("SwiftInfo 2.3.12")
            SwiftInfo.exit()
        }
        guard let executablePath = CommandLine.arguments.first else {
            fail("Couldn't determine the folder that's running SwiftInfo.")
        }
        let fileUtils = FileUtils(path: executablePath)
        let toolchainPath = SwiftInfo.getToolchainPath()

        log("Dylib Folder: \(fileUtils.toolFolder)", verbose: true)
        log("Infofile Path: \(try! fileUtils.infofileFolder())", verbose: true)
        log("Toolchain Path: \(toolchainPath)", verbose: true)

        let args = Runner.getCoreSwiftCArguments(fileUtils: fileUtils,
                                                 toolchainPath: toolchainPath,
                                                 processInfoArgs: arguments)
            .joined(separator: " ")

        log("Swiftc Args: \(args)", verbose: true)

        task.launchPath = "/bin/bash"
        task.arguments = ["-c", args]
        task.standardOutput = FileHandle.standardOutput
        task.standardError = FileHandle.standardError

        task.terminationHandler = { t -> Void in
            SwiftInfo.exit()
        }

        task.launch()
    }

    static func getToolchainPath() -> String {
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
        isInPullRequestMode = pullRequest
        printSourceKitQueries = sourceKit
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
SwiftInfo.main(CommandLine.arguments)
dispatchMain()
