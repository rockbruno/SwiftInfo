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
}
