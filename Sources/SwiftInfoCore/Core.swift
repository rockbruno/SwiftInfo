import Foundation

public struct SwiftInfo {
    public let fileUtils: FileUtils
    public let slackFormatter: SlackFormatter
    public let network: Network

    public init(fileUtils: FileUtils = .init(),
                slackFormatter: SlackFormatter = .init(),
                network: Network = Network.shared) {
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
        let formatted = slackFormatter.format(output: output)
        network.syncPost(urlString: webhookUrl, json: formatted)
    }

    public func save(output: Output) {
        print("Saving output to disk...")
        let outputFile = fileUtils.outputJson
        do {
            try fileUtils.save(output: [output.rawDictionary] + outputFile)
        } catch {
            fail(error.localizedDescription)
        }
    }
}

public func fail(_ message: String) -> Never {
    fatalError(message)
}
