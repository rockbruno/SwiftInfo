import Foundation

extension String {
    func insensitiveMatch(regex: String) -> [NSTextCheckingResult] {
        let regex = try! NSRegularExpression(pattern: regex, options: [.caseInsensitive])
        let nsString = self as NSString
        return regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
    }
}
