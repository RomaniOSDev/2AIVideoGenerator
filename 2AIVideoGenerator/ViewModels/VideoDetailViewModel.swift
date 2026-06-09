import Foundation

@MainActor
@Observable
final class VideoDetailViewModel {
    let video: GeneratedVideo

    var isSaving = false

    private let storageService: VideoStorageService

    var playbackURL: URL? { video.playbackURL }

    init(video: GeneratedVideo, storageService: VideoStorageService = .shared) {
        self.video = video
        self.storageService = storageService
    }

    func saveToPhotos() async throws {
        guard let playbackURL else {
            throw VideoStorageError.fileNotFound
        }

        isSaving = true
        defer { isSaving = false }

        let fileURL = try await storageService.resolvedFileURL(for: playbackURL)
        try await storageService.saveToPhotoLibrary(fileURL: fileURL)
    }
}
