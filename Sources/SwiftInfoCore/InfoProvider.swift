import Foundation

public protocol InfoProvider {
    var identifier: String { get }
    var description: String { get }
    func run() throws -> Info
}
