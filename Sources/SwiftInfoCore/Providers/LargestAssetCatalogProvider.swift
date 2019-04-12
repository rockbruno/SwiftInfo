import Foundation

public struct LargestAssetCatalogProvider: InfoProvider {

    public struct Args {}
    public typealias Arguments = Args

    public static let identifier: String = "largest_asset_catalog_size"

    public let description: String = "Largest Asset Catalog"
    public let name: String
    public let size: Int

    public init(name: String, size: Int) {
        self.name = name
        self.size = size
    }

    public static func extract(fromApi api: SwiftInfo, args: Args?) throws -> LargestAssetCatalogProvider {
        let catalogs = TotalAssetCatalogsSizeProvider.allCatalogs(api: api)
        guard let largest = catalogs.max(by: { $0.size < $1.size }) else {
            fail("No Asset Catalogs were found!")
        }
        return LargestAssetCatalogProvider(name: largest.name, size: largest.size)
    }

    public func summary(comparingWith other: LargestAssetCatalogProvider?, args: Args?) -> Summary {
        func format(value: Int) -> String {
            return ByteCountFormatter.string(fromByteCount: Int64(value),
                                             countStyle: .file)
        }
        let formatted = format(value: size)
        var prefix = "🖼 Largest Asset Catalog: \(name) \(formatted)"
        let style: Summary.Style
        if let other = other, other.size != size {
            let otherFormatted = format(value: other.size)
            prefix += " - previously \(other.name) (\(otherFormatted))"
            style = other.size > size ? .positive : .negative
        } else {
            style = .neutral
        }
        return Summary(text: prefix, style: style)
    }
}
