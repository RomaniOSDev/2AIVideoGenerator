import Foundation

enum VideoProvider: String, CaseIterable, Identifiable, Codable {
    case runway
    case veo

    var id: String { rawValue }

    var title: String {
        switch self {
        case .runway: L10n.providerRunway
        case .veo: L10n.providerVeo
        }
    }
}
