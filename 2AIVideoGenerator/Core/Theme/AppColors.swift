import SwiftUI

enum AppColors {
    static let background = Color(hex: 0x0A0A0F)
    static let surface = Color(hex: 0x14141C)
    static let surfaceElevated = Color(hex: 0x1C1C28)
    static let border = Color(hex: 0x4B5563)
    static let textPrimary = Color.white
    static let textSecondary = Color(hex: 0x9CA3AF)
    static let accentPurple = Color(hex: 0x7C3AED)
    static let accentBlue = Color(hex: 0x3B5BDB)
    static let success = Color(hex: 0x10B981)
    static let warning = Color(hex: 0xF59E0B)
    static let paywallGreen = Color(hex: 0x00C896)
    static let paywallLavender = Color(hex: 0xC4B5FD)

    static let gradientPrimary = LinearGradient(
        colors: [accentPurple, accentBlue],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let gradientBackground = LinearGradient(
        colors: [Color(hex: 0x0A0A0F), Color(hex: 0x12121A), Color(hex: 0x0A0A0F)],
        startPoint: .top,
        endPoint: .bottom
    )
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}
