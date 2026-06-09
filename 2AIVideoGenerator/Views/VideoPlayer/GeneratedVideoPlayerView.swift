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

    @State private var cardPlayer: AVPlayer?
    @State private var playbackController = VideoPlaybackController()

    private var ratio: CGFloat { aspectRatio.displayRatio }

    var body: some View {
        Group {
            if style == .card {
                cardPlayerView
            } else {
                cinemaPlayerView
            }
        }
        .background(Color.black)
    }

    private var cardPlayerView: some View {
        playerSurface
            .aspectRatio(ratio, contentMode: .fit)
            .clipShape(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
            )
            .onAppear(perform: startCardPlayback)
            .onDisappear(perform: stopCardPlayback)
    }

    private var cinemaPlayerView: some View {
        Color.black
            .aspectRatio(ratio, contentMode: .fit)
            .overlay {
                if let player = playbackController.player {
                    CinemaPlayerLayerView(player: player)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ProgressView()
                        .tint(AppColors.accentPurple)
                }
            }
            .overlay(alignment: .bottom) {
                VideoPlayerControlsBar(controller: playbackController)
            }
            .overlay(alignment: .bottomTrailing) {
                if showWatermark {
                    watermarkBadge
                        .padding(.bottom, 72)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                playbackController.togglePlayback()
            }
            .onAppear {
                playbackController.load(url: url)
            }
            .onDisappear {
                playbackController.teardown()
            }
    }

    private var playerSurface: some View {
        ZStack {
            Color.black

            if let cardPlayer {
                VideoPlayer(player: cardPlayer)
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

    private func startCardPlayback() {
        let newPlayer = AVPlayer(url: url)
        cardPlayer = newPlayer
        newPlayer.play()
    }

    private func stopCardPlayback() {
        cardPlayer?.pause()
        cardPlayer = nil
    }
}
