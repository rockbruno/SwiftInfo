import Foundation

public protocol InfoProvider: Codable {
    static var identifier: String { get }
    static func extract() throws -> Self
    var description: String { get }
    func summary(comparingWith other: Self?) -> String
}
