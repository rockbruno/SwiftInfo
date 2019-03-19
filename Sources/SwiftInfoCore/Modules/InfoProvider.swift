import Foundation

public protocol InfoProvider {
    func run() throws -> Info
}
