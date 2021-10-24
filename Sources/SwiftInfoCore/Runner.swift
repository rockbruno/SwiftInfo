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
            // Swift 5.5 (from Xcode 13+) uses the new swift-driver which doesn't support -toolchain arg
            // Disabling the driver for now as a workaround so it works with Swift 5.5 and older versions
            "-disallow-use-new-driver",
        ] + Array(processInfoArgs.dropFirst()) // Route SwiftInfo args to the sub process
    }
}
