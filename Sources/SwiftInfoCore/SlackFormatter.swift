import Foundation

public struct SlackFormatter {

    public init() {}

    public func format(output: Output) -> [String: Any] {
        print(output.summaries.map { $0.text }.joined(separator: "\n"))
        let data = try! JSONEncoder().encode(output.summaries)
        let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
        return ["text": "SwiftInfo results for MyApp 1.10.11:", "attachments": json]
    }
}
