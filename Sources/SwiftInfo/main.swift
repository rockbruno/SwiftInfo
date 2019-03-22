import Foundation
import SwiftInfoCore

struct SwiftInfo {
    static func run() {
        let utils = FileUtils()
        guard let path = utils.infofileFolder() else {
            print("Infofile.swift not found.")
            exit(-1)
        }
        guard let toolFolder = utils.toolFolder() else {
            print("Couldn't determine the folder that's running SwiftInfo.")
            exit(-1)
        }
        print("SwiftInfo")
        let shell = Shell()
        shell.run("swiftc",
                  path + "Infofile.swift",
                  "-I",
                  toolFolder,
                  "-L",
                  toolFolder,
                  "-lSwiftInfoCore")
        shell.run("./Infofile")
        shell.run("rm", "Infofile")
    }
}

SwiftInfo.run()
