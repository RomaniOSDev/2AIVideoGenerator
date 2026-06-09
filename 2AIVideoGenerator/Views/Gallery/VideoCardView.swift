import SwiftUI

struct VideoCardView: View {
    let video: GeneratedVideo

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                VideoThumbnailView(
                    video: video,
                    showPlayIcon: true,
                    showWatermark: video.hasWatermark
                )
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous))

                Text(video.model.title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppColors.accentPurple.opacity(0.85))
                    .clipShape(Capsule())
                    .padding(8)
            }
            .rotationEffect(.degrees(video.cardRotation))

            Text(video.prompt)
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(2)

            Text(video.durationLabel)
                .font(.caption2)
                .foregroundStyle(AppColors.textSecondary.opacity(0.8))
        }
    }
}
