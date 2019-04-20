import Foundation
import xcodeproj
import PathKit

public protocol PlistExtractor {
    func extractPlistPath(xcodeproj: String,
                          target: String,
                          configuration: String,
                          fileUtils: FileUtils) -> String
}

public struct XcodeprojPlistExtractor: PlistExtractor {

    public init() {}

    public func extractPlistPath(xcodeproj: String,
                                 target: String,
                                 configuration: String,
                                 fileUtils: FileUtils) -> String {
        do {
            let projectFolder = try fileUtils.infofileFolder()
            let fileManager = fileUtils.fileManager
            let contents = try fileManager.contentsOfDirectory(atPath: projectFolder)
            guard let project = contents.first(where: { $0.hasSuffix(xcodeproj) }) else {
                fail("Project file not found.")
            }
            guard let xcodeproj = try? XcodeProj(path: Path(projectFolder + project)) else {
                fail("Failed to load .pbxproj! (\(projectFolder + project))")
            }
            guard let pbxTarget = xcodeproj.pbxproj.targets(named: target).first else {
                fail("Target not found.")
            }
            let buildConfigs = pbxTarget.buildConfigurationList?.buildConfigurations
            let config = buildConfigs?.first { $0.name == configuration }
            guard let cfg = config else {
                fail("Config not found in .pbjproj!")
            }
            guard let plist = cfg.buildSettings["INFOPLIST_FILE"] as? String else {
                fail("Plist not found.")
            }
            return plist
        } catch {
            fail("ProjectInfo failed to resolve plist: \(error.localizedDescription)")
        }
    }
}
