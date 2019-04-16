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

    let text: String
    let color: String

    public init(text: String, style: Style) {
        self.text = text
        self.color = style.hexColor
    }

    static func genericFor<T: Comparable>(prefix: String,
                                          now: T,
                                          old: T?,
                                          increaseIsBad: Bool,
                                          formatter: ((T) -> String)? = nil,
                                          difference: ((T, T) -> T)) -> Summary {
        let formatter = formatter ?? { return "\($0)" }
        guard let old = old else {
            return Summary(text: prefix + ": \(formatter(now))", style: .neutral)
        }
        guard now != old else {
            return Summary(text: prefix + ": Still at \(formatter(now))",
                           style: .neutral)
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
        let text = prefix + "\(modifier) \(formatter(diff)) (\(formatter(now)))"
        return Summary(text: text, style: style)
    }
}
