import SwiftUI

struct VideoDetailView: View {
    @Bindable var viewModel: VideoDetailViewModel
    let onDone: () -> Void
    let onDelete: () -> Void

    @State private var showDeleteAlert = false
    @State private var alertMessage: String?
    @State private var showAlert = false
    @State private var didSaveSuccessfully = false

    private let horizontalPadding: CGFloat = 16

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    videoSection
                    actionButtons
                    promptCard
                    metadataRow
                }
                .padding(.horizontal, AppTheme.horizontalPadding)
                .padding(.top, 64)
                .padding(.bottom, 32)
            }

            topBar
                .padding(.horizontal, horizontalPadding)
                .safeAreaPadding(.top, 8)
                .background {
                    LinearGradient(
                        colors: [Color.black.opacity(0.9), Color.black.opacity(0.6), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea(edges: .top)
                    .allowsHitTesting(false)
                }
        }
        .preferredColorScheme(.dark)
        .alert(L10n.videoDelete, isPresented: $showDeleteAlert) {
            Button(L10n.cancel, role: .cancel) {}
            Button(L10n.videoDelete, role: .destructive) {
                onDelete()
                onDone()
            }
        }
        .alert(L10n.videoSave, isPresented: $showAlert) {
            Button(L10n.done, role: .cancel) {}
        } message: {
            Text(alertMessage ?? "")
        }
    }

    private var videoSection: some View {
        Group {
            if viewModel.playbackURL != nil {
                GeneratedVideoPlayerView(
                    url: viewModel.playbackURL!,
                    aspectRatio: viewModel.video.aspectRatio,
                    showWatermark: viewModel.video.hasWatermark,
                    style: .cinema
                )
            } else {
                VideoPreviewPlaceholder(
                    aspectRatio: viewModel.video.aspectRatio,
                    showPlayIcon: false,
                    showWatermark: viewModel.video.hasWatermark
                )
                .overlay {
                    Text(L10n.videoUnavailable)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .clipShape(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    private var topBar: some View {
        HStack {
            Button(action: onDone) {
                Text(L10n.done)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.white.opacity(0.12))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                showDeleteAlert = true
            } label: {
                Image(systemName: "trash")
                    .font(.body.weight(.medium))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(.white.opacity(0.12))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            if let url = viewModel.playbackURL {
                ShareLink(item: url) {
                    actionButtonLabel(title: L10n.videoShare, icon: "square.and.arrow.up", isPrimary: false)
                }
                .buttonStyle(.plain)
            } else {
                actionButtonLabel(title: L10n.videoShare, icon: "square.and.arrow.up", isPrimary: false)
                    .opacity(0.4)
            }

            Button {
                Task { await saveVideo() }
            } label: {
                actionButtonLabel(
                    title: didSaveSuccessfully ? L10n.videoSaved : L10n.videoSave,
                    icon: "arrow.down.circle",
                    isPrimary: true
                )
            }
            .buttonStyle(.plain)
            .disabled(viewModel.playbackURL == nil || viewModel.isSaving)
            .opacity(viewModel.playbackURL == nil ? 0.4 : 1)
        }
    }

    private func actionButtonLabel(title: String, icon: String, isPrimary: Bool) -> some View {
        Label(title, systemImage: icon)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(isPrimary ? .white : AppColors.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background {
                if isPrimary {
                    AppColors.gradientPrimary
                } else {
                    Color.white.opacity(0.08)
                }
            }
            .overlay {
                if !isPrimary {
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous))
    }

    private var promptCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.videoPrompt)
                .font(.caption.weight(.semibold))
                .tracking(1)
                .foregroundStyle(AppColors.textSecondary)

            Text(viewModel.video.prompt)
                .font(.body)
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.white.opacity(0.06))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous))
    }

    private var metadataRow: some View {
        HStack(spacing: 10) {
            metadataChip(viewModel.video.model.title)
            metadataChip(viewModel.video.durationLabel)
            metadataChip(viewModel.video.aspectRatio.ratioLabel)
        }
    }

    private func metadataChip(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.medium))
            .foregroundStyle(AppColors.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(Color.white.opacity(0.08))
            .clipShape(Capsule())
    }

    private func saveVideo() async {
        do {
            try await viewModel.saveToPhotos()
            didSaveSuccessfully = true
        } catch {
            alertMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            showAlert = true
        }
    }
}
