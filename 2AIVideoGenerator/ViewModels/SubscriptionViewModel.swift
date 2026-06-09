import Foundation

@MainActor
@Observable
final class SubscriptionViewModel {
    let plan = SubscriptionPlan.weekly

    func priceLabel(from service: SubscriptionService) -> String {
        if let price = service.displayPrice, let period = service.subscriptionPeriodLabel {
            return L10n.paywallTrialThenPriceDynamic(price, period)
        }
        return L10n.paywallTrialThenPrice
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
