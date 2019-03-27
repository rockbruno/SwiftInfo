import Foundation
import SwiftInfoCore

public struct MockPlistExtractor: PlistExtractor {

    public init() {}

    public func extractPlistPath(xcodeproj: String,
                                 target: String,
                                 configuration: String,
                                 fileUtils: FileUtils) -> String {
        return "Info.plist"
    }
}

