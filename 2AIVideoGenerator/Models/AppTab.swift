import Foundation

enum AppTab: Int, CaseIterable, Identifiable {
    case create
    case gallery
    case subscription

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .create: L10n.tabCreate
        case .gallery: L10n.tabGallery
        case .subscription: L10n.tabSubscription
        }
    }

    var iconName: String {
        switch self {
        case .create: "wand.and.stars"
        case .gallery: "play.rectangle.on.rectangle"
        case .subscription: "crown.fill"
        }
    }
}
