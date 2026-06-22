import Foundation
import StoreKit

@MainActor
protocol SubscriptionServiceProtocol: AnyObject {
    var state: SubscriptionState { get }
    var product: Product? { get }
    var isLoading: Bool { get }
    var isPurchasing: Bool { get }
    var productsLoadError: String? { get }
    var hasIntroductoryOffer: Bool { get }
    var displayPrice: String? { get }
    var subscriptionPeriodLabel: String? { get }

    var isSubscribed: Bool { get }
    var isInTrialPeriod: Bool { get }
    var hasPremiumAccess: Bool { get }
    var trialDaysRemaining: Int { get }

    func loadProducts() async
    func refreshStatus() async
    func purchase() async throws
    func restore() async throws
}
