import Foundation

final class AIProcessingConsentService {
    static let shared = AIProcessingConsentService()

    private let consentKey = "hasAIProcessingConsent"
    private let legacyPhotoConsentKey = "hasPhotoUploadConsent"

    private init() {}

    var hasUserConsent: Bool {
        UserDefaults.standard.bool(forKey: consentKey)
            || UserDefaults.standard.bool(forKey: legacyPhotoConsentKey)
    }

    func grantConsent() {
        UserDefaults.standard.set(true, forKey: consentKey)
    }
}
