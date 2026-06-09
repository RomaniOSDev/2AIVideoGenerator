import SwiftUI

struct PaywallFeatureRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "checkmark")
                .font(.caption2.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 20, height: 20)
                .background(AppColors.paywallGreen)
                .clipShape(Circle())

            Text(text)
                .font(.subheadline)
                .foregroundStyle(AppColors.textPrimary.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
    }
}
