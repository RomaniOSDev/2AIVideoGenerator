import SwiftUI

struct DurationSliderView: View {
    @Binding var value: Double
    let durations: [Int]

    var body: some View {
        VStack(spacing: 10) {
            Slider(value: $value, in: 0...Double(durations.count - 1), step: 1)
                .tint(AppColors.textPrimary)

            HStack {
                ForEach(Array(durations.enumerated()), id: \.offset) { index, duration in
                    if index > 0 { Spacer() }
                    Text("\(duration)\(L10n.createSeconds)")
                        .font(.caption)
                        .foregroundStyle(
                            Int(value.rounded()) == index
                                ? AppColors.textPrimary
                                : AppColors.textSecondary
                        )
                }
            }
        }
    }
}
