import Foundation

/// The sum of the size of all asset catalogs.
/// Requirements: Build logs.
public struct TotalAssetCatalogsSizeProvider: InfoProvider {
    public struct Args {}
    public typealias Arguments = Args

    public static let identifier: String = "total_asset_catalogs_size"

    public var description: String { "🎨 Total Asset Catalogs Size" }
    public let size: Int

    public init(size: Int) {
        self.size = size
    }

    public static func extract(fromApi api: SwiftInfo, args _: Args?) throws -> TotalAssetCatalogsSizeProvider {
        let catalogs = try allCatalogs(api: api)
        let total = catalogs.map { $0.size }.reduce(0, +)
        return TotalAssetCatalogsSizeProvider(size: total)
    }

    static func allCatalogsPaths(api: SwiftInfo) throws -> [String] {
        let buildLog = try api.fileUtils.buildLog()
        let compileRows = buildLog.match(regex: "CompileAssetCatalog.*")
        let catalogs: [String] = compileRows.map { (row: String) -> [String] in
            let formatted: String = row.replacingEscapedSpaces
            let catalogs: [String] = formatted.components(separatedBy: " ").filter { $0.hasSuffix(".xcassets") }
            return catalogs.compactMap { $0.removingPlaceholder }
        }.flatMap { $0 }
        let uniqueCatalogs: [String] = Array(Set(catalogs))
        return uniqueCatalogs
    }

    static func allCatalogs(api: SwiftInfo) throws -> [AssetCatalog] {
        let catalogs = try allCatalogsPaths(api: api)
        let sizes = try catalogs.map { try folderSize(ofCatalog: $0, api: api) }
        let result = zip(catalogs, sizes).map { ($0.0, $0.1) }
        return result.map { AssetCatalog(name: $0.0, size: $0.1.0, largestInnerFile: $0.1.1) }
    }

    static func folderSize(ofCatalog catalog: String, api: SwiftInfo) throws -> (size: Int, largestInnerFile: File?) {
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
        var largestInnerFile: File?
        while let next = enumerator?.nextObject() as? String {
            let name = catalog + "/" + next
            let attributes = try fileManager.attributesOfItem(atPath: name)
            let size = Int(attributes[.size] as? UInt64 ?? 0)
            fileSize += size
            if size > (largestInnerFile?.size ?? 0) {
                largestInnerFile = File(name: name, size: size)
            }
        }
        return (fileSize, largestInnerFile)
    }

    public func summary(comparingWith other: TotalAssetCatalogsSizeProvider?, args _: Args?) -> Summary {
        let prefix = description
        let stringFormatter: ((Int) -> String) = { value in
            let formatter = ByteCountFormatter()
            formatter.allowsNonnumericFormatting = false
            formatter.countStyle = .file
            return formatter.string(fromByteCount: Int64(value))
        }
        return Summary.genericFor(prefix: prefix, now: size, old: other?.size, increaseIsBad: true, stringValueFormatter: stringFormatter)
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
