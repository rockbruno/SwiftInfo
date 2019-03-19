import Foundation

public func getInfoFrom(_ providers: InfoProvider...) throws -> Info {
    var dictionary = [String: Any]()
    for provider in providers {
        do {
            let providerInfo = try provider.run()
            let key = String(describing: type(of: provider))
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

public func save(info: Info) {
    print("bla")
}
