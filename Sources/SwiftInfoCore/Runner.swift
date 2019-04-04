import Foundation

public enum Runner {
    public static func getCoreSwiftCArguments(fileUtils: FileUtils,
                                              toolchainPath: String,
                                              processInfoArgs: [String]) -> [String] {
        return [
            "swiftc",
            "--driver-mode=swift", // Don't generate a binary, just run directly.
            "-L", // Link with SwiftInfoCore manually.
            fileUtils.toolFolder,
            "-I",
            fileUtils.toolFolder,
            "-lSwiftInfoCore",
            "-Xcc",
            "-fmodule-map-file=\(fileUtils.toolFolder)Csourcekitd/include/module.modulemap",
            "-I",
            "\(fileUtils.toolFolder)Csourcekitd/include",
            fileUtils.infofileFolder + "Infofile.swift",
            "-toolchain",
            "\(toolchainPath)"] + Array(processInfoArgs.dropFirst()) // Route SwiftInfo args to the sub process
    }
}
