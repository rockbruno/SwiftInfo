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
                                          difference: ((T, T) -> T)) -> Summary {
        guard let old = old else {
            return Summary(text: prefix + ": \(now)", style: .neutral)
        }
        guard now != old else {
            return Summary(text: prefix + ": Unchanged. (\(now))", style: .neutral)
        }
        let modifier: String
        let style: Summary.Style
        if now > old {
            modifier = "*grew*"
            style = .positive
        } else {
            modifier = "was *reduced*"
            style = .negative
        }
        let text = prefix + " \(modifier) by \(difference(now, old)) (\(now))"
        return Summary(text: text, style: style)
    }
}
