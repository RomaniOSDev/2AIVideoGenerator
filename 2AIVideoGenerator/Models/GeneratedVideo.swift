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

extension GeneratedVideo {
    static let previewPortrait = GeneratedVideo(
        id: UUID(uuidString: "A1000000-0000-4000-8000-000000000001")!,
        prompt: "A cinematic neon cyberpunk city at night with heavy rain",
        model: .runwayGen4,
        duration: 5,
        aspectRatio: .portrait,
        createdAt: Date(),
        hasWatermark: false,
        cardRotation: 0,
        videoReference: SampleVideoURLs.samples[0]
    )

    static let previewLandscape = GeneratedVideo(
        id: UUID(uuidString: "A1000000-0000-4000-8000-000000000002")!,
        prompt: "Ocean waves crashing on rocky cliffs at golden hour",
        model: .veo31Fast,
        duration: 8,
        aspectRatio: .landscape,
        createdAt: Date(),
        hasWatermark: true,
        cardRotation: 2,
        videoReference: SampleVideoURLs.samples[1]
    )

    static let previewSquare = GeneratedVideo(
        id: UUID(uuidString: "A1000000-0000-4000-8000-000000000003")!,
        prompt: "Abstract liquid metal shapes floating in space",
        model: .runwayGen4,
        duration: 3,
        aspectRatio: .square,
        createdAt: Date(),
        hasWatermark: false,
        cardRotation: -2,
        videoReference: SampleVideoURLs.samples[2]
    )
}
