import Foundation
import SwiftInfoCore

struct SwiftInfo {
    static func run() {
        let utils = FileUtils()
        guard let path = utils.infofileFolder() else {
            fail("Infofile.swift not found.")
        }
        guard let toolFolder = utils.toolFolder() else {
            fail("Couldn't determine the folder that's running SwiftInfo.")
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
        shell.run("rm Infofile")
    }
}

SwiftInfo.run()
