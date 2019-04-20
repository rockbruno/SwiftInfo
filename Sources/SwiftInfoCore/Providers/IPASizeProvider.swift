import Foundation

public struct IPASizeProvider: InfoProvider {

    public struct Args {}
    public typealias Arguments = Args

    public static let identifier: String = "ipa_size"

    public let description: String = ".ipa Size"
    public let size: Int

    public init(size: Int) {
        self.size = size
    }

    public static func extract(fromApi api: SwiftInfo, args: Args?) throws -> IPASizeProvider {
        let fileUtils = api.fileUtils
        let infofileFolder = try fileUtils.infofileFolder()
        let buildFolder = infofileFolder + "build/"
        let contents = try fileUtils.fileManager.contentsOfDirectory(atPath: buildFolder)
        guard let ipa = contents.first(where: { $0.hasSuffix(".ipa") }) else {
            throw error(".ipa not found! Attempted to find .ipa at: \(buildFolder)")
        }
        let attributes = try fileUtils.fileManager.attributesOfItem(atPath: buildFolder + ipa)
        let fileSize = Int(attributes[.size] as? UInt64 ?? 0)
        return IPASizeProvider(size: fileSize)
    }

    public func summary(comparingWith other: IPASizeProvider?, args: Args?) -> Summary {
        let prefix = "📦 Compressed App Size (.ipa)"
        let formatter: ((Int) -> String) = { value in
            return ByteCountFormatter.string(fromByteCount: Int64(value),
                                             countStyle: .file)
        }
        return Summary.genericFor(prefix: prefix, now: size, old: other?.size, increaseIsBad: true, formatter: formatter) {
            return abs($1 - $0)
        }
    }
}
