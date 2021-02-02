import Foundation

public struct SlackFormatter {
    public init() {}

    public func format(output: Output, titlePrefix: String?, projectInfo: ProjectInfo) -> (json: [String: Any], message: String) {
        let errors = output.errors
        let errorMessage = errors.isEmpty ? "" : "\nErrors:\n\(errors.joined(separator: "\n"))"

        let title = (titlePrefix ?? "SwiftInfo results for ") + projectInfo.description + ":" + errorMessage
        let description = output.summaries.map { $0.text }.joined(separator: "\n")
        let message = title + "\n" + description

        let json = output.summaries.map { $0.slackDictionary }
        return (["text": title, "attachments": json], message)
    }
}
