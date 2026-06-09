import AVFoundation
import UIKit

final class VideoThumbnailService {
    static let shared = VideoThumbnailService()

    private let cache = NSCache<NSString, UIImage>()
    private let thumbnailsDirectoryName = "Thumbnails"

    private init() {}

    func thumbnail(for video: GeneratedVideo) async -> UIImage? {
        let cacheKey = video.id.uuidString as NSString

        if let cached = cache.object(forKey: cacheKey) {
            return cached
        }

        if let diskImage = loadFromDisk(videoId: video.id) {
            cache.setObject(diskImage, forKey: cacheKey)
            return diskImage
        }

        guard let url = video.playbackURL else { return nil }

        let image = await Task.detached(priority: .utility) {
            Self.generateThumbnail(from: url)
        }.value

        if let image {
            cache.setObject(image, forKey: cacheKey)
            saveToDisk(image, videoId: video.id)
        }

        return image
    }

    func deleteThumbnail(for videoId: UUID) {
        let cacheKey = videoId.uuidString as NSString
        cache.removeObject(forKey: cacheKey)

        let url = thumbnailURL(for: videoId)
        try? FileManager.default.removeItem(at: url)
    }

    private var thumbnailsDirectoryURL: URL {
        VideoStorageService.shared.directoryURL
            .appendingPathComponent(thumbnailsDirectoryName, isDirectory: true)
    }

    private func thumbnailURL(for videoId: UUID) -> URL {
        thumbnailsDirectoryURL.appendingPathComponent("\(videoId.uuidString).jpg")
    }

    private func loadFromDisk(videoId: UUID) -> UIImage? {
        let url = thumbnailURL(for: videoId)
        guard FileManager.default.fileExists(atPath: url.path),
              let data = try? Data(contentsOf: url),
              let image = UIImage(data: data) else {
            return nil
        }
        return image
    }

    private func saveToDisk(_ image: UIImage, videoId: UUID) {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return }

        do {
            let directory = thumbnailsDirectoryURL
            if !FileManager.default.fileExists(atPath: directory.path) {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
            }
            try data.write(to: thumbnailURL(for: videoId), options: .atomic)
        } catch {
            return
        }
    }

    private static func generateThumbnail(from url: URL) -> UIImage? {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 480, height: 480)

        do {
            let cgImage = try generator.copyCGImage(at: CMTime(seconds: 0.1, preferredTimescale: 600), actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            return nil
        }
    }
}
