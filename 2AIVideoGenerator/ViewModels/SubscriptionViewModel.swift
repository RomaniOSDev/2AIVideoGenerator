import Foundation

@MainActor
@Observable
final class SubscriptionViewModel {
    func productTitle(from service: SubscriptionService) -> String {
        service.productDisplayName ?? L10n.paywallProSubscription
    }

    func billedAmountLabel(from service: SubscriptionService) -> String {
        guard let price = service.displayPrice, let period = service.subscriptionPeriodLabel else {
            return L10n.paywallPriceUnavailable
        }
        return L10n.paywallBilledAmount(price, period)
    }

    func trialFootnote(from service: SubscriptionService) -> String? {
        guard service.hasIntroductoryOffer,
              let trialDuration = service.introductoryOfferDurationLabel,
              let price = service.displayPrice,
              let period = service.subscriptionPeriodLabel else {
            return nil
        }
        return L10n.paywallTrialFootnote(trialDuration, price, period)
    }

    func purchaseButtonTitle(from service: SubscriptionService) -> String {
        guard let price = service.displayPrice, let period = service.subscriptionPeriodLabel else {
            return L10n.paywallSubscribe
        }
        return L10n.paywallSubscribeWithPrice(price, period)
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
