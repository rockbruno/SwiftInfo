import Foundation

final class MockFileManager: FileManager {

    private(set) var files = [String: String]()
    var createdDicts = Set<String>()

    func dataContents(atPath path: String) -> Data? {
        guard let file = stringContents(atPath: path) else {
            return nil
        }
        return file.data(using: .utf8)!
    }

    func stringContents(atPath path: String) -> String? {
        return files[path]
    }

    func add(file: String, contents: String) {
        files[file] = contents
    }

    override func fileExists(atPath path: String) -> Bool {
        return files[path] != nil
    }

    override func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]? = nil) throws {
        createdDicts.insert(path)
    }
}
