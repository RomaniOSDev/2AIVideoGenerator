import SwiftUI

struct AIProcessingConsentSheet: View {
    let onAllow: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            sheetHandle
                .padding(.top, 10)
                .padding(.bottom, 4)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    heroImage
                    headerSection
                    infoCard
                    legalLinks
                }
                .padding(.horizontal, AppTheme.horizontalPadding)
                .padding(.bottom, 16)
            }

            bottomActions
                .padding(.horizontal, AppTheme.horizontalPadding)
                .padding(.top, 8)
                .padding(.bottom, 24)
                .background {
                    LinearGradient(
                        colors: [Color(hex: 0x0A0A0F).opacity(0), Color(hex: 0x0A0A0F)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea(edges: .bottom)
                }
        }
        .appBackground()
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }

    private var sheetHandle: some View {
        Capsule()
            .fill(AppColors.border.opacity(0.55))
            .frame(width: 40, height: 5)
    }

    private var heroImage: some View {
        Image("AIConsentHero")
            .resizable()
            .scaledToFill()
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                AppColors.accentPurple.opacity(0.45),
                                AppColors.accentBlue.opacity(0.2),
                                Color.clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: AppColors.accentPurple.opacity(0.25), radius: 24, y: 12)
    }

    private var headerSection: some View {
        VStack(spacing: 10) {
            Text(L10n.aiConsentTitle)
                .font(.title2.weight(.bold))
                .foregroundStyle(AppColors.textPrimary)
                .multilineTextAlignment(.center)

            Text(L10n.aiConsentSubtitle)
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            consentPoint(icon: "text.alignleft", text: L10n.aiConsentPointPrompt)
            consentPoint(icon: "photo.on.rectangle.angled", text: L10n.aiConsentPointPhoto)
            consentPoint(icon: "lock.shield.fill", text: L10n.aiConsentPointPurpose)

            Divider()
                .overlay(AppColors.border.opacity(0.35))

            Text(L10n.aiConsentMessage)
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                .fill(AppColors.surfaceElevated.opacity(0.92))
                .background {
                    RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                        .fill(.ultraThinMaterial)
                }
        }
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                .stroke(AppColors.border.opacity(0.35), lineWidth: 1)
        }
    }

    private var legalLinks: some View {
        HStack(spacing: 0) {
            legalLink(title: L10n.profilePrivacy, icon: "hand.raised.fill", url: AppLegalLinks.privacyPolicy)
            divider
            legalLink(title: L10n.profileTerms, icon: "doc.text.fill", url: AppLegalLinks.termsOfUse)
        }
        .padding(.vertical, 4)
    }

    private var divider: some View {
        Rectangle()
            .fill(AppColors.border.opacity(0.35))
            .frame(width: 1, height: 28)
    }

    private var bottomActions: some View {
        VStack(spacing: 12) {
            Button(action: onAllow) {
                Text(L10n.aiConsentAllow)
            }
            .buttonStyle(PrimaryButtonStyle())

            Button(L10n.cancel, action: onCancel)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppColors.textSecondary)
        }
    }

    private func consentPoint(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(AppColors.accentPurple.opacity(0.18))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(AppColors.accentPurple)
            }

            Text(text)
                .font(.subheadline)
                .foregroundStyle(AppColors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 8)

            Spacer(minLength: 0)
        }
    }

    private func legalLink(title: String, icon: String, url: URL) -> some View {
        Link(destination: url) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption.weight(.semibold))
                Text(title)
                    .font(.subheadline.weight(.medium))
            }
            .foregroundStyle(AppColors.paywallLavender)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
        }
    }
}

#Preview {
    AIProcessingConsentSheet(onAllow: {}, onCancel: {})
}
