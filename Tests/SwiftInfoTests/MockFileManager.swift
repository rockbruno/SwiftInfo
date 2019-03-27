import Foundation

final class MockFileManager: FileManager {

    private(set) var files = [String: String]()
    private(set) var plists = [String: NSDictionary]()
    private(set) var attributes = [String: [FileAttributeKey : Any]]()
    var createdDicts = Set<String>()

    func dataContents(atPath path: String) -> Data? {
        guard let file = stringContents(atPath: path) else {
            return nil
        }
        return file.data(using: .utf8)!
    }

    override func contentsOfDirectory(atPath path: String) throws -> [String] {
        return files.filter { $0.key.hasPrefix(path) }
                    .compactMap { $0.key.components(separatedBy: path).last }
    }

    override func attributesOfItem(atPath path: String) throws -> [FileAttributeKey : Any] {
        return attributes[path] ?? [:]
    }

    func stringContents(atPath path: String) -> String? {
        return files[path]
    }

    func plistContents(atPath path: String) -> NSDictionary? {
        return plists[path]
    }

    func add(file: String, contents: String) {
        files[file] = contents
    }

    func add(plist: NSDictionary, file: String) {
        plists[file] = plist
    }


    func add(attributes: [FileAttributeKey: Any], file: String) {
        self.attributes[file] = attributes
    }

    override func fileExists(atPath path: String) -> Bool {
        return files[path] != nil
    }

    override func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]? = nil) throws {
        createdDicts.insert(path)
    }
}
