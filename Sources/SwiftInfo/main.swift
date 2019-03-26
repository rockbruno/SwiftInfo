import Foundation
import SwiftInfoCore

struct Main {
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
        shell.run("install_name_tool",
                  "-id",
                  toolFolder + "/libSwiftInfoCore.dylib",
                  toolFolder + "/libSwiftInfoCore.dylib")
        //FIXME: Shutting down SwiftInfo should force the sub processes to shut down as well.
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

Main.run()
