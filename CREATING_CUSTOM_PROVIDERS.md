# Creating your own providers

If you wish to track something that's not handled by the default providers, you can create your own provider by creating a `struct` that inherits from `InfoProvider` inside your Infofile. Here's a simple provider that tracks the number of files in a project where adding new files is bad:

struct FileCountProvider: InfoProvider {

    struct Args {
        let fromFolders: [String]
    }

    typealias Arguments = Args

    static let identifier = "file_count"
    let description = "Number of files"

    let fileCount: Int

    static func extract(fromApi api: SwiftInfo, args: Args?) throws -> FileCountProvider {
        let count = // get the number of files from the provided `args?.fromFolders`
        return FileCountProvider(fileCount: count)
    }

    // Given another instance of this provider, return a `Summary` that explains the difference between them.
    func summary(comparingWith other: FileCountProvider?, args: Args?) -> Summary {
        let prefix = "File Count"
        guard let other = other else {
            return Summary(text: prefix + ": \(fileCount)", style: .neutral)
        }
        guard count != other.count else {
            return Summary(text: prefix + ": Unchanged. (\(fileCount))", style: .neutral)
        }
        let modifier: String
        let style: Summary.Style
        if fileCount > other.fileCount {
            modifier = "*grew*"
            style = .negative
        } else {
            modifier = "was *reduced*"
            style = .positive
        }
        let difference = abs(other.fileCount - fileCount)
        let text = prefix + " \(modifier) by \(difference) (\(fileCount))"
        return Summary(text: text, style: style, numericValue: Float(fileCount), stringValue: "\(fileCount) files")
    }
}

Check our docs page to see the capabilities of the `SwiftInfo` api.

**If you end up creating a custom provider, consider submitting it here as a pull request to have it added as a default one!**