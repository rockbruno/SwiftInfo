import Foundation

/// A `Summary` is a wrapper struct that represents the result of comparing two instances of a provider.
public struct Summary: Codable, Hashable {
    /// The sentimental result of a `Summary`.
    public enum Style {
        /// Indicates that the result was good.
        case positive
        /// Indicates that the result was neutral.
        case neutral
        /// Indicates that the result was bad.
        case negative

        /// The attributed hex color of this style.
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

    /// Creates a `Summary`.
    ///
    /// - Parameters:
    ///   - text: The description of this summary.
    ///   - style: The sentimental result of this summary. See `Summary.Style` for more information.
    ///   - numericValue: The numeric value that represents this summary, to be used in tools like SwiftInfo-Reader.
    ///   For example, if a build increased the number of tests by 3, `numericValue` should be 3.
    ///   - stringValue: The string value that represents this summary. For example,
    ///   if a build increased the number of tests by 3, `stringValue` can be either 3 or 'Three'. This is used only
    ///   for visual purposes.
    public init(text: String, style: Style, numericValue: Float, stringValue: String) {
        self.text = text
        color = style.hexColor
        self.numericValue = numericValue
        self.stringValue = stringValue
    }

    /// Creates a basic `Summary` that differs depending if a provider's value increased, decreased or stayed the same.
    /// Here's an example:
    /// Build Time: *Increased* by 3 (100 seconds)
    ///
    /// - Parameters:
    ///   - prefix: The prefix of the message. Ideally, this should be the description of your provider.
    ///   - now: The current numeric value of the provider.
    ///   - old: The previous numeric value of the provider.
    ///   - increaseIsBad: If set to true, increases in value will use the `.negative` `Summary.Style`.
    ///   - stringValueFormatter: (Optional) The closure that translates the numeric value to a visual string.
    ///   By default, the behavior is to simply cast the number to a String.
    ///   - numericValueFormatter: (Optional) The closure that translates the numeric value to a Float.
    ///   Float is the type used by reader tools like SwiftInfo-Reader, and by default, the behavior is to simply
    ///   convert the number to a Float.
    ///   - difference: (Optional) The closure that shows how to calculate the numerical difference between the providers.
    ///   The first argument is the **new** value, and the second is the **old** one.
    ///   By default, this closure is { abs(old - new) }.
    public static func genericFor<T: BinaryInteger & SignedNumeric>(
        prefix: String,
        now: T,
        old: T?,
        increaseIsBad: Bool,
        stringValueFormatter: ((T) -> String)? = nil,
        numericValueFormatter: ((T) -> Float)? = nil,
        difference: ((T, T) -> T)? = nil
    ) -> Summary {
        let stringFormatter = stringValueFormatter ?? { "\($0)" }
        let numberFormatter = numericValueFormatter ?? { Float($0) }
        let difference = difference ?? { abs($1 - $0) }
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
