import SwiftUI

struct VideoPlayerControlsBar: View {
    @Bindable var controller: VideoPlaybackController

    private var sliderRange: ClosedRange<Double> {
        0...max(controller.duration, 1)
    }

    var body: some View {
        VStack(spacing: 10) {
            Slider(
                value: Binding(
                    get: { controller.currentTime },
                    set: { controller.currentTime = $0 }
                ),
                in: sliderRange,
                onEditingChanged: { isEditing in
                    controller.isScrubbing = isEditing
                    if !isEditing {
                        controller.seek(to: controller.currentTime)
                    }
                }
            )
            .tint(AppColors.accentPurple)

            HStack(spacing: 14) {
                Button(action: controller.togglePlayback) {
                    Image(systemName: controller.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                }
                .buttonStyle(.plain)

                Button {
                    controller.seek(to: max(0, controller.currentTime - 10))
                } label: {
                    Image(systemName: "gobackward.10")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.9))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)

                Button {
                    controller.seek(to: min(controller.duration, controller.currentTime + 10))
                } label: {
                    Image(systemName: "goforward.10")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.9))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)

                Text(timeLabel)
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.white.opacity(0.85))

                Spacer(minLength: 0)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background {
            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.75), Color.black.opacity(0.92)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }

    private var timeLabel: String {
        let current = VideoTimeFormatting.format(controller.currentTime)
        let total = VideoTimeFormatting.format(controller.duration)
        return "\(current) / \(total)"
    }
}
