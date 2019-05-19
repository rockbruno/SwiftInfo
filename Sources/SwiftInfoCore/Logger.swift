import Foundation

public var isInVerboseMode = ProcessInfo.processInfo.arguments.contains("-v")
public var isInSilentMode = ProcessInfo.processInfo.arguments.contains("-s")
public var isInPullRequestMode = ProcessInfo.processInfo.arguments.contains("-pullRequest")
public var printSourceKitQueries = ProcessInfo.processInfo.arguments.contains("-print-sourcekit")

public func log(_ message: String, verbose: Bool = false, sourceKit: Bool = false, hasPrefix: Bool = true) {
    guard isInSilentMode == false else {
        return
    }
    guard (sourceKit && printSourceKitQueries) || verbose == false || isInVerboseMode else {
        return
    }
    print("\(hasPrefix ? "* " : "")\(message)")
}
