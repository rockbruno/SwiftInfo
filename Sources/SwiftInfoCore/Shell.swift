import Foundation

public struct Shell {
    @discardableResult
    public func run(supressOutput: Bool = false, _ args: String...) -> String? {
        let task = Process()
        task.launchPath = "/bin/bash"
        task.arguments = ["-c", args.joined(separator: " ")]
        let pipe = Pipe()
        if supressOutput {
            task.standardOutput = pipe
        }
        task.launch()
        task.waitUntilExit()
        if supressOutput {
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            return String(data: data, encoding: .utf8)!
        } else {
            return nil
        }
    }

    public init() {}
}
