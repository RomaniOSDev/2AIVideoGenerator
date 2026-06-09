import Foundation

struct GenerationParams: Sendable {
    var prompt: String
    var imageURLs: [String]?
    var videoURL: String?
    var duration: Int?
    var aspectRatio: VideoAspectRatio?
    var resolution: String?
    var saveAudio: Bool?
    var sound: Bool?
    var qualityMode: String?
    var seed: Int?

    init(
        prompt: String,
        imageURLs: [String]? = nil,
        videoURL: String? = nil,
        duration: Int? = nil,
        aspectRatio: VideoAspectRatio? = nil,
        resolution: String? = nil,
        saveAudio: Bool? = nil,
        sound: Bool? = nil,
        qualityMode: String? = nil,
        seed: Int? = nil
    ) {
        self.prompt = prompt
        self.imageURLs = imageURLs
        self.videoURL = videoURL
        self.duration = duration
        self.aspectRatio = aspectRatio
        self.resolution = resolution
        self.saveAudio = saveAudio
        self.sound = sound
        self.qualityMode = qualityMode
        self.seed = seed
    }

    var aspectRatioValue: String? {
        aspectRatio?.apiValue
    }
}

private extension VideoAspectRatio {
    var apiValue: String {
        switch self {
        case .portrait: "9:16"
        case .landscape: "16:9"
        case .square: "1:1"
        }
    }
}
