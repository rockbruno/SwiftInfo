import Foundation

/// Number of OBJ-C files and headers (for mixed OBJ-C / Swift projects).
/// Requirements: Build logs.
public struct OBJCFileCountProvider: InfoProvider {
    public struct Args {}
    public typealias Arguments = Args

    public static let identifier: String = "objc_file_count"

    public var description: String { "🧙‍♂️ OBJ-C .h/.m File Count" }
    public let count: Int

    public init(count: Int) {
        self.count = count
    }

    public static func extract(fromApi api: SwiftInfo, args _: Args?) throws -> OBJCFileCountProvider {
        let buildLog = try api.fileUtils.buildLog()
        let impl = Set(buildLog.match(regex: #"CompileC.* (.*\.m)"#))
        let headers = buildLog.match(regex: "CpHeader")
        return OBJCFileCountProvider(count: impl.count + headers.count)
    }

    public func summary(comparingWith other: OBJCFileCountProvider?, args _: Args?) -> Summary {
        let prefix = description
        return Summary.genericFor(prefix: prefix, now: count, old: other?.count, increaseIsBad: true)
    }
}
