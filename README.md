# 📊 SwiftInfo

<img src="https://i.imgur.com/Y6z0xij.png">

[![GitHub release](https://img.shields.io/github/tag/rockbruno/SwiftInfo.svg)](https://github.com/rockbruno/SwiftInfo/releases)

SwiftInfo is a CLI tool that extracts, tracks and analyzes metrics that are useful for Swift apps. Besides the default tracking options that are shipped with the tool, you can also customize SwiftInfo to track pretty much anything that can be conveyed in a simple `.swift` script.

By default SwiftInfo will assume you're extracting info from a release build and send the final results to Slack, but it can be used to extract info from individual pull requests as well with the [danger-SwiftInfo](https://github.com/rockbruno/danger-SwiftInfo) [danger](https://github.com/danger/danger) plugin.

<img src="https://i.imgur.com/8kvEx5O.png">

## Available Providers

| **Type Name** | **Description** |
|---|:---:|
| **📦 IPASizeProvider**        | Size of the .ipa archive (not the App Store size!) |
| **📊 CodeCoverageProvider**        | Code coverage percentage |
| **👶 TargetCountProvider**        | Number of targets (dependencies) |
| **🎯 TestCountProvider**        | Sum of all test target's test count |
| **⚠️ WarningCountProvider**        | Number of warnings in a build |
| **🧙‍♂️ OBJCFileCountProvider**        | Number of OBJ-C files and headers (for mixed OBJ-C / Swift projects) |
| **⏰ LongestTestDurationProvider**        | The name and duration of the longest test |
| **🛏 TotalTestDurationProvider**        | Time it took to build and run all tests |
| **🖼 LargestAssetCatalogProvider**        | The name and size of the largest asset catalog |
| **🎨 TotalAssetCatalogsSizeProvider**        | The sum of the size of all asset catalogs |
| **💻 LinesOfCodeProvider**        | Executable lines of code |
| **🚚 ArchiveDurationProvider**        | Time it took to build and archive the app |
| **📷 LargestAssetProvider**        | The largest asset in the project. Only considers files inside asset catalogs. |

Each provider may have a specific set of requirements in order for them to work. [Check their documentation to learn more](https://rockbruno.github.io/SwiftInfo/Structs.html).

## Usage

SwiftInfo extracts information by analyzing the logs that your build system generates when you build and/or test your app. Because it requires these logs to work, SwiftInfo is meant to be used alongside a build automation tool like [fastlane](https://github.com/fastlane/fastlane). The following topics describe how you can retrieve these logs and setup SwiftInfo itself.

We'll show how to get the logs first as you'll need them to configure SwiftInfo.

**Note:** This repository contains an example project. Check it out to see the tool in action -- just go to the example project folder and run `make swiftinfo` in your terminal.	

### Retrieving raw logs with [fastlane](https://github.com/fastlane/fastlane)

If you use fastlane, you can expose raw logs to SwiftInfo by adding the `buildlog_path` argument to `scan` (test logs) and `gym` (build logs). Here's a simple example of a fastlane lane that runs tests, submits an archive to TestFlight and runs SwiftInfo (make sure to edit the folder paths to what's being used by your project):

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

  # Run the CocoaPods version of SwiftInfo
  sh("../Pods/SwiftInfo/bin/swiftinfo")

  # Commit and push SwiftInfo's output
  sh("git add ../SwiftInfo-output/SwiftInfoOutput.json")
  sh("git commit -m \"[ci skip] Updating SwiftInfo Output JSON\"")
  push_to_git_remote
end
```

### Retrieving raw logs manually

An alternative that doesn't require fastlane is to simply manually run `xcodebuild` / `xctest` and pipe the output to a file. We don't recommend doing this in a real project, but it can be useful if you just want to test the tool without having to setup fastlane.

```
xcodebuild -workspace ./Example.xcworkspace -scheme Example 2>&1 | tee ./build/build_log/Example-Release.log
```

## Configuring SwiftInfo

SwiftInfo itself is configured by creating a `Infofile.swift` file in your project's root. Here's an example one with a detailed explanation:

```swift
import SwiftInfoCore

// Use `FileUtils` to configure the path of your logs. 
// If you're retrieving them with fastlane and don't know what the name of the log files are going to be, 
// just run it once to have it create them.

FileUtils.buildLogFilePath = "./build/build_log/MyApp-MyConfig.log"
FileUtils.testLogFilePath = "./build/tests_log/MyApp-MyConfig.log"

// Now, create a `SwiftInfo` instance by passing your project's information.

let projectInfo = ProjectInfo(xcodeproj: "MyApp.xcodeproj",
                              target: "MyTarget",
                              configuration: "MyConfig")

let api = SwiftInfo(projectInfo: projectInfo)

// Use SwiftInfo's `extract()` method to extract and append all the information you want into a single property.

let output = api.extract(IPASizeProvider.self) +
             api.extract(WarningCountProvider.self) +
             api.extract(TestCountProvider.self) +
             api.extract(TargetCountProvider.self, args: .init(mode: .complainOnRemovals)) +
             api.extract(CodeCoverageProvider.self, args: .init(targets: ["NetworkModule", "MyApp"])) +
             api.extract(LinesOfCodeProvider.self, args: .init(targets: ["NetworkModule", "MyApp"]))

// Lastly, process the output.

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

## Saving and visualizing the data

After successfully extracting data, you should call `api.save(output: output)` to have SwiftInfo add/update a json file in the `{Infofile path}/SwiftInfo-output` folder. It's important to add this file to version control after the running the tool as this is what SwiftInfo uses to compare new pieces of information.

You can then use [SwiftInfo-Reader](https://github.com/rockbruno/SwiftInfo-Reader) to transform this output into a more visual static HTML page.

<img src="https://i.imgur.com/62jNGdh.png">

## Customizing Providers

To be able to support different types of projects, SwiftInfo provides customization options to some providers. See the documentation for each provider to see what it supports.
If you wish to track something that's not handled by the default providers, you can also create your own providers. [Click here to see how](CREATING_CUSTOM_PROVIDERS.md).

## Customizing Runs

Any arguments you pass to SwiftInfo can be inspected inside your Infofile. This allows you to pass any custom information you want to the binary and use it to customize your runs.

For example, if you run SwiftInfo by calling `swiftinfo --myCustomArgument`, you can use `ProcessInfo` to check for its presence inside your Infofile.

```swift
if ProcessInfo.processInfo.arguments.contains("--myCustomArgument") {
    print("Yay, custom arguments!")
}
```

If the argument has a value, you can also fetch that value with `UserDefaults`.

## Installation

### CocoaPods

`pod 'SwiftInfo'`

### [Homebrew](https://brew.sh/)

To install SwiftInfo with Homebrew the first time, simply run these commands:

```bash
brew tap rockbruno/SwiftInfo https://github.com/rockbruno/SwiftInfo.git
brew install rockbruno/SwiftInfo/swiftinfo
```

To **update** to the newest Homebrew version of SwiftInfo when you have an old version already installed, run:

```bash
brew upgrade swiftinfo
```

### Manually

Download the [latest release](https://github.com/rockbruno/SwiftInfo/releases) and unzip the contents somewhere in your project's folder.

### Swift Package Manager

SwiftPM is currently not supported due to the need of shipping additional files with the binary, which SwiftPM does not support. We might find a solution for this, but for now there's no way to use the tool with it.
