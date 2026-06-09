import Foundation

@MainActor
@Observable
final class GalleryViewModel {
    var selectedFilter: VideoProvider? = nil

    func filteredVideos(from videos: [GeneratedVideo]) -> [GeneratedVideo] {
        guard let filter = selectedFilter else { return videos }
        return videos.filter { $0.provider == filter }
    }

    var filterTitle: String {
        selectedFilter?.title ?? L10n.all
    }
}
