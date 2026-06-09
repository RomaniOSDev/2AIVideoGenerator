import SwiftUI

struct PaywallShowcaseItem: Identifiable {
    let id: Int
    let colors: [UInt]
}

struct PaywallCarouselView: View {
    private let items: [PaywallShowcaseItem] = [
        PaywallShowcaseItem(id: 0, colors: [0x1A3A5C, 0x0D1B2A, 0x2D6A8F]),
        PaywallShowcaseItem(id: 1, colors: [0x5C3D2E, 0x8B5A3C, 0xD4A574]),
        PaywallShowcaseItem(id: 2, colors: [0x1B2D4A, 0x3D5A80, 0x6B8CAE])
    ]

    @State private var selectedIndex = 1

    var body: some View {
        HStack(spacing: 14) {
            ForEach(items) { item in
                showcaseCard(item, isCenter: item.id == selectedIndex)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            selectedIndex = item.id
                        }
                    }
            }
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
    }

    private func showcaseCard(_ item: PaywallShowcaseItem, isCenter: Bool) -> some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .fill(
                LinearGradient(
                    colors: item.colors.map { Color(hex: $0) },
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                Image(systemName: "play.fill")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.2))
            }
            .frame(width: isCenter ? 155 : 120, height: isCenter ? 190 : 150)
            .scaleEffect(isCenter ? 1 : 0.92)
            .opacity(isCenter ? 1 : 0.5)
            .animation(.easeInOut(duration: 0.25), value: isCenter)
    }
}
