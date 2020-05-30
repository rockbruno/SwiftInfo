import Foundation
import SwiftInfoCore

let task = Process()

public struct Main {
    static func run() {
        let fileUtils = FileUtils()
        let toolchainPath = getToolchainPath()
        log("SwiftInfo 2.3.11")
        if ProcessInfo.processInfo.arguments.contains("-version") {
            exit(0)
        }
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
            exit(t.terminationStatus)
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
