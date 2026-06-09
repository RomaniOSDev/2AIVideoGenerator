import Foundation
import Photos

enum VideoStorageError: LocalizedError {
    case photoAccessDenied
    case fileNotFound

    var errorDescription: String? {
        switch self {
        case .photoAccessDenied: L10n.videoSaveAccessDenied
        case .fileNotFound: L10n.videoUnavailable
        }
    }
}

final class VideoStorageService {
    static let shared = VideoStorageService()

    private let directoryName = "GeneratedVideos"

    private init() {}

    var directoryURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(directoryName, isDirectory: true)
    }

    func fileURL(for fileName: String) -> URL {
        directoryURL.appendingPathComponent(fileName)
    }

    func playbackURL(for reference: String) -> URL? {
        if reference.hasPrefix("http://") || reference.hasPrefix("https://") {
            return URL(string: reference)
        }
        let url = fileURL(for: reference)
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    func delete(fileName: String) {
        let url = fileURL(for: fileName)
        try? FileManager.default.removeItem(at: url)
    }

    func saveGeneratedVideoData(_ data: Data) throws -> String {
        try ensureDirectoryExists()
        let fileName = "generated_\(UUID().uuidString).mp4"
        let destination = fileURL(for: fileName)
        try data.write(to: destination, options: .atomic)
        return fileName
    }

    func saveDownloadedVideo(from sourceURL: URL, id: UUID) async throws -> String {
        try ensureDirectoryExists()

        let fileName = "\(id.uuidString).mp4"
        let destination = fileURL(for: fileName)

        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }

        if sourceURL.isFileURL {
            try FileManager.default.copyItem(at: sourceURL, to: destination)
        } else {
            let (temporaryURL, _) = try await URLSession.shared.download(from: sourceURL)
            try FileManager.default.moveItem(at: temporaryURL, to: destination)
        }

        return fileName
    }

    func resolvedFileURL(for url: URL) async throws -> URL {
        if url.isFileURL {
            guard FileManager.default.fileExists(atPath: url.path) else {
                throw VideoStorageError.fileNotFound
            }
            return url
        }

        let (temporaryURL, _) = try await URLSession.shared.download(from: url)
        return temporaryURL
    }

    func saveToPhotoLibrary(fileURL: URL) async throws {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized || status == .limited else {
            throw VideoStorageError.photoAccessDenied
        }

        try await PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
        }
    }

    private func ensureDirectoryExists() throws {
        if !FileManager.default.fileExists(atPath: directoryURL.path) {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
        }
    }
}
