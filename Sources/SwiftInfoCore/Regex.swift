import Foundation

extension String {
    func match(regex: String, options: NSRegularExpression.Options = []) -> [String] {
        let regex = try! NSRegularExpression(pattern: regex, options: options)
        let nsString = self as NSString
        return regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length)).map {
            String(self[Range($0.range, in: self)!])
        }
    }

    func insensitiveMatch(regex: String) -> [String] {
        return match(regex: regex, options: [.caseInsensitive])
    }
}
