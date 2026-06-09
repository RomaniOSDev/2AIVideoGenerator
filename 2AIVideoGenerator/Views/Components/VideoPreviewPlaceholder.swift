import SwiftUI

struct VideoPreviewPlaceholder: View {
    var aspectRatio: VideoAspectRatio = .landscape
    var showPlayIcon: Bool = true
    var showWatermark: Bool = false

    private var ratio: CGFloat {
        switch aspectRatio {
        case .portrait: 9 / 16
        case .landscape: 16 / 9
        case .square: 1
        }
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            AppColors.surfaceElevated,
                            AppColors.accentPurple.opacity(0.2),
                            AppColors.accentBlue.opacity(0.15)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            if showPlayIcon {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.white.opacity(0.85))
            }

            if showWatermark {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(L10n.galleryWatermark)
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.7))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.black.opacity(0.45))
                            .clipShape(Capsule())
                            .padding(8)
                    }
                }
            }
        }
        .aspectRatio(ratio, contentMode: .fit)
    }
}
