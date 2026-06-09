import SwiftUI

struct HomeModelCardView: View {
    let model: AIModelOption
    let isSelected: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let badge = model.badges.first {
                Text(badge)
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(isSelected ? AppColors.accentPurple : AppColors.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(
                        (isSelected ? AppColors.accentPurple : AppColors.border)
                            .opacity(0.2)
                    )
                    .clipShape(Capsule())
            }

            Text(model.title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(model.subtitle)
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous)
                .fill(
                    isSelected
                        ? LinearGradient(
                            colors: [
                                AppColors.accentPurple.opacity(0.25),
                                AppColors.accentBlue.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [AppColors.surface, AppColors.surface],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous)
                .stroke(
                    isSelected
                        ? LinearGradient(
                            colors: [AppColors.accentPurple, AppColors.accentBlue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        : LinearGradient(
                            colors: [AppColors.border.opacity(0.4), AppColors.border.opacity(0.4)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                    lineWidth: isSelected ? 2 : 1
                )
        )
        .shadow(color: isSelected ? AppColors.accentPurple.opacity(0.3) : .clear, radius: 12, y: 4)
    }
}
