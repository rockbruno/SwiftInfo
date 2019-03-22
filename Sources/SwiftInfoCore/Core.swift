import Foundation

public func getInfoFrom(_ providers: InfoProvider...) throws -> Info {
    var dictionary = [String: Any]()
    for provider in providers {
        do {
            let providerInfo = try provider.run()
            let key = String(describing: provider.description)
            dictionary[key] = providerInfo.dictionary
        } catch {
            print(error)
            throw error
        }
    }
    return Info(dictionary: dictionary)
}

public func sendToSlack(info: Info) {
    print("slack")
}

public func save(info: Info) throws {
    var outputFile = FileUtils().outputJson
    let array = outputFile["data"] as? [[String: Any]] ?? []
    outputFile["data"] = [info.dictionary] + array
    try FileUtils().save(output: outputFile)
    print("bla")
}
