import Foundation

struct GeneratedVideo: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let prompt: String
    let model: AIModelOption
    let duration: Int
    let aspectRatio: VideoAspectRatio
    let createdAt: Date
    let hasWatermark: Bool
    let cardRotation: Double
    /// Remote URL or local filename in `VideoStorageService`.
    let videoReference: String?

    var provider: VideoProvider { model.provider }

    var durationLabel: String {
        "\(duration) \(L10n.createSeconds)"
    }

    var playbackURL: URL? {
        guard let videoReference else { return nil }
        return VideoStorageService.shared.playbackURL(for: videoReference)
    }

    var isLocalFile: Bool {
        guard let videoReference else { return false }
        return !videoReference.hasPrefix("http://") && !videoReference.hasPrefix("https://")
    }
}
