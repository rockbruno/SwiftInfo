import Foundation

/// The largest asset in the project. Only considers files inside asset catalogs.
/// Requirements: Build logs.
public struct LargestAssetProvider: InfoProvider {
    public struct Args {}
    public typealias Arguments = Args

    public static let identifier: String = "largest_asset"

    public var description: String { "📷 Largest Asset" }

    public let name: String
    public let size: Int

    public init(name: String, size: Int) {
        self.name = name
        self.size = size
    }

    public static func extract(fromApi api: SwiftInfo, args _: Args?) throws -> LargestAssetProvider {
        let catalogs = try TotalAssetCatalogsSizeProvider.allCatalogs(api: api)
        let files = catalogs.compactMap { $0.largestInnerFile }
        guard let maxFile = files.max(by: { $0.size < $1.size }) else {
            throw error("Can't find the largest asset because no assets were found.")
        }
        return LargestAssetProvider(name: maxFile.name, size: maxFile.size)
    }

    public func summary(comparingWith other: LargestAssetProvider?, args _: Args?) -> Summary {
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
            style = size < other.size ? .positive : .negative
        } else {
            style = .neutral
        }
        return Summary(text: prefix,
                       style: style,
                       numericValue: Float(size),
                       stringValue: "\(formatted) (\(name))")
    }
}
