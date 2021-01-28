import Foundation

public enum Runner {
    public static func getCoreSwiftCArguments(fileUtils: FileUtils,
                                              toolchainPath: String,
                                              processInfoArgs: [String]) -> [String] {
        let include = fileUtils.toolFolder + "/../include/swiftinfo"
        return [
            "swiftc",
            "--driver-mode=swift", // Don't generate a binary, just run directly.
            "-L", // Link with SwiftInfoCore manually.
            include,
            "-I",
            include,
            "-lSwiftInfoCore",
            "-Xcc",
            "-fmodule-map-file=\(include)/Csourcekitd/include/module.modulemap",
            "-I",
            "\(include)/Csourcekitd/include",
            (try! fileUtils.infofileFolder()) + "Infofile.swift",
            "-toolchain",
            "\(toolchainPath)",
        ] + Array(processInfoArgs.dropFirst()) // Route SwiftInfo args to the sub process
    }
}
