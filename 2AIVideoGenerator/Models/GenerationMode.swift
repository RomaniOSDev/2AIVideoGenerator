import Foundation

enum GenerationMode: String, CaseIterable, Identifiable {
    case textToVideo
    case imageToVideo

    var id: String { rawValue }

    var title: String {
        switch self {
        case .textToVideo: L10n.createTextToVideo
        case .imageToVideo: L10n.createImageToVideo
        }
    }
}
