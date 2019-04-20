import Foundation

public struct TotalAssetCatalogsSizeProvider: InfoProvider {

    public struct Args {}
    public typealias Arguments = Args

    public static let identifier: String = "total_asset_catalogs_size"

    public let description: String = "Asset Catalogs Size"
    public let size: Int

    public init(size: Int) {
        self.size = size
    }

    public static func extract(fromApi api: SwiftInfo, args: Args?) throws -> TotalAssetCatalogsSizeProvider {
        let catalogs = try allCatalogs(api: api)
        let total = catalogs.map { $0.size }.reduce(0, +)
        return TotalAssetCatalogsSizeProvider(size: total)
    }

    public static func allCatalogs(api: SwiftInfo) throws -> [(name: String, size: Int)] {
        let buildLog = try api.fileUtils.buildLog()
        let compileRows = buildLog.match(regex: "CompileAssetCatalog.*")
        let catalogs: [String] = compileRows.compactMap {
            let formatted = $0.replacingEscapedSpaces
            let catalog = formatted.components(separatedBy: " ").first {
                $0.hasSuffix(".xcassets")
            }
            return catalog?.removingPlaceholder
        }
        let sizes = try catalogs.map { try folderSize(ofCatalog: $0, api: api) }
        let result = zip(catalogs, sizes).map { ($0.0, $0.1) }
        return result
    }

    public static func folderSize(ofCatalog catalog: String, api: SwiftInfo) throws -> Int {
        let fileManager = api.fileUtils.fileManager
        let enumerator: FileManager.DirectoryEnumerator?
        if fileManager.enumerator(atPath: catalog)?.nextObject() == nil {
            // Xcode's new build system
            let infofileFolder = try api.fileUtils.infofileFolder()
            enumerator = fileManager.enumerator(atPath: infofileFolder + catalog)
        } else {
            // Legacy build
            enumerator = fileManager.enumerator(atPath: catalog)
        }
        var fileSize = 0
        while let next = enumerator?.nextObject() as? String {
            let attributes = try fileManager.attributesOfItem(atPath: catalog + "/" + next)
            let size = Int(attributes[.size] as? UInt64 ?? 0)
            fileSize += size
        }
        return fileSize
    }

    public func summary(comparingWith other: TotalAssetCatalogsSizeProvider?, args: Args?) -> Summary {
        let prefix = "🎨 Total Asset Catalogs Size"
        let formatter: ((Int) -> String) = { value in
            return ByteCountFormatter.string(fromByteCount: Int64(value),
                                             countStyle: .file)
        }
        return Summary.genericFor(prefix: prefix, now: size, old: other?.size, increaseIsBad: true, formatter: formatter) {
            return abs($1 - $0)
        }
    }
}

extension String {
    private var spacedFolderPlaceholder: String {
        return "\u{0}"
    }

    var replacingEscapedSpaces: String {
        return replacingOccurrences(of: "\\ ", with: spacedFolderPlaceholder)
    }

    var removingPlaceholder: String {
        return replacingOccurrences(of: spacedFolderPlaceholder, with: " ")
    }
}
