import Foundation

/// The base protocol that defines a struct capable of extracting and comparing pieces of information.
public protocol InfoProvider: Codable {
    /// A structure that represents the arguments to use when extracting and comparing this provider.
    associatedtype Arguments

    /// The unique identifier of this provider.
    static var identifier: String { get }

    /// Executes this provider and returns an instance of it that contains the extracted info.
    static func extract(fromApi api: SwiftInfo, args: Arguments?) throws -> Self

    /// The descriptive name of this provider, for visual purposes.
    var description: String { get }

    /// Given another instance of this provider, return a `Summary` that explains the difference between them.
    func summary(comparingWith other: Self?, args: Arguments?) -> Summary
}

extension InfoProvider {
    static func extract(fromApi api: SwiftInfo) throws -> Self {
        return try extract(fromApi: api, args: nil)
    }

    func summary(comparingWith other: Self?) -> Summary {
        return summary(comparingWith: other, args: nil)
    }

    public static func error(_ message: String) -> SwiftInfoError {
        return .generic(message)
    }
}
