import Foundation

@MainActor
@Observable
final class GenerationProgressViewModel {
    var progress: Double = 0
    var remainingSeconds: Int = 120
    var statusLabel: String = L10n.generationStatusPreparing

    private let totalEstimatedSeconds: Int = 120
    private var generationTask: Task<Void, Never>?

    var progressPercent: Int {
        Int((progress * 100).rounded())
    }

    var statusText: String {
        statusLabel
    }

    func start(
        service: any WaveSpeedServiceProtocol,
        request: VideoGenerationRequest,
        onComplete: @escaping (URL) -> Void,
        onFailure: @escaping (Error) -> Void
    ) {
        progress = 0
        statusLabel = L10n.generationStatusPreparing
        updateRemainingSeconds()

        generationTask?.cancel()
        generationTask = Task {
            do {
                let localURL = try await service.generateVideo(request: request) { [weak self] update in
                    Task { @MainActor in
                        guard let self else { return }
                        self.progress = update.value
                        self.statusLabel = Self.localizedStatus(for: update.label)
                        self.updateRemainingSeconds()
                    }
                }

                guard !Task.isCancelled else { return }

                progress = 1
                updateRemainingSeconds()
                onComplete(localURL)
            } catch is CancellationError {
                WaveSpeedLogger.info("Generation cancelled by user")
                return
            } catch {
                guard !Task.isCancelled else { return }
                let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                WaveSpeedLogger.error("Generation UI error at \(Int(progress * 100))%: \(message)")
                onFailure(error)
            }
        }
    }

    func cancel() {
        generationTask?.cancel()
        generationTask = nil
    }

    private func updateRemainingSeconds() {
        remainingSeconds = max(1, Int((1 - progress) * Double(totalEstimatedSeconds)))
    }

    private static func localizedStatus(for label: String) -> String {
        switch label {
        case "Uploading media": L10n.generationStatusUploading
        case "Submitting job": L10n.generationStatusSubmitting
        case "Generating frames": L10n.generationStatusFrames
        case "Downloading video", "Saving video": L10n.generationStatusRendering
        case "Rendering video": L10n.generationStatusRendering
        default: L10n.generationStatusPreparing
        }
    }
}
