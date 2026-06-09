import Foundation

struct VideoModelConfig: Identifiable, Sendable {
    let id: String
    let displayName: String
    /// Path after `/api/v3/`, e.g. `pruna-ai/p-video/text-to-video`
    let endpointPath: String
    let buildRequest: @Sendable ([String], GenerationParams) -> WaveSpeedRequestBody
}

// MARK: - Pruna AI P-Video (text-to-video)

struct PrunaPVideoTextToVideoRequest: Sendable {
    let prompt: String
    let aspectRatio: String
    let duration: Int
    let resolution: String
    let saveAudio: Bool
    let seed: Int

    enum CodingKeys: String, CodingKey {
        case prompt, duration, seed, resolution
        case aspectRatio = "aspect_ratio"
        case saveAudio = "save_audio"
    }
}

extension PrunaPVideoTextToVideoRequest: Encodable {
    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(prompt, forKey: .prompt)
        try container.encode(aspectRatio, forKey: .aspectRatio)
        try container.encode(duration, forKey: .duration)
        try container.encode(resolution, forKey: .resolution)
        try container.encode(saveAudio, forKey: .saveAudio)
        try container.encode(seed, forKey: .seed)
    }
}

// MARK: - Pruna AI P-Video (image-to-video)

struct PrunaPVideoImageToVideoRequest: Sendable {
    let prompt: String
    let image: String
    let duration: Int
    let resolution: String
    let seed: Int
    let saveAudio: Bool

    enum CodingKeys: String, CodingKey {
        case prompt, image, duration, seed, resolution
        case saveAudio = "save_audio"
    }
}

extension PrunaPVideoImageToVideoRequest: Encodable {
    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(prompt, forKey: .prompt)
        try container.encode(image, forKey: .image)
        try container.encode(duration, forKey: .duration)
        try container.encode(resolution, forKey: .resolution)
        try container.encode(seed, forKey: .seed)
        try container.encode(saveAudio, forKey: .saveAudio)
    }
}

// MARK: - Skywork AI Skyreels v4 (text-to-video)

struct SkyreelsV4TextToVideoRequest: Sendable {
    let prompt: String
    let duration: Int
    let aspectRatio: String
    let resolution: String
    let sound: Bool
    let mode: String

    enum CodingKeys: String, CodingKey {
        case prompt, duration, resolution, sound, mode
        case aspectRatio = "aspect_ratio"
    }
}

extension SkyreelsV4TextToVideoRequest: Encodable {
    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(prompt, forKey: .prompt)
        try container.encode(duration, forKey: .duration)
        try container.encode(aspectRatio, forKey: .aspectRatio)
        try container.encode(resolution, forKey: .resolution)
        try container.encode(sound, forKey: .sound)
        try container.encode(mode, forKey: .mode)
    }
}

// MARK: - Skywork AI Skyreels v4 (reference-to-video)

struct SkyreelsV4ReferenceToVideoRequest: Sendable {
    let prompt: String
    let images: [String]?
    let aspectRatio: String
    let duration: Int
    let resolution: String
    let sound: Bool
    let mode: String

    enum CodingKeys: String, CodingKey {
        case prompt, images, duration, resolution, sound, mode
        case aspectRatio = "aspect_ratio"
    }
}

extension SkyreelsV4ReferenceToVideoRequest: Encodable {
    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(prompt, forKey: .prompt)
        if let images, !images.isEmpty {
            try container.encode(images, forKey: .images)
        }
        try container.encode(aspectRatio, forKey: .aspectRatio)
        try container.encode(duration, forKey: .duration)
        try container.encode(resolution, forKey: .resolution)
        try container.encode(sound, forKey: .sound)
        try container.encode(mode, forKey: .mode)
    }
}

enum VideoModelRegistry {
    static let prunaPVideo = VideoModelConfig(
        id: "pruna-p-video",
        displayName: "Pruna AI P-Video",
        endpointPath: "pruna-ai/p-video/text-to-video",
        buildRequest: { _, params in
            let body = PrunaPVideoTextToVideoRequest(
                prompt: params.prompt,
                aspectRatio: params.aspectRatioValue ?? "16:9",
                duration: params.duration ?? 5,
                resolution: params.resolution ?? WaveSpeedConfiguration.prunaVideoResolution,
                saveAudio: params.saveAudio ?? true,
                seed: params.seed ?? -1
            )
            return WaveSpeedRequestBody { try body.encode(to: $0) }
        }
    )

    static let prunaPVideoImageToVideo = VideoModelConfig(
        id: "pruna-p-video-image",
        displayName: "Pruna AI P-Video",
        endpointPath: "pruna-ai/p-video/image-to-video",
        buildRequest: { imageURLs, params in
            guard let imageURL = imageURLs.first, !imageURL.isEmpty else {
                fatalError("Image URL is required for Pruna P-Video image-to-video.")
            }

            let prompt = params.prompt.trimmingCharacters(in: .whitespacesAndNewlines)
            let body = PrunaPVideoImageToVideoRequest(
                prompt: prompt.isEmpty
                    ? "Smooth cinematic motion with natural lighting and camera movement"
                    : prompt,
                image: imageURL,
                duration: params.duration ?? 5,
                resolution: params.resolution ?? WaveSpeedConfiguration.prunaVideoResolution,
                seed: params.seed ?? -1,
                saveAudio: params.saveAudio ?? true
            )
            return WaveSpeedRequestBody { try body.encode(to: $0) }
        }
    )

    static let skyreelsV4TextToVideo = VideoModelConfig(
        id: "skyreels-v4-text",
        displayName: "Skywork AI Skyreels v4",
        endpointPath: "skywork-ai/skyreels-v4/text-to-video",
        buildRequest: { _, params in
            let prompt = params.prompt.trimmingCharacters(in: .whitespacesAndNewlines)
            let body = SkyreelsV4TextToVideoRequest(
                prompt: prompt.isEmpty
                    ? "A cinematic shot with soft natural lighting and smooth camera movement"
                    : prompt,
                duration: params.duration ?? 5,
                aspectRatio: params.aspectRatioValue ?? "16:9",
                resolution: params.resolution ?? WaveSpeedConfiguration.defaultVideoResolution,
                sound: params.sound ?? false,
                mode: params.qualityMode ?? "std"
            )
            return WaveSpeedRequestBody { try body.encode(to: $0) }
        }
    )

    static let skyreelsV4ReferenceToVideo = VideoModelConfig(
        id: "skyreels-v4-reference",
        displayName: "Skywork AI Skyreels v4",
        endpointPath: "skywork-ai/skyreels-v4/reference-to-video",
        buildRequest: { imageURLs, params in
            let prompt = params.prompt.trimmingCharacters(in: .whitespacesAndNewlines)
            let body = SkyreelsV4ReferenceToVideoRequest(
                prompt: prompt.isEmpty
                    ? "A cinematic shot with soft natural lighting and smooth camera movement"
                    : prompt,
                images: imageURLs.isEmpty ? nil : Array(imageURLs.prefix(3)),
                aspectRatio: params.aspectRatioValue ?? "16:9",
                duration: params.duration ?? 5,
                resolution: params.resolution ?? WaveSpeedConfiguration.defaultVideoResolution,
                sound: params.sound ?? false,
                mode: params.qualityMode ?? "std"
            )
            return WaveSpeedRequestBody { try body.encode(to: $0) }
        }
    )

    static func config(for model: AIModelOption, mode: GenerationMode) -> VideoModelConfig {
        switch model {
        case .runwayGen4, .runwayGen4Turbo:
            switch mode {
            case .textToVideo:
                prunaPVideo
            case .imageToVideo:
                prunaPVideoImageToVideo
            }
        case .veo31Fast:
            switch mode {
            case .textToVideo:
                skyreelsV4TextToVideo
            case .imageToVideo:
                skyreelsV4ReferenceToVideo
            }
        }
    }
}
