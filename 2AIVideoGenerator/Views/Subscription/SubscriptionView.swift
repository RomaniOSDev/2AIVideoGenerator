import SwiftUI

struct SubscriptionView: View {
    @Bindable var appState: AppStateViewModel
    @State private var viewModel = SubscriptionViewModel()
    @State private var alertMessage: String?
    @State private var showAlert = false

    @Environment(\.openURL) private var openURL

    private var subscriptionService: SubscriptionService {
        appState.subscriptionService
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer().frame(height: 16)

                PaywallCarouselView()
                    .padding(.bottom, 20)

                Text(L10n.paywallTitle)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)

                Text(L10n.paywallSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 6)
                    .padding(.bottom, 20)

                if appState.hasPremiumAccess {
                    statusBanner
                        .padding(.horizontal, AppTheme.horizontalPadding)
                        .padding(.bottom, 16)
                }

                productSection
                    .padding(.horizontal, AppTheme.horizontalPadding)

                bottomSection
                    .padding(.horizontal, AppTheme.horizontalPadding)
                    .padding(.top, 28)
                    .padding(.bottom, 32)
            }
        }
        .appBackground()
        .preferredColorScheme(.dark)
        .task {
            await subscriptionService.loadProducts()
            await subscriptionService.refreshStatus()
        }
        .alert(L10n.subscriptionErrorTitle, isPresented: $showAlert) {
            Button(L10n.done, role: .cancel) {}
        } message: {
            Text(alertMessage ?? "")
        }
    }

    @ViewBuilder
    private var productSection: some View {
        if subscriptionService.isLoading && subscriptionService.product == nil {
            VStack(spacing: 12) {
                ProgressView()
                    .tint(AppColors.accentPurple)
                Text(L10n.paywallLoadingProducts)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 40)
        } else if let error = subscriptionService.productsLoadError, subscriptionService.product == nil {
            productLoadErrorView(message: error)
        } else if subscriptionService.product != nil {
            subscriptionCard
        }
    }

    private func productLoadErrorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.title2)
                .foregroundStyle(AppColors.warning)

            Text(L10n.paywallProductsLoadFailed)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            Text(message)
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)

            Button {
                Task { await subscriptionService.loadProducts() }
            } label: {
                Text(L10n.paywallReloadProducts)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(AppColors.gradientPrimary)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(subscriptionService.isLoading)
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(AppColors.surface.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous))
    }

    private var statusBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.title3)
                .foregroundStyle(AppColors.success)

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.statusLabel(
                    isPro: appState.isProSubscriber,
                    isInTrial: appState.isInTrialPeriod
                ))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.textPrimary)

                if let detail = viewModel.statusDetail(
                    isPro: appState.isProSubscriber,
                    isInTrial: appState.isInTrialPeriod,
                    daysRemaining: appState.trialDaysRemaining
                ) {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }

            Spacer()
        }
        .padding(16)
        .background(AppColors.surface.opacity(0.85))
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous)
                .stroke(AppColors.success.opacity(0.4), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous))
    }

    private var subscriptionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(L10n.paywallProSubscription)
                        .font(.caption.weight(.bold))
                        .tracking(1.2)
                        .foregroundStyle(AppColors.paywallLavender)

                    Text(viewModel.priceLabel(from: subscriptionService))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(AppColors.textPrimary)

                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.features(from: subscriptionService), id: \.self) { feature in
                            PaywallFeatureRow(text: feature)
                        }
                    }
                    .padding(.top, 4)
                }

                if !appState.hasPremiumAccess, subscriptionService.hasIntroductoryOffer {
                    Text(L10n.paywallFreeTrialBadge)
                        .font(.caption2.weight(.bold))
                        .tracking(0.5)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(AppColors.paywallGreen)
                        .clipShape(Capsule())
                        .offset(x: 4, y: -4)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                .fill(Color(hex: 0x0D0D12).opacity(0.85))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            AppColors.accentPurple.opacity(0.9),
                            AppColors.accentBlue.opacity(0.6),
                            AppColors.accentPurple.opacity(0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1.5
                )
        )
        .shadow(color: AppColors.accentPurple.opacity(0.25), radius: 20, y: 4)
    }

    private var bottomSection: some View {
        VStack(spacing: 16) {
            if !appState.hasPremiumAccess {
                Button {
                    Task { await performPurchase() }
                } label: {
                    Group {
                        if subscriptionService.isPurchasing {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(viewModel.purchaseButtonTitle(from: subscriptionService))
                                .font(.headline.weight(.bold))
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [AppColors.accentBlue, AppColors.accentPurple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .disabled(
                    subscriptionService.isPurchasing
                        || subscriptionService.isLoading
                        || subscriptionService.product == nil
                )
                .opacity(subscriptionService.product == nil ? 0.5 : 1)
            }

            Text(L10n.paywallAutoRenewDisclaimer)
                .font(.caption2)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 6) {
                footerLink(L10n.paywallFooterTerms) {
                    openURL(AppLegalLinks.termsOfUse)
                }
                Text("•")
                    .foregroundStyle(AppColors.textSecondary.opacity(0.5))
                footerLink(L10n.paywallFooterRestore) {
                    Task { await performRestore() }
                }
                Text("•")
                    .foregroundStyle(AppColors.textSecondary.opacity(0.5))
                footerLink(L10n.paywallFooterPrivacy) {
                    openURL(AppLegalLinks.privacyPolicy)
                }
            }
        }
    }

    private func performPurchase() async {
        do {
            try await appState.purchaseSubscription()
        } catch SubscriptionError.userCancelled {
            return
        } catch {
            presentError(error)
        }
    }

    private func performRestore() async {
        do {
            try await appState.restorePurchases()
        } catch {
            presentError(error)
        }
    }

    private func presentError(_ error: Error) {
        alertMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        showAlert = true
    }

    private func footerLink(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption2.weight(.medium))
                .tracking(0.3)
                .foregroundStyle(AppColors.textSecondary.opacity(0.7))
                .textCase(.uppercase)
        }
        .buttonStyle(.plain)
        .disabled(subscriptionService.isLoading)
    }
}
