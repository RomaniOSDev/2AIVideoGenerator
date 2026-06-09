import Foundation
import SwiftUI

@MainActor
@Observable
final class AppStateViewModel {
    private let onboardingKey = "hasCompletedOnboarding"

    let subscriptionService: SubscriptionService
    let waveSpeedService: WaveSpeedService

    var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: onboardingKey) }
    }

    var selectedTab: AppTab = .create
    var isGenerating: Bool = false
    var presentedVideo: GeneratedVideo?
    var videos: [GeneratedVideo] = []

    var isProSubscriber: Bool { subscriptionService.isSubscribed }
    var isInTrialPeriod: Bool { subscriptionService.isInTrialPeriod }
    var hasPremiumAccess: Bool { subscriptionService.hasPremiumAccess }
    var trialDaysRemaining: Int { subscriptionService.trialDaysRemaining }

    var hasWatermark: Bool {
        !hasPremiumAccess
    }

    init(
        subscriptionService: SubscriptionService,
        waveSpeedService: WaveSpeedService = WaveSpeedService()
    ) {
        self.subscriptionService = subscriptionService
        self.waveSpeedService = waveSpeedService
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: onboardingKey)
        videos = VideoLibraryStore.shared.load()
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    func openPaywall() {
        selectedTab = .subscription
    }

    func canGenerateVideo() -> Bool {
        hasPremiumAccess
    }

    func purchaseSubscription() async throws {
        try await subscriptionService.purchase()
    }

    func restorePurchases() async throws {
        try await subscriptionService.restore()
    }

    func addVideo(_ video: GeneratedVideo) {
        videos.insert(video, at: 0)
        VideoLibraryStore.shared.save(videos)
    }

    func deleteVideo(_ video: GeneratedVideo) {
        if let reference = video.videoReference, video.isLocalFile {
            VideoStorageService.shared.delete(fileName: reference)
        }
        VideoThumbnailService.shared.deleteThumbnail(for: video.id)
        videos.removeAll { $0.id == video.id }
        if presentedVideo?.id == video.id {
            presentedVideo = nil
        }
        VideoLibraryStore.shared.save(videos)
    }
}
