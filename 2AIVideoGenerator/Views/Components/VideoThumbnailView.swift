import SwiftUI

struct VideoThumbnailView: View {
    let video: GeneratedVideo
    var showPlayIcon: Bool = true
    var showWatermark: Bool = false

    @State private var thumbnail: UIImage?

    private var ratio: CGFloat {
        switch video.aspectRatio {
        case .portrait: 9 / 16
        case .landscape: 16 / 9
        case .square: 1
        }
    }

    var body: some View {
        ZStack {
            Group {
                if let thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .scaledToFill()
                } else {
                    VideoPreviewPlaceholder(
                        aspectRatio: video.aspectRatio,
                        showPlayIcon: false,
                        showWatermark: false
                    )
                }
            }

            if showPlayIcon {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.35), radius: 4)
            }

            if showWatermark {
                watermarkBadge
            }
        }
        .aspectRatio(ratio, contentMode: .fit)
        .clipped()
        .task(id: video.id) {
            thumbnail = await VideoThumbnailService.shared.thumbnail(for: video)
        }
    }

    private var watermarkBadge: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text(L10n.galleryWatermark)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.black.opacity(0.45))
                    .clipShape(Capsule())
                    .padding(8)
            }
        }
    }
}
