import SwiftUI

struct ChipSelectorView<T: Hashable>: View {
    let items: [T]
    let selected: T
    let label: (T) -> String
    let onSelect: (T) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(items, id: \.self) { item in
                Button {
                    onSelect(item)
                } label: {
                    Text(label(item))
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(selected == item ? .white : AppColors.textSecondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            selected == item
                                ? AnyShapeStyle(AppColors.gradientPrimary)
                                : AnyShapeStyle(AppColors.surface)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall, style: .continuous)
                                .stroke(
                                    selected == item ? Color.clear : AppColors.border.opacity(0.4),
                                    lineWidth: 1
                                )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }
}
