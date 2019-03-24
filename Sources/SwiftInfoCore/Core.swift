import Foundation

public func extract<T: InfoProvider>(_ provider: T.Type) throws -> Output {
    do {
        let extracted = try provider.extract()
        let other = try FileUtils().lastOutput.extractedInfo(ofType: provider)
        let summary = extracted.summary(comparingWith: other)
        let info = ExtractedInfo(data: extracted, summary: summary)
        let dictionary = try info.encoded()
        return Output(rawDictionary: dictionary)
    } catch {
        print(error)
        throw error
    }
}

public func sendToSlack(output: Output) {
    print("slack")
}

public func save(output: Output) throws {
    let outputFile = FileUtils().outputJson
    try FileUtils().save(output: [output.rawDictionary] + outputFile)
}

public func fail(_ message: String) -> Never {
    fatalError(message)
}
