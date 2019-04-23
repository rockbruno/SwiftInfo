import Foundation

public struct Summary: Codable, Hashable {

    public enum Style {
        case positive
        case neutral
        case negative

        var hexColor: String {
            switch self {
            case .positive:
                return "#36a64f"
            case .neutral:
                return "#757575"
            case .negative:
                return "#c41919"
            }
        }
    }

    /// The descriptive result of this summary.
    let text: String
    /// A hex value that represents the result of this summary.
    let color: String
    /// The numeric value that represents this summary, to be used in tools like SwiftInfo-Reader.
    let numericValue: Float
    /// The string value that represents this summary, to be used in tools like SwiftInfo-Reader.
    let stringValue: String

    var slackDictionary: [String: Any] {
        return ["text": text, "color": color]
    }

    public init(text: String, style: Style, numericValue: Float, stringValue: String) {
        self.text = text
        self.color = style.hexColor
        self.numericValue = numericValue
        self.stringValue = stringValue
    }

    static func genericFor<T: BinaryInteger>(prefix: String,
                                             now: T,
                                             old: T?,
                                             increaseIsBad: Bool,
                                             stringValueFormatter: ((T) -> String)? = nil,
                                             numericValueFormatter: ((T) -> Float)? = nil,
                                             difference: ((T, T) -> T))
                                             -> Summary {
        let stringFormatter = stringValueFormatter ?? { return "\($0)" }
        let numberFormatter = numericValueFormatter ?? { Float($0) }
        func result(text: String, style: Style) -> Summary {
            return Summary(text: text,
                           style: style,
                           numericValue: numberFormatter(now),
                           stringValue: stringFormatter(now))
        }
        guard let old = old else {
            return result(text: prefix + ": \(stringFormatter(now))", style: .neutral)
        }
        guard now != old else {
            return result(text: prefix + ": Still at \(stringFormatter(now))", style: .neutral)
        }
        let modifier: String
        let style: Style
        if now > old {
            modifier = ": *Increased* by"
            style = increaseIsBad ? .negative : .positive
        } else if now < old {
            modifier = ": *Reduced* by"
            style = increaseIsBad ? .positive : .negative
        } else {
            modifier = ": Still at"
            style = .neutral
        }
        let diff = difference(now, old)
        let text = prefix + "\(modifier) \(stringFormatter(diff)) (\(stringFormatter(now)))"
        return result(text: text, style: style)
    }
}
