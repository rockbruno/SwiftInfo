import Foundation

public struct Output {
    let rawDictionary: [String: Any]
    let summaries: [Summary]
    let errors: [String]

    init<T: InfoProvider>(info: ExtractedInfo<T>) throws {
        self.rawDictionary = try info.encoded()
        self.summaries = [info.summary]
        self.errors = []
    }

    func extractedInfo<T: InfoProvider>(ofType type: T.Type) throws -> T? {
        let json = rawDictionary[type.identifier] as? [String: Any] ?? [:]
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: []) else {
            return nil
        }
        let extractedInfo = try? JSONDecoder().decode(ExtractedInfo<T>.self, from: data)
        return extractedInfo?.data
    }
}

extension Output {
    public static func +(lhs: Output, rhs: Output) -> Output {
        let lhsDict = lhs.rawDictionary
        let rhsDict = rhs.rawDictionary
        let dict = lhsDict.merging(rhsDict) { new, _ in
            return new
        }
        return Output(rawDictionary: dict,
                      summaries: lhs.summaries + rhs.summaries,
                      errors: lhs.errors + rhs.errors)
    }

    public static func +=(lhs: inout Output, rhs: Output) {
        lhs = lhs + rhs
    }

    public init(rawDictionary: [String: Any], summaries: [Summary], errors: [String]) {
        self.rawDictionary = rawDictionary
        self.summaries = summaries
        self.errors = errors
    }
}
