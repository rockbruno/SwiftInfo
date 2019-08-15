import Foundation

extension String {
    func matchResults(regex: String, options: NSRegularExpression.Options = []) -> [NSTextCheckingResult] {
        let regex = try! NSRegularExpression(pattern: regex, options: options)
        let nsString = self as NSString
        return regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
    }

    func match(regex: String, options: NSRegularExpression.Options = []) -> [String] {
        return matchResults(regex: regex, options: options).map {
            String(self[Range($0.range, in: self)!])
        }
    }

    func insensitiveMatch(regex: String) -> [String] {
        return match(regex: regex, options: [.caseInsensitive])
    }
}

extension NSTextCheckingResult {
    func captureGroup(_ index: Int, originalString: String) -> String {
        let groupRange = range(at: index)
        let groupStartIndex = originalString.index(originalString.startIndex,
                                                   offsetBy: groupRange.location)
        let groupEndIndex = originalString.index(groupStartIndex,
                                                 offsetBy: groupRange.length)
        let substring = originalString[groupStartIndex..<groupEndIndex]
        return String(substring)
    }
}
