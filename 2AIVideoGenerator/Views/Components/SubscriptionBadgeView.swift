import SwiftUI

struct SubscriptionBadgeView: View {
    let isPro: Bool
    let isInTrial: Bool
    let trialDaysRemaining: Int
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: iconName)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(iconColor)

                Text(label)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppColors.textPrimary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(AppColors.surfaceElevated)
            .overlay(
                Capsule()
                    .stroke(AppColors.border.opacity(0.5), lineWidth: 1)
            )
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .disabled(onTap == nil)
    }

    private var iconName: String {
        if isPro { "checkmark.seal.fill" }
        else if isInTrial { "gift.fill" }
        else { "crown.fill" }
    }

    private var iconColor: Color {
        if isPro { AppColors.success }
        else if isInTrial { AppColors.accentPurple }
        else { AppColors.warning }
    }

    private var label: String {
        if isPro { L10n.profileProPlan }
        else if isInTrial { String(format: L10n.subscriptionTrialBadge, trialDaysRemaining) }
        else { L10n.profileGetPro }
    }
}
