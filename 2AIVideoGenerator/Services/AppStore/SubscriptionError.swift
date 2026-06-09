import Foundation

enum SubscriptionError: LocalizedError {
    case productNotFound
    case userCancelled
    case pending
    case verificationFailed
    case restoreFailed
    case unknown

    var errorDescription: String? {
        switch self {
        case .productNotFound: L10n.subscriptionErrorProductNotFound
        case .userCancelled: nil
        case .pending: L10n.subscriptionErrorPending
        case .verificationFailed: L10n.subscriptionErrorVerification
        case .restoreFailed: L10n.subscriptionErrorRestore
        case .unknown: L10n.subscriptionErrorUnknown
        }
    }
}
