import Foundation

struct ExtractedInfo<T: InfoProvider>: Codable {
    let data: T
    let summary: Summary

    func encoded() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        return [T.identifier: json]
    }
}
