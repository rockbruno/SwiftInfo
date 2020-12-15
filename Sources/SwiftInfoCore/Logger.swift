import Foundation

public var isInVerboseMode = false
public var isInSilentMode = false
public var isInPullRequestMode = false
public var printSourceKitQueries = false

public func log(_ message: String, verbose: Bool = false, sourceKit: Bool = false, hasPrefix: Bool = true) {
    guard isInSilentMode == false else {
        return
    }
    guard (sourceKit && printSourceKitQueries) || verbose == false || isInVerboseMode else {
        return
    }
    print("\(hasPrefix ? "* " : "")\(message)")
}
