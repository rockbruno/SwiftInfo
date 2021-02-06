import Foundation

func args() -> [String] {
    return ProcessInfo.processInfo.arguments
}

public var isInVerboseMode = args().contains("-v") || args().contains("--verbose")
public var isInSilentMode = args().contains("-s") || args().contains("--silent")
public var isInPullRequestMode = args().contains("--pullRequest")
public var printSourceKitQueries = args().contains("-p") || args().contains("--print-sourcekit")

public func log(_ message: String, verbose: Bool = false, sourceKit: Bool = false, hasPrefix: Bool = true) {
    guard isInSilentMode == false else {
        return
    }
    guard (sourceKit && printSourceKitQueries) || verbose == false || isInVerboseMode else {
        return
    }
    print("\(hasPrefix ? "* " : "")\(message)")
}
