import Foundation
import SwiftInfoCore

let task = Process()

struct Main {
    static func run() {
        let utils = FileUtils()
        let path = utils.infofileFolder()
        let toolFolder = utils.toolFolder()

        log("SwiftInfo")
        log("Dylib Folder: \(toolFolder)", verbose: true)
        log("Infofile Path: \(path)", verbose: true)

        let args = ["swiftc",
        "--driver-mode=swift", // Don't generate a binary, just run directly.
        "-L", // Link with SwiftInfoCore manually.
        toolFolder,
        "-I",
        toolFolder,
        "-lSwiftInfoCore",
        path + "Infofile.swift",
        ] + Array(ProcessInfo.processInfo.arguments.dropFirst()) // Route SwiftInfo args to the sub process

        task.launchPath = "/bin/bash"
        task.arguments = ["-c", args.joined(separator: " ")]
        task.standardOutput = FileHandle.standardOutput
        task.standardError = FileHandle.standardError

        task.terminationHandler = { t -> Void in
            exit(t.terminationStatus)
        }

        task.launch()
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
Main.run()
dispatchMain()
