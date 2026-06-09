import Foundation

@MainActor
@Observable
final class OnboardingViewModel {
    var currentIndex: Int = 0

    let slides = OnboardingSlide.slides

    var isLastSlide: Bool {
        currentIndex >= slides.count - 1
    }

    func next() {
        guard !isLastSlide else { return }
        currentIndex += 1
    }

    func skipToEnd() {
        currentIndex = slides.count - 1
    }
}
