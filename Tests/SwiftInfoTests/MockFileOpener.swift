import Foundation
import SwiftInfoCore

final class MockFileOpener: FileOpener {

    enum Errors: Error {
        case noData
    }

    let mockFM: MockFileManager

    init(mockFM: MockFileManager) {
        self.mockFM = mockFM
    }

    override func stringContents(ofUrl url: URL) throws -> String {
        guard let file = mockFM.stringContents(atPath: url.relativePath) else {
            throw Errors.noData
        }
        return file
    }

    override func dataContents(ofUrl url: URL) throws -> Data {
        guard let file = mockFM.dataContents(atPath: url.relativePath) else {
            throw Errors.noData
        }
        return file
    }

    override func plistContents(ofPath path: String) -> NSDictionary? {
        guard let file = mockFM.plistContents(atPath: path) else {
            return nil
        }
        return file
    }

    override func write(data: Data, toUrl url: URL) throws {
        let contents = String(data: data, encoding: .utf8)!
        mockFM.add(file: url.relativePath, contents: contents)
    }
}
