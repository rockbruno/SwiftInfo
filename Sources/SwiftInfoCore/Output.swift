import Foundation

public struct Output {
    let rawDictionary: [String: Any]

    func extractedInfo<T: InfoProvider>(ofType type: T.Type) throws -> T? {
        let json = rawDictionary[type.identifier] as? [String: Any] ?? [:]
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        let extractedInfo = try JSONDecoder().decode(ExtractedInfo<T>.self, from: data)
        return extractedInfo.data
    }

    public static func +(lhs: Output, rhs: Output) -> Output {
        let lhsDict = lhs.rawDictionary
        let rhsDict = rhs.rawDictionary
        let dict = lhsDict.merging(rhsDict) { new, _ in
            return new
        }
        return Output(rawDictionary: dict)
    }

    public static func +=(lhs: inout Output, rhs: Output) {
        lhs = lhs + rhs
    }
}
