import Foundation

public struct TotalAssetCatalogsSizeProvider: InfoProvider {

    public static let identifier: String = "total_asset_catalogs_size"

    public let description: String = "Asset Catalogs Size"
    public let size: Int

    public init(size: Int) {
        self.size = size
    }

    public static func extract(fromApi api: SwiftInfo) throws -> TotalAssetCatalogsSizeProvider {
        let catalogs = allCatalogs(api: api)
        let total = catalogs.map { $0.size }.reduce(0, +)
        return AssetCatalogsSizeProvider(size: total)
    }

    public static func allCatalogs(api: SwiftInfo) -> [(name: String, size: Int)] {
        let buildLog = api.fileUtils.buildLog
        let compileRows = buildLog.match(regex: "CompileAssetCatalog.*")
        let catalogs: [String] = compileRows.compactMap {
            let formatted = $0.replacingEscapedSpaces
            let catalog = formatted.components(separatedBy: " ").last
            return catalog?.removingPlaceholder
        }
        let infofileFolder = api.fileUtils.infofileFolder
        let sizes = catalogs.map { folderSize(ofCatalog: infofileFolder + $0, api: api) }
        let result = zip(catalogs, sizes).map { ($0.0, $0.1) }
        return result
    }

    public static func folderSize(ofCatalog catalog: String, api: SwiftInfo) -> Int {
        let fileManager = api.fileUtils.fileManager
        let enumerator = fileManager.enumerator(atPath: catalog)
        var fileSize = 0
        while let next = enumerator?.nextObject() as? String {
            let attributes = try? fileManager.attributesOfItem(atPath: catalog + "/" + next)
            let size = Int(attributes?[.size] as? UInt64 ?? 0)
            fileSize += size
        }
        return fileSize
    }

    public func summary(comparingWith other: TotalAssetCatalogsSizeProvider?) -> Summary {
        let prefix = "🎨 Total Asset Catalogs Size"
        let formatter: ((Int) -> String) = { value in
            return ByteCountFormatter.string(fromByteCount: Int64(value),
                                             countStyle: .file)
        }
        return Summary.genericFor(prefix: prefix, now: size, old: other?.size, formatter: formatter) {
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
