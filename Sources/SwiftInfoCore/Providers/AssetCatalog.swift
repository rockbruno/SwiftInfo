import Foundation

protocol FileProtocol {
    var name: String { get }
    var size: Int { get }
}

struct AssetCatalog: FileProtocol {
    let name: String
    let size: Int
    let largestInnerFile: File?
}

struct File: FileProtocol {
    let name: String
    let size: Int
}
