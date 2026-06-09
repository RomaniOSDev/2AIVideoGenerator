import Foundation
import UIKit

struct VideoGenerationRequest: Sendable {
    let prompt: String
    let model: AIModelOption
    let mode: GenerationMode
    let duration: Int
    let aspectRatio: VideoAspectRatio
    let imageData: Data?
    let imageFilename: String?
    let imageMimeType: String?
}

protocol WaveSpeedServiceProtocol: Sendable {
    func generateVideo(
        request: VideoGenerationRequest,
        onProgress: @Sendable @escaping (GenerationProgressUpdate) -> Void
    ) async throws -> URL
}

final class WaveSpeedService: WaveSpeedServiceProtocol, @unchecked Sendable {
    private let aiService: AIService

    init(aiService: AIService = AIService(mode: .live)) {
        self.aiService = aiService
    }

    func generateVideo(
        request: VideoGenerationRequest,
        onProgress: @Sendable @escaping (GenerationProgressUpdate) -> Void
    ) async throws -> URL {
        WaveSpeedLogger.info(
            "WaveSpeedService.generateVideo mode=\(request.mode) model=\(request.model.rawValue) " +
            "duration=\(request.duration)s aspect=\(request.aspectRatio.rawValue) " +
            "hasImage=\(request.imageData != nil) promptLen=\(request.prompt.count)"
        )
        let modelConfig = VideoModelRegistry.config(for: request.model, mode: request.mode)
        var uploads: [UploadInput] = []

        if request.mode == .imageToVideo {
            guard let imageData = request.imageData else {
                throw WaveSpeedError.predictionFailed("Image is required for image-to-video generation.")
            }
            uploads.append(
                UploadInput(
                    data: imageData,
                    filename: request.imageFilename ?? "input.jpg",
                    mimeType: request.imageMimeType ?? "image/jpeg"
                )
            )
        }

        let params = GenerationParams(
            prompt: request.prompt,
            duration: request.duration,
            aspectRatio: request.aspectRatio,
            resolution: request.model == .veo31Fast ? "1080p" : "720p",
            saveAudio: request.model == .veo31Fast ? nil : true,
            sound: request.model == .veo31Fast ? false : nil,
            qualityMode: request.model == .veo31Fast ? "std" : nil
        )

        return try await aiService.generateVideo(
            model: modelConfig,
            params: params,
            uploads: uploads,
            onProgress: onProgress
        )
    }
}
