import SwiftUI

enum AppTheme {
    static let cornerRadiusSmall: CGFloat = 10
    static let cornerRadiusMedium: CGFloat = 14
    static let cornerRadiusLarge: CGFloat = 20
    static let horizontalPadding: CGFloat = 20
    static let cardRotationRange: ClosedRange<Double> = -4...4
}

struct MainBackgroundView: View {
    var body: some View {
        Image("backMain")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
    }
}

struct AppBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background {
                MainBackgroundView()
            }
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var isEnabled: Bool = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Group {
                    if isEnabled {
                        AppColors.gradientPrimary
                    } else {
                        Color.gray.opacity(0.35)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusMedium, style: .continuous))
            .opacity(configuration.isPressed ? 0.85 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.medium))
            .foregroundStyle(AppColors.textPrimary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(AppColors.surfaceElevated)
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall, style: .continuous)
                    .stroke(AppColors.border.opacity(0.6), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall, style: .continuous))
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

extension View {
    func appBackground() -> some View {
        modifier(AppBackground())
    }
}
