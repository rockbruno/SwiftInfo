import Foundation

open class FileOpener {
    open func stringContents(ofUrl url: URL) throws -> String {
        return try String(contentsOf: url)
    }

    open func dataContents(ofUrl url: URL) throws -> Data {
        return try Data(contentsOf: url)
    }

    open func plistContents(ofPath path: String) -> NSDictionary? {
        return NSDictionary(contentsOfFile: path)
    }

    open func write(data: Data, toUrl url: URL) throws {
        try data.write(to: url)
    }

    public init() {}
}
