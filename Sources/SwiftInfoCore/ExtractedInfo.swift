import Foundation

struct ExtractedInfo<T: InfoProvider>: Codable {
    let data: T
    let summary: Summary?

    init(data: T, summary: Summary?) {
        self.data = data
        self.summary = summary
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        data = try values.decode(T.self, forKey: .data)
        summary = try? values.decode(Summary.self, forKey: .summary)
    }

    func encoded() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
        return [T.identifier: json]
    }
}
