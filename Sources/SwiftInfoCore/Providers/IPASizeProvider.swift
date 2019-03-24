import Foundation

public struct IPASizeProvider: InfoProvider {

    public static let identifier: String = "ipa_size"

    public let description: String = ".ipa Size"
    public let size: Int
    public let friendlySize: String

    public init(size: Int, friendlySize: String) {
        self.size = size
        self.friendlySize = friendlySize
    }

    public static func extract() throws -> IPASizeProvider {
        guard let infofileFolder = FileUtils().infofileFolder() else {
            fail("Build folder not found!")
        }
        let buildFolder = infofileFolder + "build/"
        let contents = try FileManager.default.contentsOfDirectory(atPath: buildFolder)
        guard let ipa = contents.first(where: { $0.hasSuffix(".ipa") }) else {
            fail(".ipa not found!")
        }
        let attributes = try FileManager.default.attributesOfItem(atPath: buildFolder + ipa)
        let fileSize = Int(attributes[.size] as? UInt64 ?? 0)
        let friendlySize = convertToFileString(with: fileSize)
        return IPASizeProvider(size: fileSize, friendlySize: friendlySize)
    }

    static func convertToFileString(with size: Int) -> String {
        var convertedValue = Double(size)
        var multiplyFactor = 0
        let tokens = ["bytes", "KB", "MB", "GB", "TB", "PB",  "EB",  "ZB", "YB"]
        while convertedValue > 1000 {
            convertedValue /= 1000
            multiplyFactor += 1
        }
        return String(format: "%4.2f %@", convertedValue, tokens[multiplyFactor])
    }

    public func summary(comparingWith other: IPASizeProvider?) -> String {
        let regularMessage = ".ipa size: \(friendlySize)"
        guard let other = other else {
            return regularMessage
        }
        if size == other.size {
            return regularMessage
        }
        let difference = abs(other.size - size)
        let modifier = size > other.size ? "*grew*" : "was *reduced*"
        let friendlyDifference = IPASizeProvider.convertToFileString(with: difference)
        return ".ipa size \(modifier) by \(friendlyDifference) (\(friendlySize))"
    }
}
