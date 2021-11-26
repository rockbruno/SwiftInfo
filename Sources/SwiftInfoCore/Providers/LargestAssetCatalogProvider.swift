import Foundation

/// The name and size of the largest asset catalog.
/// Requirements: Build logs.
public struct LargestAssetCatalogProvider: InfoProvider {
    public struct Args {}
    public typealias Arguments = Args

    public static let identifier: String = "largest_asset_catalog_size"

    public var description: String { "🖼 Largest Asset Catalog" }
    public let name: String
    public let size: Int

    public init(name: String, size: Int) {
        self.name = name
        self.size = size
    }

    public static func extract(fromApi api: SwiftInfo, args _: Args?) throws -> LargestAssetCatalogProvider {
        let catalogs = try TotalAssetCatalogsSizeProvider.allCatalogs(api: api)
        guard let largest = catalogs.max(by: { $0.size < $1.size }) else {
            throw error("No Asset Catalogs were found!")
        }
        return LargestAssetCatalogProvider(name: largest.name, size: largest.size)
    }

    public func summary(comparingWith other: LargestAssetCatalogProvider?, args _: Args?) -> Summary {
        let stringFormatter: ((Int) -> String) = { value in
            let formatter = ByteCountFormatter()
            formatter.allowsNonnumericFormatting = false
            formatter.countStyle = .file
            return formatter.string(fromByteCount: Int64(value))
        }
        let formatted = stringFormatter(size)
        var prefix = "\(description): \(name) \(formatted)"
        let style: Summary.Style
        if let other = other, other.size != size {
            let otherFormatted = stringFormatter(other.size)
            prefix += " - previously \(other.name) (\(otherFormatted))"
            style = other.size > size ? .positive : .negative
        } else {
            style = .neutral
        }
        return Summary(text: prefix,
                       style: style,
                       numericValue: Float(size),
                       stringValue: "\(formatted) (\(name))")
    }
}
