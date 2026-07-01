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
                Spacer().frame(height: 12)

                if appState.hasPremiumAccess {
                    statusBanner
                        .padding(.horizontal, AppTheme.horizontalPadding)
                        .padding(.bottom, 16)
                }

                productSection
                    .padding(.horizontal, AppTheme.horizontalPadding)

                if !appState.hasPremiumAccess {
                    bottomSection
                        .padding(.horizontal, AppTheme.horizontalPadding)
                        .padding(.top, 20)
                }

                marketingSection
                    .padding(.top, appState.hasPremiumAccess ? 20 : 28)
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

    private var marketingSection: some View {
        VStack(spacing: 16) {
            PaywallCarouselView()
                .padding(.horizontal, AppTheme.horizontalPadding)

            Text(L10n.paywallTitle)
                .font(.title3.weight(.bold))
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.horizontalPadding)

            Text(L10n.paywallSubtitle)
                .font(.footnote)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppTheme.horizontalPadding)
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
            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.productTitle(from: subscriptionService))
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppColors.textPrimary)

                if let length = subscriptionService.subscriptionLengthDescription {
                    Text(length)
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.billedAmountLabel(from: subscriptionService))
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(AppColors.textPrimary)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)

                if let trialFootnote = viewModel.trialFootnote(from: subscriptionService) {
                    Text(trialFootnote)
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary.opacity(0.85))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Divider()
                .overlay(AppColors.border.opacity(0.35))

            Text(L10n.paywallServicesIncluded)
                .font(.caption.weight(.semibold))
                .tracking(0.6)
                .foregroundStyle(AppColors.paywallLavender)

            VStack(alignment: .leading, spacing: 12) {
                ForEach(viewModel.features(from: subscriptionService), id: \.self) { feature in
                    PaywallFeatureRow(text: feature)
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
        VStack(spacing: 14) {
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
                            .multilineTextAlignment(.center)
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

            legalLinksRow

            Text(L10n.paywallAutoRenewDisclaimer)
                .font(.caption2)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var legalLinksRow: some View {
        HStack(spacing: 0) {
            legalLink(L10n.paywallFooterTerms) {
                openURL(AppLegalLinks.termsOfUse)
            }
            Text("•")
                .font(.footnote)
                .foregroundStyle(AppColors.textSecondary.opacity(0.5))
            legalLink(L10n.paywallFooterPrivacy) {
                openURL(AppLegalLinks.privacyPolicy)
            }
            Text("•")
                .font(.footnote)
                .foregroundStyle(AppColors.textSecondary.opacity(0.5))
            legalLink(L10n.paywallFooterRestore) {
                Task { await performRestore() }
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

    private func legalLink(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(AppColors.paywallLavender)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .disabled(subscriptionService.isLoading)
    }
}
