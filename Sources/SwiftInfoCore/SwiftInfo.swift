import Foundation

/// The base API for SwiftInfo operations.
public struct SwiftInfo {
    /// The information about the current project.
    public let projectInfo: ProjectInfo

    /// Utilities for opening and saving files.
    public let fileUtils: FileUtils

    /// A HTTP Client that sends synchronous POST requests.
    public let client: HTTPClient

    /// An instance of SourceKit.
    public let sourceKit: SourceKit

    let slackFormatter: SlackFormatter

    public init(projectInfo: ProjectInfo,
                fileUtils: FileUtils = .init(),
                slackFormatter: SlackFormatter = .init(),
                client: HTTPClient = .init(),
                sourceKit: SourceKit? = nil) {
        self.projectInfo = projectInfo
        self.fileUtils = fileUtils
        self.slackFormatter = slackFormatter
        self.client = client
        if let sourceKit = sourceKit {
            self.sourceKit = sourceKit
        } else {
            let toolchain = UserDefaults.standard.string(forKey: "toolchain") ?? ""
            self.sourceKit = SourceKit(path: toolchain)
        }
    }

    /// Executes a provider with an optional set of additional arguments.
    ///
    /// - Parameters:
    ///    - provider: The provider metatype to execute.
    ///    - args: (Optional) The arguments to send to the provider, if applicable.
    ///
    /// - Returns: The output of this provider.
    public func extract<T: InfoProvider>(_ provider: T.Type,
                                         args: T.Arguments? = nil) -> Output {
        do {
            log("Extracting \(provider.identifier)")
            let extracted = try provider.extract(fromApi: self, args: args)
            log("\(provider.identifier): Parsing previously extracted info", verbose: true)
            let other = try fileUtils.lastOutput().extractedInfo(ofType: provider)
            log("\(provider.identifier): Comparing with previously extracted info", verbose: true)
            let summary = extracted.summary(comparingWith: other, args: args)
            log("\(provider.identifier): Finishing", verbose: true)
            let info = ExtractedInfo(data: extracted, summary: summary)
            return try Output(info: info)
        } catch {
            let message = "**\(provider.identifier):** \(error.localizedDescription)"
            log(message)
            return Output(rawDictionary: [:],
                          summaries: [],
                          errors: [message])
        }
    }

    /// Sends an output to slack.
    public func sendToSlack(output: Output, webhookUrl: String) {
        log("Sending to Slack")
        log("Slack Webhook: \(webhookUrl)", verbose: true)
        let formatted = slackFormatter.format(output: output, projectInfo: projectInfo)
        client.syncPost(urlString: webhookUrl, json: formatted.json)
    }

    /// Uses the SlackFormatter to format the output and print it.
    ///
    /// - Parameters:
    ///  - output: The output to print.
    public func print(output: Output) {
        let formatted = slackFormatter.format(output: output, projectInfo: projectInfo)
        // We print directly so that `log()`'s conditions don't interfere.
        // This is meant to be used with `danger-SwiftInfo` for printing to pull requests.
        Swift.print(formatted.message)
    }

    /// Saves the current output to the device.
    ///
    /// - Parameters:
    ///   - output: The output to save. The file will be saved as {Infofile path}/SwiftInfo-output.json.
    ///   - timestamp: (Optional) A custom timestamp for the output.
    public func save(output: Output,
                     timestamp: TimeInterval = Date().timeIntervalSince1970) {
        log("Saving output to disk")
        var dict = output.rawDictionary
        dict["swiftinfo_run_project_info"] = [
            "xcodeproj": projectInfo.xcodeproj,
            "target": projectInfo.target,
            "configuration": projectInfo.configuration,
            "versionString": (try? projectInfo.getVersionString()) ?? "(Failed to parse version)",
            "buildNumber": (try? projectInfo.getBuildNumber()) ?? "(Failed to parse build number)",
            "description": projectInfo.description,
            "timestamp": timestamp,
        ]
        do {
            let outputFile = try fileUtils.outputArray()
            try fileUtils.save(output: [dict] + outputFile)
        } catch {
            fail(error.localizedDescription)
        }
    }
}

/// Crashes SwiftInfo with a message.
public func fail(_ message: String) -> Never {
    print("SwiftInfo crashed. Reason: \(message)")
    exit(-1)
}
