import Foundation

public struct SlackFormatter {

    public init() {}

    public func format(output: Output, projectInfo: ProjectInfo) -> (json: [String: Any], message: String) {
        let json = output.summaries.map { $0.slackDictionary }
        let prefix = "SwiftInfo results for \(projectInfo.description):"
        let errors = "\nErrors:\n\(output.errors.joined(separator: "\n"))"
        let title = prefix + (output.errors.isEmpty ? "" : errors)
        let description = output.summaries.map { $0.text }.joined(separator: "\n")
        let message = title + "\n" + description
        return (["text": title, "attachments": json], message)
    }
}
