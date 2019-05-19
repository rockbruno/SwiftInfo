# 📊 SwiftInfo

<img src="https://i.imgur.com/Y6z0xij.png">

[![GitHub release](https://img.shields.io/github/tag/rockbruno/SwiftInfo.svg)](https://github.com/rockbruno/SwiftInfo/releases)

SwiftInfo is a CLI tool that extracts, tracks and analyzes metrics that are useful for Swift apps. Besides the default tracking options that are shipped with the tool, you can also customize SwiftInfo to track pretty much anything that can be conveyed in a simple `.swift` script.

By default SwiftInfo will assume you're extracting info from a release build and send the final results to Slack, but it can be used to extract info from individual pull requests as well with the [danger-SwiftInfo](https://github.com/rockbruno/danger-SwiftInfo) [danger](https://github.com/danger/danger) plugin.

<img src="https://i.imgur.com/8kvEx5O.png">

## Available Providers

| **Type Name** | **Description** | **Requirements** |
|---|:---:|:---:|
| **📦 IPASizeProvider**        | Size of the .ipa archive (Not the App Store size!) | Successful xcodebuild archive and build logs |
| **📊 CodeCoverageProvider**        | Code coverage percentage | Test logs, Xcode developer tools, Test targets with code coverage reports enabled |
| **👶 TargetCountProvider**        | Number of targets (dependencies) | Build logs |
| **🎯 TestCountProvider**        | Sum of all test target's test count | Test logs |
| **⚠️ WarningCountProvider**        | Number of warnings in a build | Build logs |
| **🧙‍♂️ OBJCFileCountProvider**        | Number of OBJ-C files and headers (for mixed OBJ-C / Swift projects) | Build logs |
| **⏰ LongestTestDurationProvider**        | The name and duration of the longest test | Test logs |
| **🛏 TotalTestDurationProvider**        | Time it took to build and run all tests | Test logs |
| **🖼 LargestAssetCatalogProvider**        | The name and size of the largest asset catalog | Build logs |
| **🎨 TotalAssetCatalogsSizeProvider**        | The sum of the size of all asset catalogs | Build logs |
| **💻 LinesOfCodeProvider**        | Executable lines of code | Same as CodeCoverageProvider. |
| **🚚 ArchiveDurationProvider**        | Time it took to build and archive the app | Successful xcodebuild archive and build logs |
| **📷 LargestAssetProvider**        | The largest asset in the project. Only considers files inside asset catalogs. | Build logs |

## Usage

SwiftInfo extracts information by analyzing the logs that logs that Xcode generates when you build and/or test your app. Because it requires these logs to work, SwiftInfo is meant to be used alongside a build automation tool like [fastlane](https://github.com/fastlane/fastlane). The following topics describe how you can retrieve these logs and setup SwiftInfo itself.

We'll show how to get the logs first as you'll need them to configure SwiftInfo.

**Note:** This repository contains an example project. Check it out to see the tool in action!

### Retrieving raw logs with [fastlane](https://github.com/fastlane/fastlane)

If you use fastlane, you can expose the raw logs by adding the `buildlog_path` argument to `scan` (test logs) and `gym` (build logs). Here's a simple example of a fastlane step that runs tests, submits an archive to TestFlight and runs SwiftInfo (be sure to edit the folder paths to what's being used by your project):

```ruby
desc "Submits a new beta build and runs SwiftInfo"
lane :beta do
  # Run tests, copying the raw logs to the project folder
  scan(
    scheme: "MyScheme",
    buildlog_path: "./build/tests_log"
  )

  # Archive the app, copying the raw logs to the project folder and the .ipa to the /build folder
  gym(
    workspace: "MyApp.xcworkspace",
    scheme: "Release",
    output_directory: "build",
    buildlog_path: "./build/build_log"
  )

  # Send to TestFlight
  pilot(
      skip_waiting_for_build_processing: true
  )

  # Run SwiftInfo
  sh("../Pods/SwiftInfo/bin/swiftinfo")

  # Commit and push SwiftInfo's result
  sh("git add ../SwiftInfo-output/SwiftInfoOutput.json")
  sh("git commit -m \"[ci skip] Updating SwiftInfo Output JSON\"")
  push_to_git_remote
end
```

### Retrieving raw logs manually

An alternative that doesn't require fastlane is to simply manually run `xcodebuild` / `xctest` and pipe the output to a file. We don't recommend doing this in a real project, but it can be useful if you just want to test the tool without having to setup fastlane.

```
xcodebuild -workspace ./Example.xcworkspace -scheme Example &> ./build/build_log/Example-Release.log
```

## Configuring SwiftInfo

SwiftInfo itself is configured by creating a `Infofile.swift` file in your project's root. Here's an example one:

```swift
import SwiftInfoCore

// 1
FileUtils.buildLogFilePath = "./build/build_log/MyApp-MyConfig.log"
FileUtils.testLogFilePath = "./build/tests_log/MyApp-MyConfig.log"

// 2
let projectInfo = ProjectInfo(xcodeproj: "MyApp.xcodeproj",
                              target: "MyTarget",
                              configuration: "MyConfig")

let api = SwiftInfo(projectInfo: projectInfo)

// 3
let output = api.extract(IPASizeProvider.self) +
             api.extract(WarningCountProvider.self) +
             api.extract(TestCountProvider.self) +
             api.extract(TargetCountProvider.self, args: .init(mode: .complainOnRemovals)) +
             api.extract(CodeCoverageProvider.self, args: .init(targets: ["NetworkModule", "MyApp"])) +
             api.extract(LinesOfCodeProvider.self, args: .init(targets: ["NetworkModule", "MyApp"]))

// 4

if isInPullRequestMode {
    // If called from danger-SwiftInfo, print the results to the pull request
    api.print(output: output)
} else {
    // If called manually, send the results to Slack...
    api.sendToSlack(output: output, webhookUrl: url)
    // ...and save the output to your repo so it serves as the basis for new comparisons.
    api.save(output: output)
}
```

- 1: Use `FileUtils` to configure the path of your logs. If you're using fastlane and don't know what the name of the log files are going to be, just run it once to have it create them.
- 2: Create a `SwiftInfo` instance by passing your project's information.
- 3: Use `SwiftInfo`'s `extract()` to extract and append all the information you want into a single property.
- 4: Lastly, you can act upon this output. Here, I print the results to a pull request if [danger-SwiftInfo](https://github.com/rockbruno/danger-SwiftInfo) is being used, or send it to Slack / save it to the repo if this is the result of a release build.

You can see `SwiftInfo`'s properties and methods [here.](Sources/SwiftInfoCore/SwiftInfo.swift)

## Available Arguments

To be able to support different types of projects, SwiftInfo provides customization options to some providers. Click on each of them to see their documentation!

[👶 TargetCountProvider](Sources/SwiftInfoCore/Providers/TargetCountProvider.swift#L16)

[💻 LinesOfCodeProvider](Sources/SwiftInfoCore/Providers/LinesOfCodeProvider.swift#L11)

[📊 CodeCoverageProvider](Sources/SwiftInfoCore/Providers/CodeCoverageProvider.swift#L11)

## Output

After successfully extracting data, you can call `api.save(output: output)` to have SwiftInfo add/update a json file in the `{Infofile path}/SwiftInfo-output` folder. It's important to add this file to version control after the running the tool as this is what SwiftInfo uses to compare new pieces of information.

[SwiftInfo-Reader](https://github.com/rockbruno/SwiftInfo-Reader) can be used to transform this output into a more visual static HTML page.

<img src="https://i.imgur.com/62jNGdh.png">

## Tracking custom info

If you wish to track something that's not handled by the default providers, you can create your own provider by creating a `struct` that [inherits from InfoProvider](Sources/SwiftInfoCore/InfoProvider.swift) inside your Infofile. Here's a simple provider that tracks the number of files in a project where adding new files is bad:

```swift
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
```

Documentation of useful types and methods from SwiftInfoCore that you can use when building custom providers will be available soon.

**If you end up creating a custom provider, consider submitting it here as a pull request to have it added as a default one!**

## Installation

### [Homebrew](https://brew.sh/)

To install SwiftInfo the first time, simply run these commands:

```bash
brew tap rockbruno/SwiftInfo https://github.com/rockbruno/SwiftInfo.git
brew install rockbruno/SwiftInfo/swiftinfo
```

To **update** to the newest version of SwiftInfo when you have an old version already installed run:

```bash
brew upgrade swiftinfo
```

### CocoaPods

`pod 'SwiftInfo'`

### Manual

Download the [latest release](https://github.com/rockbruno/SwiftInfo/releases) and unzip the contents somewhere in your project's folder.

### Swift Package Manager

SwiftPM is currently not supported due to the need of shipping additional files with the binary, which SwiftPM does not support. We might find a solution for this, but for now there's no way to use the tool with it.

## License

SwiftInfo is released under the MIT license. See LICENSE for details.
