import SwiftUI

struct HomeView: View {
    @Bindable var appState: AppStateViewModel
    @State private var viewModel = HomeViewModel()

    private var recentVideos: [GeneratedVideo] {
        Array(appState.videos.prefix(6))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    GenerationModeToggle(selected: $viewModel.generationMode)
                    modelSection

                    if viewModel.generationMode == .imageToVideo {
                        ImageInputSection(viewModel: viewModel)
                    }

                    promptSection
                    durationSection
                    generateButton

                    if !recentVideos.isEmpty {
                        recentSection
                        gallerySection
                    }
                }
                .padding(.horizontal, AppTheme.horizontalPadding)
                .padding(.bottom, 32)
            }
            .scrollDismissesKeyboard(.interactively)
            .appBackground()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    subscriptionButton
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
        .fullScreenCover(isPresented: $appState.isGenerating) {
            GenerationProgressView(
                prompt: viewModel.prompt,
                request: viewModel.makeGenerationRequest(),
                service: appState.waveSpeedService,
                onComplete: { localURL in finishGeneration(localVideoURL: localURL) },
                onCancel: { appState.isGenerating = false }
            )
        }
    }

    private var subscriptionButton: some View {
        Button {
            appState.selectedTab = .subscription
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "crown.fill")
                    .font(.body)
                Text(L10n.tabSubscription)
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(AppColors.textPrimary)
        }
        .buttonStyle(.plain)
    }

    private var modelSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.createAiModels)
                .font(.caption.weight(.semibold))
                .tracking(1)
                .foregroundStyle(AppColors.textSecondary)

            HStack(spacing: 12) {
                ForEach(AIModelOption.homeModels) { model in
                    Button {
                        viewModel.selectedModel = model
                    } label: {
                        HomeModelCardView(
                            model: model,
                            isSelected: viewModel.selectedModel == model
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var promptSection: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack(alignment: .topLeading) {
                TextEditor(text: $viewModel.prompt)
                    .frame(minHeight: 140)
                    .scrollContentBackground(.hidden)
                    .padding(16)
                    .padding(.bottom, 44)
                    .foregroundStyle(AppColors.textPrimary)

                if viewModel.prompt.isEmpty {
                    Text(viewModel.generationMode == .imageToVideo
                         ? L10n.createImagePromptPlaceholder
                         : L10n.createPromptPlaceholder)
                        .font(.body)
                        .foregroundStyle(AppColors.textSecondary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 24)
                        .allowsHitTesting(false)
                }
            }
            .background(AppColors.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous))

            HStack(spacing: 8) {
                promptActionButton(L10n.createEnhance, icon: "wand.and.stars") {}
                promptActionButton(L10n.createRandom, icon: "dice") {
                    viewModel.applyRandomPrompt()
                }
            }
            .padding(12)
        }
    }

    private func promptActionButton(_ title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                Text(title)
                    .font(.caption.weight(.medium))
            }
            .foregroundStyle(AppColors.textSecondary)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(AppColors.surfaceElevated)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.createDurationSection)
                .font(.caption.weight(.semibold))
                .tracking(1)
                .foregroundStyle(AppColors.textSecondary)

            DurationSliderView(
                value: $viewModel.durationSliderValue,
                durations: viewModel.durations
            )
        }
    }

    private var generateButton: some View {
        Button {
            startGeneration()
        } label: {
            Text(L10n.createGenerateVideo)
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(AppColors.gradientPrimary)
                .clipShape(Capsule())
                .opacity(viewModel.canGenerate ? 1 : 0.5)
        }
        .buttonStyle(.plain)
        .disabled(!viewModel.canGenerate)
    }

    private var recentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.createRecentGenerations)
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(recentVideos) { video in
                        Button {
                            appState.presentedVideo = video
                        } label: {
                            VideoThumbnailCard(video: video)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var gallerySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(L10n.createMyGallery)
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Button(L10n.createViewAll) {
                    appState.selectedTab = .gallery
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppColors.accentPurple)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(recentVideos) { video in
                        Button {
                            appState.presentedVideo = video
                        } label: {
                            VideoThumbnailCard(video: video)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func startGeneration() {
        guard viewModel.canGenerate else { return }

        if !appState.canGenerateVideo() {
            appState.openPaywall()
            return
        }

        hideKeyboard()
        appState.isGenerating = true
    }

    private func finishGeneration(localVideoURL: URL) {
        let video = viewModel.makeVideo(hasWatermark: appState.hasWatermark, localVideoURL: localVideoURL)
        appState.addVideo(video)
        appState.isGenerating = false
        viewModel.resetCreationSettings()
        appState.presentedVideo = video
    }
}
