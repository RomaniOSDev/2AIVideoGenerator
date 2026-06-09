import Foundation

struct SubscriptionPlan: Identifiable {
    let id: String
    let price: String
    let period: String
    let trialDays: Int
    let features: [String]

    static let weekly = SubscriptionPlan(
        id: "pro_weekly",
        price: "$9.99",
        period: L10n.paywallPerWeek,
        trialDays: 3,
        features: [
            L10n.paywallFeatureModels,
            L10n.paywallFeatureQuality,
            L10n.paywallFeatureNoWatermark,
            L10n.paywallFeaturePriority
        ]
    )
}
