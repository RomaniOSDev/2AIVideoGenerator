import Foundation

enum AIModelOption: String, CaseIterable, Identifiable, Codable {
    case runwayGen4
    case runwayGen4Turbo
    case veo31Fast

    var id: String { rawValue }

    static let homeModels: [AIModelOption] = [.runwayGen4, .veo31Fast]

    var title: String {
        switch self {
        case .runwayGen4: L10n.modelRunwayGen4
        case .runwayGen4Turbo: L10n.modelRunwayTurbo
        case .veo31Fast: L10n.modelVeo31
        }
    }

    var subtitle: String {
        switch self {
        case .runwayGen4: L10n.modelRunwayGen4Desc
        case .runwayGen4Turbo: L10n.modelRunwayTurboDesc
        case .veo31Fast: L10n.modelVeo31Desc
        }
    }

    var provider: VideoProvider {
        switch self {
        case .runwayGen4, .runwayGen4Turbo: .runway
        case .veo31Fast: .veo
        }
    }

    var badges: [String] {
        switch self {
        case .runwayGen4: [L10n.badgeHDAudio]
        case .runwayGen4Turbo: [L10n.badgeFast]
        case .veo31Fast: [L10n.badgeHD]
        }
    }
}
