import Foundation

public enum Runner {
    public static func getCoreSwiftCArguments(fileUtils: FileUtils,
                                              processInfoArgs: [String]) -> [String] {
        return [
            "swiftc",
            "--driver-mode=swift", // Don't generate a binary, just run directly.
            "-L", // Link with SwiftInfoCore manually.
            fileUtils.toolFolder,
            "-I",
            fileUtils.toolFolder,
            "-lSwiftInfoCore",
            fileUtils.infofileFolder + "Infofile.swift",
            ] + Array(processInfoArgs.dropFirst()) // Route SwiftInfo args to the sub process
    }
}
