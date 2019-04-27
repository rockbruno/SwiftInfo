import Foundation

public struct SlackFormatter {

    public init() {}

    public func format(output: Output, projectInfo: ProjectInfo) -> [String: Any] {
        let json = output.summaries.map { $0.slackDictionary }
        let prefix = "SwiftInfo results for \(projectInfo.description):"
        let errors = "\nErrors:\n\(output.errors.joined(separator: "\n"))"
        let text = prefix + (output.errors.isEmpty ? "" : errors)
        log(text, hasPrefix: false)
        log(output.summaries.map { $0.text }.joined(separator: "\n"), hasPrefix: false)
        return ["text": text, "attachments": json]
    }
}
