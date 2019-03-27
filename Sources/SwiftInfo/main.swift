import Foundation
import SwiftInfoCore

let task = Process()

public struct Main {
    static func run() {
        let fileUtils = FileUtils()
        log("SwiftInfo")
        log("Dylib Folder: \(fileUtils.toolFolder)", verbose: true)
        log("Infofile Path: \(fileUtils.infofileFolder)", verbose: true)

        let processInfoArgs = ProcessInfo.processInfo.arguments
        let args = Runner.getCoreSwiftCArguments(fileUtils: fileUtils,
                                                 processInfoArgs: processInfoArgs)

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
