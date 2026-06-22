import SwiftUI

struct PaywallShowcaseItem: Identifiable {
    let id: Int
    let imageName: String
}

struct PaywallCarouselView: View {
    private let items: [PaywallShowcaseItem] = [
        PaywallShowcaseItem(id: 0, imageName: "Paywall1"),
        PaywallShowcaseItem(id: 1, imageName: "Paywall2"),
        PaywallShowcaseItem(id: 2, imageName: "Paywall3")
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
        Image(item.imageName)
            .resizable()
            .scaledToFill()
            .frame(width: isCenter ? 155 : 120, height: isCenter ? 190 : 150)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color.white.opacity(isCenter ? 0.18 : 0.08), lineWidth: 1)
            }
            .scaleEffect(isCenter ? 1 : 0.92)
            .opacity(isCenter ? 1 : 0.5)
            .animation(.easeInOut(duration: 0.25), value: isCenter)
    }
}
