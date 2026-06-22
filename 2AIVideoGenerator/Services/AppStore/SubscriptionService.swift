import Foundation
import StoreKit

@MainActor
@Observable
final class SubscriptionService: SubscriptionServiceProtocol {
    private(set) var state = SubscriptionState()
    private(set) var product: Product?
    private(set) var isLoading = false
    private(set) var isPurchasing = false
    private(set) var productsLoadError: String?

    private nonisolated(unsafe) var transactionListener: Task<Void, Never>?

    var displayPrice: String? {
        product?.displayPrice
    }

    var subscriptionPeriodLabel: String? {
        guard let period = product?.subscription?.subscriptionPeriod else { return nil }
        switch period.unit {
        case .week: return L10n.paywallPerWeek
        case .month: return L10n.subscriptionPerMonth
        case .year: return L10n.subscriptionPerYear
        default: return nil
        }
    }

    var hasIntroductoryOffer: Bool {
        product?.subscription?.introductoryOffer != nil
    }

    var isSubscribed: Bool {
        state.isActive && !state.isInIntroOffer
    }

    var isInTrialPeriod: Bool {
        state.isActive && state.isInIntroOffer
    }

    var hasPremiumAccess: Bool {
        state.isActive
    }

    var trialDaysRemaining: Int {
        state.trialDaysRemaining
    }

    init() {
        transactionListener = listenForTransactions()
        Task {
            await loadProducts()
            await refreshStatus()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    func loadProducts() async {
        isLoading = true
        productsLoadError = nil
        defer { isLoading = false }

        do {
            let products = try await Product.products(for: [SubscriptionProductIDs.proWeekly])
            guard let loadedProduct = products.first else {
                product = nil
                productsLoadError = L10n.subscriptionErrorProductNotFound
                return
            }
            product = loadedProduct
        } catch {
            product = nil
            productsLoadError = error.localizedDescription
        }
    }

    func refreshStatus() async {
        var newState = SubscriptionState()

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            guard transaction.productID == SubscriptionProductIDs.proWeekly else { continue }
            guard transaction.revocationDate == nil else { continue }

            if let expiration = transaction.expirationDate, expiration < Date() {
                continue
            }

            newState.isActive = true
            newState.isInIntroOffer = transaction.offerType == .introductory
            newState.expirationDate = transaction.expirationDate
            newState.willAutoRenew = true
        }

        if let product, newState.isActive {
            if let statuses = try? await product.subscription?.status,
               let status = statuses.first,
               case .verified(let renewalInfo) = status.renewalInfo {
                newState.willAutoRenew = renewalInfo.willAutoRenew
            }
        }

        state = newState
    }

    func purchase() async throws {
        guard let product else { throw SubscriptionError.productNotFound }

        isPurchasing = true
        defer { isPurchasing = false }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try verify(verification)
            await transaction.finish()
            await refreshStatus()
        case .userCancelled:
            throw SubscriptionError.userCancelled
        case .pending:
            throw SubscriptionError.pending
        @unknown default:
            throw SubscriptionError.unknown
        }
    }

    func restore() async throws {
        isLoading = true
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await refreshStatus()
            guard state.isActive else { throw SubscriptionError.restoreFailed }
        } catch let error as SubscriptionError {
            throw error
        } catch {
            throw SubscriptionError.restoreFailed
        }
    }

    // MARK: - Private

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                guard let self else { continue }
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self.refreshStatus()
                }
            }
        }
    }

    private func verify<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value):
            return value
        case .unverified:
            throw SubscriptionError.verificationFailed
        }
    }
}
