import Foundation

public struct SwiftInfo {
    public let projectInfo: ProjectInfo
    public let fileUtils: FileUtils
    public let slackFormatter: SlackFormatter
    public let network: Network

    public init(projectInfo: ProjectInfo,
                fileUtils: FileUtils = .init(),
                slackFormatter: SlackFormatter = .init(),
                network: Network = Network.shared) {
        self.projectInfo = projectInfo
        self.fileUtils = fileUtils
        self.slackFormatter = slackFormatter
        self.network = network
    }

    public func extract<T: InfoProvider>(_ provider: T.Type) -> Output {
        do {
            print("Extracting \(provider.identifier)")
            let extracted = try provider.extract()
            let other = try fileUtils.lastOutput.extractedInfo(ofType: provider)
            let summary = extracted.summary(comparingWith: other)
            let info = ExtractedInfo(data: extracted, summary: summary)
            return try Output(info: info)
        } catch {
            fail(error.localizedDescription)
        }
    }

    public func sendToSlack(output: Output, webhookUrl: String) {
        print("Sending to slack...")
        let formatted = slackFormatter.format(output: output, projectInfo: projectInfo)
        network.syncPost(urlString: webhookUrl, json: formatted)
    }

    public func save(output: Output) {
        print("Saving output to disk...")
        let outputFile = fileUtils.outputJson
        var dict = output.rawDictionary
        dict["swiftinfo_run_description_key"] = projectInfo.description
        do {
            try fileUtils.save(output: [dict] + outputFile)
        } catch {
            fail(error.localizedDescription)
        }
    }
}

public func fail(_ message: String) -> Never {
    fatalError(message)
}
