# 📊 SwiftInfo

SwiftInfo is a simple CLI tool that extracts and analyzes useful metrics of Swift apps such as number of dependencies, `.ipa` size, number of tests, code coverage and much more. Besides the tracking options that are provided by default, you can customize SwiftInfo to track pretty much anything that can be conveyed in a simple `.swift` script.

## Usage

SwiftInfo requires the raw logs of a succesful test/archive build combo to work, so it's better used as the last step of a CI pipeline.
