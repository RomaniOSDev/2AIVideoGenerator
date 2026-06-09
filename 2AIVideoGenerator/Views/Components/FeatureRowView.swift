import SwiftUI

struct FeatureRowView: View {
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(AppColors.success)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(AppColors.textPrimary)
            Spacer()
        }
    }
}
