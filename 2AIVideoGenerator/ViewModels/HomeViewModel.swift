import Foundation
import UIKit

@MainActor
@Observable
final class HomeViewModel {
    var generationMode: GenerationMode = .textToVideo {
        didSet { handleModeChange(from: oldValue, to: generationMode) }
    }

    var prompt: String = ""
    var selectedModel: AIModelOption = .runwayGen4
    var selectedDuration: Int = 5
    var selectedAspect: VideoAspectRatio = .portrait
    var selectedImage: UIImage?
    var showPhotoLibrary = false

    let durations = [3, 5, 8, 10]

    var durationSliderValue: Double {
        get { Double(durations.firstIndex(of: selectedDuration) ?? 1) }
        set {
            let index = Int(newValue.rounded())
            if durations.indices.contains(index) {
                selectedDuration = durations[index]
            }
        }
    }

    var canGenerate: Bool {
        switch generationMode {
        case .textToVideo:
            !prompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .imageToVideo:
            selectedImage != nil
        }
    }

    func setSelectedImage(_ image: UIImage) {
        selectedImage = image
    }

    func clearSelectedImage() {
        selectedImage = nil
    }

    func applyRandomPrompt() {
        prompt = RandomVideoPrompts.random()
    }

    func makeGenerationRequest() -> VideoGenerationRequest {
        var imageData: Data?
        var imageFilename: String?
        var imageMimeType: String?

        if let image = selectedImage, let data = image.jpegData(compressionQuality: 0.9) {
            imageData = data
            imageFilename = "input-\(UUID().uuidString.prefix(8)).jpg"
            imageMimeType = "image/jpeg"
        }

        return VideoGenerationRequest(
            prompt: prompt.trimmingCharacters(in: .whitespacesAndNewlines),
            model: selectedModel,
            mode: generationMode,
            duration: selectedDuration,
            aspectRatio: selectedAspect,
            imageData: imageData,
            imageFilename: imageFilename,
            imageMimeType: imageMimeType
        )
    }

    func makeVideo(hasWatermark: Bool, localVideoURL: URL) -> GeneratedVideo {
        GeneratedVideo(
            id: UUID(),
            prompt: prompt.trimmingCharacters(in: .whitespacesAndNewlines),
            model: selectedModel,
            duration: selectedDuration,
            aspectRatio: selectedAspect,
            createdAt: Date(),
            hasWatermark: hasWatermark,
            cardRotation: Double.random(in: AppTheme.cardRotationRange),
            videoReference: localVideoURL.lastPathComponent
        )
    }

    func resetCreationSettings() {
        generationMode = .textToVideo
        prompt = ""
        selectedModel = .runwayGen4
        selectedDuration = 5
        selectedAspect = .portrait
        selectedImage = nil
        showPhotoLibrary = false
    }

    private func handleModeChange(from oldValue: GenerationMode, to newValue: GenerationMode) {
        guard oldValue != newValue else { return }
        if newValue == .textToVideo {
            clearSelectedImage()
        }
    }
}
