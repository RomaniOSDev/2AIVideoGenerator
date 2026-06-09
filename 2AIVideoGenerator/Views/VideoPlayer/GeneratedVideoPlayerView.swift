import AVKit
import SwiftUI

struct GeneratedVideoPlayerView: View {
    let url: URL
    let aspectRatio: VideoAspectRatio
    let showWatermark: Bool
    var style: PlayerStyle = .card

    enum PlayerStyle {
        case card
        case cinema
    }

    @State private var player: AVPlayer?

    private var ratio: CGFloat { aspectRatio.displayRatio }

    var body: some View {
        Group {
            if style == .card {
                cardPlayer
            } else {
                cinemaPlayer
            }
        }
        .background(Color.black)
    }

    private var cardPlayer: some View {
        playerSurface
            .aspectRatio(ratio, contentMode: .fit)
            .clipShape(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
            )
            .onAppear(perform: startPlayback)
            .onDisappear(perform: stopPlayback)
    }

    private var cinemaPlayer: some View {
        Color.black
            .aspectRatio(ratio, contentMode: .fit)
            .overlay {
                CinemaPlayerView(url: url)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .overlay(alignment: .bottomTrailing) {
                if showWatermark {
                    watermarkBadge
                }
            }
    }

    private var playerSurface: some View {
        ZStack {
            Color.black

            if let player {
                VideoPlayer(player: player)
                    .background(Color.black)
            } else {
                ProgressView()
                    .tint(AppColors.accentPurple)
            }

            if showWatermark {
                watermarkBadge
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
            }
        }
    }

    private var watermarkBadge: some View {
        Text(L10n.galleryWatermark)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(.white.opacity(0.85))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.black.opacity(0.45))
            .clipShape(Capsule())
            .padding(12)
            .allowsHitTesting(false)
    }

    private func startPlayback() {
        let newPlayer = AVPlayer(url: url)
        player = newPlayer
        newPlayer.play()
    }

    private func stopPlayback() {
        player?.pause()
        player = nil
    }
}
