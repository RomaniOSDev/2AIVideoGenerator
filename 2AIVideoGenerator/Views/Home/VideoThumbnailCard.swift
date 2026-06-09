import SwiftUI

struct VideoThumbnailCard: View {
    let video: GeneratedVideo
    var size: CGFloat = 120

    var body: some View {
        ZStack {
            VideoThumbnailView(video: video, showPlayIcon: false)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack {
                HStack {
                    Circle()
                        .fill(AppColors.accentPurple)
                        .frame(width: 8, height: 8)
                    Spacer()
                    Text("\(video.duration)\(L10n.createSeconds)")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(.black.opacity(0.45))
                        .clipShape(Capsule())
                }
                Spacer()
            }
            .padding(8)
        }
        .frame(width: size, height: size)
    }
}
