import SwiftUI

struct MainTabView: View {
    @Bindable var appState: AppStateViewModel

    var body: some View {
        TabView(selection: $appState.selectedTab) {
            HomeView(appState: appState)
                .tabItem {
                    Label(L10n.tabCreate, systemImage: AppTab.create.iconName)
                }
                .tag(AppTab.create)

            GalleryView(appState: appState)
                .tabItem {
                    Label(L10n.tabGallery, systemImage: AppTab.gallery.iconName)
                }
                .tag(AppTab.gallery)

            SubscriptionView(appState: appState)
                .tabItem {
                    Label(L10n.tabSubscription, systemImage: AppTab.subscription.iconName)
                }
                .tag(AppTab.subscription)
        }
        .appBackground()
        .tint(AppColors.accentPurple)
        .fullScreenCover(item: $appState.presentedVideo) { video in
            VideoDetailView(
                viewModel: VideoDetailViewModel(video: video),
                onDone: { appState.presentedVideo = nil },
                onDelete: { appState.deleteVideo(video) }
            )
        }
    }
}
