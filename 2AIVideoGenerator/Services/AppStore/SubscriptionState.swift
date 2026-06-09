import Foundation

struct SubscriptionState: Equatable {
    var isActive: Bool = false
    var isInIntroOffer: Bool = false
    var expirationDate: Date?
    var willAutoRenew: Bool = true

    var trialDaysRemaining: Int {
        guard isInIntroOffer, let expirationDate else { return 0 }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: expirationDate).day ?? 0
        return max(0, days + 1)
    }
}
