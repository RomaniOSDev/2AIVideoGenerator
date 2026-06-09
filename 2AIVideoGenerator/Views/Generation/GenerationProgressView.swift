import SwiftUI

struct GenerationProgressView: View {
    let prompt: String
    let request: VideoGenerationRequest
    let service: any WaveSpeedServiceProtocol
    let onComplete: (URL) -> Void
    let onCancel: () -> Void

    @State private var viewModel = GenerationProgressViewModel()
    @State private var errorMessage: String?
    @State private var showError = false

    private let ringSize: CGFloat = 200
    private let ringLineWidth: CGFloat = 6

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            progressRing
                .padding(.bottom, 28)

            statusSection
                .padding(.bottom, 32)

            promptPreviewCard
                .padding(.horizontal, AppTheme.horizontalPadding)

            Spacer()

            cancelButton
                .padding(.bottom, 48)
        }
        .appBackground()
        .preferredColorScheme(.dark)
        .onAppear {
            viewModel.start(
                service: service,
                request: request,
                onComplete: onComplete,
                onFailure: { error in
                    errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
                    showError = true
                }
            )
        }
        .onDisappear {
            viewModel.cancel()
        }
        .alert(L10n.generationErrorTitle, isPresented: $showError) {
            Button(L10n.done, role: .cancel) {
                viewModel.cancel()
                onCancel()
            }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    private var progressRing: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.08), lineWidth: ringLineWidth)
                .frame(width: ringSize, height: ringSize)

            Circle()
                .trim(from: 0, to: viewModel.progress)
                .stroke(
                    AngularGradient(
                        colors: [
                            AppColors.accentPurple,
                            AppColors.accentBlue,
                            AppColors.accentPurple.opacity(0.8)
                        ],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: ringLineWidth, lineCap: .round)
                )
                .frame(width: ringSize, height: ringSize)
                .rotationEffect(.degrees(-90))
                .shadow(color: AppColors.accentPurple.opacity(0.55), radius: 12)
                .animation(.easeInOut(duration: 0.25), value: viewModel.progress)

            Text("\(viewModel.progressPercent)%")
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: AppColors.accentPurple.opacity(0.45), radius: 10)
        }
    }

    private var statusSection: some View {
        VStack(spacing: 10) {
            Text(viewModel.statusText)
                .font(.title2.weight(.bold))
                .foregroundStyle(AppColors.textPrimary)

            Text(String(format: L10n.generationTimeRemaining, viewModel.remainingSeconds))
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
        }
        .multilineTextAlignment(.center)
        .padding(.horizontal, 24)
    }

    private var promptPreviewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "chevron.left.forwardslash.chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColors.textSecondary)

                Text(L10n.generationPromptPreview)
                    .font(.caption.weight(.semibold))
                    .tracking(1.2)
                    .foregroundStyle(AppColors.textSecondary)
            }

            Text(prompt.isEmpty ? "—" : prompt)
                .font(.subheadline)
                .italic()
                .foregroundStyle(AppColors.textSecondary.opacity(0.9))
                .lineLimit(5)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private var cancelButton: some View {
        Button {
            viewModel.cancel()
            onCancel()
        } label: {
            Text(L10n.generationCancel)
                .font(.system(.subheadline, design: .monospaced))
                .foregroundStyle(AppColors.textSecondary)
        }
        .buttonStyle(.plain)
    }
}
