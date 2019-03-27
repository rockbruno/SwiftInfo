import Foundation

public final class HTTPClient {

    let client = URLSession.shared
    let group = DispatchGroup()

    public init() {}

    public func syncPost(urlString: String, json: [String: Any]) {
        guard let url = URL(string: urlString) else {
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.allHTTPHeaderFields = ["Content-Type": "application/json"]
        let data = try! JSONSerialization.data(withJSONObject: json, options: [])
        request.httpBody = data
        group.enter()
        let task = client.dataTask(with: request) { [weak self] _, _, _ in
            self?.group.leave()
        }
        task.resume()
        group.wait()
    }
}
