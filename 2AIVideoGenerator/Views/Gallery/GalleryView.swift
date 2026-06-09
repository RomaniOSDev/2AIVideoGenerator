import SwiftUI

struct GalleryView: View {
    @Bindable var appState: AppStateViewModel
    @State private var viewModel = GalleryViewModel()

    private var filteredVideos: [GeneratedVideo] {
        viewModel.filteredVideos(from: appState.videos)
    }

    var body: some View {
        NavigationStack {
            Group {
                if filteredVideos.isEmpty {
                    emptyState
                } else {
                    galleryGrid
                }
            }
            .appBackground()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    filterMenu
                }
                ToolbarItem(placement: .topBarTrailing) {
                    SubscriptionBadgeView(
                        isPro: appState.isProSubscriber,
                        isInTrial: appState.isInTrialPeriod,
                        trialDaysRemaining: appState.trialDaysRemaining
                    ) {
                        if !appState.hasPremiumAccess {
                            appState.openPaywall()
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var filterMenu: some View {
        Menu {
            Button(L10n.all) {
                viewModel.selectedFilter = nil
            }
            ForEach(VideoProvider.allCases) { provider in
                Button(provider.title) {
                    viewModel.selectedFilter = provider
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(viewModel.filterTitle)
                    .font(.subheadline.weight(.medium))
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
            .foregroundStyle(AppColors.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppColors.surfaceElevated)
            .clipShape(Capsule())
        }
    }

    private var galleryGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 16),
                    GridItem(.flexible(), spacing: 16)
                ],
                spacing: 20
            ) {
                ForEach(filteredVideos) { video in
                    Button {
                        appState.presentedVideo = video
                    } label: {
                        VideoCardView(video: video)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, AppTheme.horizontalPadding)
            .padding(.vertical, 16)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "play.rectangle.on.rectangle")
                .font(.system(size: 52))
                .foregroundStyle(AppColors.textSecondary.opacity(0.5))

            Text(L10n.galleryEmptyTitle)
                .font(.title3.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)

            Text(L10n.galleryEmptySubtitle)
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Button(L10n.tabCreate) {
                appState.selectedTab = .create
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, 48)
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
