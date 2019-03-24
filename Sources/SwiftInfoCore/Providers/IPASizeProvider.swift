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

    public func summary(comparingWith other: IPASizeProvider?) -> Summary {
        let prefix = "📦 .ipa size"
        guard let other = other else {
            return Summary(text: prefix + ": \(friendlySize)", style: .neutral)
        }
        guard size != other.size else {
            return Summary(text: prefix + ": Unchanged. (\(friendlySize))", style: .neutral)
        }
        let modifier: String
        let style: Summary.Style
        if size > other.size {
            modifier = "*grew*"
            style = .negative
        } else {
            modifier = "was *reduced*"
            style = .positive
        }
        let difference = abs(other.size - size)
        let friendlyDifference = IPASizeProvider.convertToFileString(with: difference)
        let text = prefix + " \(modifier) by \(friendlyDifference) (\(friendlySize))"
        return Summary(text: text, style: style)
    }
}
