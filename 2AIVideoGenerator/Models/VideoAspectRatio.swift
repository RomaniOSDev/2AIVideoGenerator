import Foundation

enum VideoAspectRatio: String, CaseIterable, Identifiable, Codable {
    case portrait
    case landscape
    case square

    var id: String { rawValue }

    var title: String {
        switch self {
        case .portrait: L10n.aspectPortrait
        case .landscape: L10n.aspectLandscape
        case .square: L10n.aspectSquare
        }
    }

    var iconName: String {
        switch self {
        case .portrait: "rectangle.portrait"
        case .landscape: "rectangle"
        case .square: "square"
        }
    }

    var ratioLabel: String {
        switch self {
        case .portrait: "9:16"
        case .landscape: "16:9"
        case .square: "1:1"
        }
    }

    var displayRatio: CGFloat {
        switch self {
        case .portrait: 9 / 16
        case .landscape: 16 / 9
        case .square: 1
        }
    }
}
