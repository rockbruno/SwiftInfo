import Foundation

public struct OBJCFileCountProvider: InfoProvider {

    public struct Args {}
    public typealias Arguments = Args

    public static let identifier: String = "objc_file_count"

    public let description: String = "Objective-C File Count"
    public let count: Int

    public init(count: Int) {
        self.count = count
    }

    public static func extract(fromApi api: SwiftInfo, args: Args?) throws -> OBJCFileCountProvider {
        let buildLog = api.fileUtils.buildLog
        let impl = Set(buildLog.match(regex: #"CompileC.* (.*\.m)"#))
        let headers = buildLog.match(regex: "CpHeader")
        return OBJCFileCountProvider(count: impl.count + headers.count)
    }

    public func summary(comparingWith other: OBJCFileCountProvider?, args: Args?) -> Summary {
        let prefix = "🧙‍♂️ OBJ-C .h/.m File Count"
        return Summary.genericFor(prefix: prefix, now: count, old: other?.count) {
            return abs($1 - $0)
        }
    }
}
