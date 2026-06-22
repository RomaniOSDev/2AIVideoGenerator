import Foundation

@MainActor
@Observable
final class SubscriptionViewModel {
    func priceLabel(from service: SubscriptionService) -> String {
        guard let price = service.displayPrice, let period = service.subscriptionPeriodLabel else {
            return L10n.paywallPriceUnavailable
        }

        if service.hasIntroductoryOffer {
            return L10n.paywallTrialThenPriceDynamic(price, period)
        }

        return L10n.paywallPriceDynamic(price, period)
    }

    func purchaseButtonTitle(from service: SubscriptionService) -> String {
        if service.hasIntroductoryOffer {
            return L10n.paywallStartTrial
        }
        return L10n.paywallSubscribe
    }

    func features(from service: SubscriptionService) -> [String] {
        [
            L10n.paywallFeatureModels,
            L10n.paywallFeatureQuality,
            L10n.paywallFeatureNoWatermark,
            L10n.paywallFeaturePriority
        ]
    }

    func statusLabel(isPro: Bool, isInTrial: Bool) -> String {
        if isPro {
            L10n.profileProPlan
        } else if isInTrial {
            L10n.profileTrialPlan
        } else {
            L10n.profileFreePlan
        }
    }

    func statusDetail(isPro: Bool, isInTrial: Bool, daysRemaining: Int) -> String? {
        if isPro {
            return L10n.profileSubscriptionActive
        }
        if isInTrial {
            return String(format: L10n.profileTrialDaysLeft, daysRemaining)
        }
        return nil
    }
}
