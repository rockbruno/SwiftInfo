import Foundation

/// Size of the .ipa archive (not the App Store size!).
/// Requirements: .ipa available in the `#{PROJECT_DIR}/build` folder (or in another `PROJECT_DIR` subfolder provided as the `path` argument).
public struct IPASizeProvider: InfoProvider {
    public struct Args {
        /// The path to the folder containing the .ipa file.
        public let path: String

        public init(path: String) {
            self.path = path
        }
    }
    public typealias Arguments = Args

    public static let identifier: String = "ipa_size"

    public let description: String = "📦 Compressed App Size (.ipa)"
    public let size: Int

    public init(size: Int) {
        self.size = size
    }

    public static func extract(fromApi api: SwiftInfo, args: Args?) throws -> IPASizeProvider {
        let fileUtils = api.fileUtils
        let infofileFolder = try fileUtils.infofileFolder()
        let buildFolder = infofileFolder + (args?.path ?? "build/")
        let contents = try fileUtils.fileManager.contentsOfDirectory(atPath: buildFolder)
        guard let ipa = contents.first(where: { $0.hasSuffix(".ipa") }) else {
            throw error(".ipa not found! Attempted to find .ipa at: \(buildFolder)")
        }
        let attributes = try fileUtils.fileManager.attributesOfItem(atPath: buildFolder + ipa)
        let fileSize = Int(attributes[.size] as? UInt64 ?? 0)
        return IPASizeProvider(size: fileSize)
    }

    public func summary(comparingWith other: IPASizeProvider?, args _: Args?) -> Summary {
        let prefix = description
        let stringFormatter: ((Int) -> String) = { value in
            let formatter = ByteCountFormatter()
            formatter.allowsNonnumericFormatting = false
            formatter.countStyle = .file
            return formatter.string(fromByteCount: Int64(value))
        }
        return Summary.genericFor(prefix: prefix,
                                  now: size,
                                  old: other?.size,
                                  increaseIsBad: true,
                                  stringValueFormatter: stringFormatter)
    }
}
