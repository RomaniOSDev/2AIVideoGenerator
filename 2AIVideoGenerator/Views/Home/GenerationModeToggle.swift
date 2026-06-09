import SwiftUI

struct GenerationModeToggle: View {
    @Binding var selected: GenerationMode

    var body: some View {
        HStack(spacing: 0) {
            ForEach(GenerationMode.allCases) { mode in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selected = mode
                    }
                } label: {
                    Text(mode.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(selected == mode ? .black : AppColors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            selected == mode
                                ? AnyShapeStyle(Color.white)
                                : AnyShapeStyle(Color.clear)
                        )
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(AppColors.surface)
        .clipShape(Capsule())
    }
}
