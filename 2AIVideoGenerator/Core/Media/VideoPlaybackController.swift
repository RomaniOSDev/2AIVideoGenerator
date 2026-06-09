import AVFoundation
import Foundation

@MainActor
@Observable
final class VideoPlaybackController {
    private(set) var player: AVPlayer?
    var isPlaying = false
    var currentTime: Double = 0
    var duration: Double = 0
    var isScrubbing = false

    private var timeObserver: Any?
    private var endObserver: NSObjectProtocol?

    func load(url: URL, autoplay: Bool = true) {
        teardown()

        let player = AVPlayer(url: url)
        self.player = player
        isPlaying = false
        currentTime = 0
        duration = 0

        observePlayback(player)
        loadDuration(from: url)

        if autoplay {
            player.play()
            isPlaying = true
        }
    }

    func teardown() {
        if let timeObserver, let player {
            player.removeTimeObserver(timeObserver)
        }
        timeObserver = nil

        if let endObserver {
            NotificationCenter.default.removeObserver(endObserver)
        }
        endObserver = nil

        player?.pause()
        player = nil
        isPlaying = false
        currentTime = 0
        duration = 0
        isScrubbing = false
    }

    func togglePlayback() {
        guard let player else { return }

        if isPlaying {
            player.pause()
            isPlaying = false
        } else {
            if currentTime >= duration, duration > 0 {
                seek(to: 0)
            }
            player.play()
            isPlaying = true
        }
    }

    func seek(to seconds: Double) {
        guard let player else { return }

        let clamped = max(0, min(seconds, max(duration, 0)))
        currentTime = clamped
        player.seek(to: CMTime(seconds: clamped, preferredTimescale: 600))
    }

    private func observePlayback(_ player: AVPlayer) {
        let interval = CMTime(seconds: 0.25, preferredTimescale: 600)
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let self, !self.isScrubbing else { return }
            self.currentTime = max(0, time.seconds)
        }

        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.isPlaying = false
            self.currentTime = self.duration
        }
    }

    private func loadDuration(from url: URL) {
        let asset = AVURLAsset(url: url)

        Task {
            guard let loadedDuration = try? await asset.load(.duration) else { return }
            let seconds = loadedDuration.seconds
            guard seconds.isFinite, seconds > 0 else { return }
            duration = seconds
        }
    }
}

enum VideoTimeFormatting {
    static func format(_ seconds: Double) -> String {
        guard seconds.isFinite, seconds >= 0 else { return "0:00" }

        let total = Int(seconds.rounded())
        let minutes = total / 60
        let remainder = total % 60
        return String(format: "%d:%02d", minutes, remainder)
    }
}
