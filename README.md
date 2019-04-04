# 📊 SwiftInfo

<img src="https://i.imgur.com/Y6z0xij.png">

[![GitHub release](https://img.shields.io/github/tag/rockbruno/SwiftInfo.svg)](https://github.com/rockbruno/SwiftInfo/releases)

SwiftInfo is a simple CLI tool that extracts, tracks and analyzes metrics that are useful for Swift apps. Besides the default tracking options that are shipped with the tool, you can customize SwiftInfo to track pretty much anything that can be conveyed in a simple `.swift` script.

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
| **🛏 TotalTestDurationProvider**        | The sum of the duration of all tests | Test logs |
| **🖼 LargestAssetCatalogProvider**        | The name and size of the largest asset catalog | Build logs |
| **🎨 TotalAssetCatalogsSizeProvider**        | The sum of the size of all asset catalogs | Build logs |

## Usage

SwiftInfo requires the raw logs of a succesful test/archive build combo to work, so it's better used as the last step of a CI pipeline. 

If you use Fastlane, you can easily expose the raw logs by adding `buildlog_path` to `scan` and `gym`. Here's a simple example of a Fastlane step that runs tests, submits an archive to TestFlight and runs SwiftInfo (be sure to edit the folder paths to what's being used by your project):

```ruby
desc "Submits a new beta build and runs SwiftInfo"
lane :beta do
  # Run tests, copying the raw logs to the project folder 
  scan(
    scheme: "MyScheme",
    buildlog_path: "./build/tests_log"
  )
    
  # Archive the app, copying the raw logs to the project folder 
  gym(
    workspace: "MyApp.xcworkspace",
    scheme: "Release",
    buildlog_path: "./build/build_log"
  )
 
  # Send to TestFlight
  pilot(
      skip_waiting_for_build_processing: true
  )

  # Run SwiftInfo
  sh("../Pods/SwiftInfo/swiftinfo")

  # Commit and push SwiftInfo's result
  sh("git add ../SwiftInfo-output/SwiftInfoOutput.json")
  sh("git commit -m \"[ci skip] Updating SwiftInfo Output JSON\"")
  push_to_git_remote
end
```

SwiftInfo itself is configured by creating a `Infofile.swift` file in your project's root. Here's an example Infofile that retrieves some data and sends it to Slack:

```swift
import SwiftInfoCore

FileUtils.buildLogFilePath = "./build/build_log/MyApp-MyConfig.log"
FileUtils.testLogFilePath = "./build/tests_log/MyApp-MyConfig.log"

let projectInfo = ProjectInfo(xcodeproj: "MyApp.xcodeproj",
                              target: "MyTarget",
                              configuration: "MyConfig")

let api = SwiftInfo(projectInfo: projectInfo)

let output = api.extract(IPASizeProvider.self)      +
             api.extract(WarningCountProvider.self) +
             api.extract(TestCountProvider.self)    +
             api.extract(TargetCountProvider.self)  +
             api.extract(CodeCoverageProvider.self)

// Send the results to Slack.
api.sendToSlack(output: output, webhookUrl: "YOUR_SLACK_WEBHOOK_HERE")

// Save the output to disk.
api.save(output: output)
```

You can see `SwiftInfo`'s properties and methods [here.](Sources/SwiftInfoCore/SwiftInfo.swift)

## Output

After successfully extracting data, SwiftInfo will add/update a json file in the `{Infofile path}/SwiftInfo-output` folder. It's important to add this file to version control after the running the tool as this is what SwiftInfo uses to compare new pieces of information.

Although you can't do anything with the output for now besides sending it to Slack, tools are being developed that allows you to convert this JSON to graphs inside a HTML page.

## Tracking custom info

If you wish to track something that's not handled by the default providers, you can create your own provider by creating a `struct` that [inherits from InfoProvider](Sources/SwiftInfoCore/InfoProvider.swift) inside your Infofile. Here's a simple provider that tracks the number of files in a project where adding new files is bad:

```swift
struct FileCountProvider: InfoProvider {
    static let identifier = "file_count"
    let description = "Number of files"

    let fileCount: Int

    static func extract(fromApi api: SwiftInfo) throws -> FileCountProvider {
        let count = // get the number of files in the project folder
        return FileCountProvider(fileCount: count)
    }

    // Given another instance of this provider, return a `Summary` that explains the difference between them.
    func summary(comparingWith other: FileCountProvider?) -> Summary {
        let prefix = "File Count"
        guard let other = other else {
            return Summary(text: prefix + ": \(count)", style: .neutral)
        }
        guard count != other.count else {
            return Summary(text: prefix + ": Unchanged. (\(count))", style: .neutral)
        }
        let modifier: String
        let style: Summary.Style
        if count > other.count {
            modifier = "*grew*"
            style = .negative
        } else {
            modifier = "was *reduced*"
            style = .positive
        }
        let difference = abs(other.count - count)
        let text = prefix + " \(modifier) by \(difference) (\(count))"
        return Summary(text: text, style: style)
    }
}
```

Documentation of useful types and methods from SwiftInfoCore that you can use when building custom providers will be available soon.

**If you end up creating a custom provider, consider submitting it here as a pull request to have it added as a default one!**

## Installation

### CocoaPods

`pod 'SwiftInfo'`

## License

SwiftInfo is released under the GNU GPL v3.0 license. See LICENSE for details.
