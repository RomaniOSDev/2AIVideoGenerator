import Foundation

struct OnboardingSlide: Identifiable {
    let id: Int
    let title: String
    let subtitle: String
    let imageName: String

    static let slides: [OnboardingSlide] = [
        OnboardingSlide(
            id: 0,
            title: L10n.onboardingTitle1,
            subtitle: L10n.onboardingSubtitle1,
            imageName: "onbord1"
        ),
        OnboardingSlide(
            id: 1,
            title: L10n.onboardingTitle2,
            subtitle: L10n.onboardingSubtitle2,
            imageName: "onbord2"
        ),
        OnboardingSlide(
            id: 2,
            title: L10n.onboardingTitle3,
            subtitle: L10n.onboardingSubtitle3,
            imageName: "onbord3"
        )
    ]
}
