import Foundation

enum RandomVideoPrompts {
    private static let keys: [String.LocalizationValue] = [
        "randomPrompt.01", "randomPrompt.02", "randomPrompt.03", "randomPrompt.04",
        "randomPrompt.05", "randomPrompt.06", "randomPrompt.07", "randomPrompt.08",
        "randomPrompt.09", "randomPrompt.10", "randomPrompt.11", "randomPrompt.12",
        "randomPrompt.13", "randomPrompt.14", "randomPrompt.15", "randomPrompt.16",
        "randomPrompt.17", "randomPrompt.18", "randomPrompt.19", "randomPrompt.20"
    ]

    static func random() -> String {
        let key = keys.randomElement() ?? keys[0]
        return String(localized: key)
    }
}
