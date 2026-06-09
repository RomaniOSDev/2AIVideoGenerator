import SwiftUI

struct RootView: View {
    @State private var appState = AppStateViewModel(subscriptionService: SubscriptionService())
    @State private var onboardingViewModel = OnboardingViewModel()

    var body: some View {
        Group {
            if appState.hasCompletedOnboarding {
                MainTabView(appState: appState)
            } else {
                OnboardingView(viewModel: onboardingViewModel) {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        appState.completeOnboarding()
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    RootView()
}
