import Foundation
import xcodeproj
import PathKit

public struct ProjectInfo: CustomStringConvertible {
    let xcodeproj: String
    let target: String
    let configuration: String
    let fileUtils: FileUtils
    let plistPath: String

    public var description: String {
        return "\(target) \(versionString()) (\(buildNumber())) - \(configuration)"
    }

    public init(xcodeproj: String,
                target: String,
                configuration: String,
                fileUtils: FileUtils = .init()) {
        self.xcodeproj = xcodeproj
        self.target = target
        self.configuration = configuration
        self.fileUtils = fileUtils
        func projectPlist() -> String {
            let projectFolder = fileUtils.infofileFolder()
            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: projectFolder)
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
        plistPath = projectPlist()
    }

    func plistDict() -> NSDictionary {
        let folder = fileUtils.infofileFolder()
        guard let dictionary = NSDictionary(contentsOfFile: folder + plistPath) else {
            fail("Failed to load plist \(folder + plistPath)")
        }
        return dictionary
    }

    func versionString() -> String {
        let plist = plistDict()
        guard let version = plist["CFBundleShortVersionString"] as? String else {
            fail("Project version not found.")
        }
        return version
    }

    func buildNumber() -> String {
        let plist = plistDict()
        guard let version = plist["CFBundleVersion"] as? String else {
            fail("Project build number not found.")
        }
        return version
    }
}
