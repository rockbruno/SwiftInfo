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
        let style = genericStyleFor(now, old)
        switch style {
        case .positive:
            modifier = ": *Increased* by"
        case .negative:
            modifier = ": *Reduced* by"
        case .neutral:
            modifier = ": Still at"
        }
        let diff = difference(now, old)
        let text = prefix + "\(modifier) \(formatter(diff)) (\(formatter(now)))"
        return Summary(text: text, style: style)
    }

    static func genericStyleFor<T: Comparable>(_ now: T, _ old: T) -> Style {
        if now > old {
            return .positive
        } else if now < old {
            return .negative
        } else {
            return .neutral
        }
    }
}
