import SwiftUI

struct OnboardingView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onComplete: () -> Void

    var body: some View {
        VStack(spacing: 0) {
                HStack {
                    Spacer()
                    if !viewModel.isLastSlide {
                        Button(L10n.skip) {
                            viewModel.skipToEnd()
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppColors.textSecondary)
                    }
                }
                .padding(.horizontal, AppTheme.horizontalPadding)
                .padding(.top, 8)

                TabView(selection: $viewModel.currentIndex) {
                    ForEach(viewModel.slides) { slide in
                        onboardingPage(slide)
                            .tag(slide.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                pageIndicator
                    .padding(.bottom, 16)

                if viewModel.isLastSlide {
                    Button(L10n.getStartedFree, action: onComplete)
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal, AppTheme.horizontalPadding)
                        .padding(.bottom, 32)
                } else {
                    Button(L10n.next) {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            viewModel.next()
                        }
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, AppTheme.horizontalPadding)
                    .padding(.bottom, 32)
                }
        }
        .appBackground()
    }

    private func onboardingPage(_ slide: OnboardingSlide) -> some View {
        VStack(spacing: 28) {
            Spacer()

            Image(slide.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: 320)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous))
                .padding(.horizontal, AppTheme.horizontalPadding)

            VStack(spacing: 12) {
                Text(slide.title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(slide.subtitle)
                    .font(.body)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }
            .padding(.horizontal, AppTheme.horizontalPadding)

            Spacer()
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(viewModel.slides) { slide in
                Capsule()
                    .fill(slide.id == viewModel.currentIndex ? AppColors.accentPurple : AppColors.border.opacity(0.5))
                    .frame(width: slide.id == viewModel.currentIndex ? 24 : 8, height: 8)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.currentIndex)
            }
        }
    }
}
