import SwiftInfoCore
import Foundation

FileUtils.buildLogFilePath = "./build/build_log/SwiftInfoExample-SwiftInfoExample.log"
FileUtils.testLogFilePath = "./build/tests_log/SwiftInfoExample-SwiftInfoExample.log"

let projectInfo = ProjectInfo(xcodeproj: "SwiftInfoExample.xcodeproj",
                              target: "SwiftInfoExample",
                              configuration: "Release")

let api = SwiftInfo(projectInfo: projectInfo)

let output = api.extract(IPASizeProvider.self)                +
             api.extract(WarningCountProvider.self)           +
             api.extract(LargestAssetProvider.self)           +
             api.extract(TotalTestDurationProvider.self)      +
             api.extract(TestCountProvider.self)              +
             api.extract(CodeCoverageProvider.self)           +
             api.extract(LongestTestDurationProvider.self)    +
             api.extract(ArchiveDurationProvider.self)

//api.sendToSlack(output: output, webhookUrl: "slackUrlHere")
api.print(output: output)
api.save(output: output)
