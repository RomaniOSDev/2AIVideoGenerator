import Foundation

final class VideoLibraryStore {
    static let shared = VideoLibraryStore()

    private let fileName = "video_library.json"
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.sortedKeys]
        return encoder
    }()
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    private init() {}

    private var catalogURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
    }

    func load() -> [GeneratedVideo] {
        guard let data = try? Data(contentsOf: catalogURL),
              let videos = try? decoder.decode([GeneratedVideo].self, from: data) else {
            return []
        }

        let validVideos = videos.filter { video in
            guard let reference = video.videoReference else { return false }
            return VideoStorageService.shared.playbackURL(for: reference) != nil
        }

        if validVideos.count != videos.count {
            save(validVideos)
        }

        return validVideos.sorted { $0.createdAt > $1.createdAt }
    }

    func save(_ videos: [GeneratedVideo]) {
        guard let data = try? encoder.encode(videos) else { return }
        try? data.write(to: catalogURL, options: .atomic)
    }
}
