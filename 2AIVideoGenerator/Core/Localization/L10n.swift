import Foundation

enum L10n {
    // MARK: - Common
    static let skip = String(localized: "common.skip")
    static let next = String(localized: "common.next")
    static let close = String(localized: "common.close")
    static let cancel = String(localized: "common.cancel")
    static let done = String(localized: "common.done")
    static let all = String(localized: "common.all")
    static let guest = String(localized: "common.guest")

    // MARK: - Tabs
    static let tabCreate = String(localized: "tab.create")
    static let tabGallery = String(localized: "tab.gallery")
    static let tabSubscription = String(localized: "tab.subscription")

    // MARK: - Onboarding
    static let onboardingTitle1 = String(localized: "onboarding.title1")
    static let onboardingSubtitle1 = String(localized: "onboarding.subtitle1")
    static let onboardingTitle2 = String(localized: "onboarding.title2")
    static let onboardingSubtitle2 = String(localized: "onboarding.subtitle2")
    static let onboardingTitle3 = String(localized: "onboarding.title3")
    static let onboardingSubtitle3 = String(localized: "onboarding.subtitle3")
    static let getStartedFree = String(localized: "onboarding.getStarted")

    // MARK: - Home / Create
    static let createTextToVideo = String(localized: "create.textToVideo")
    static let createImageToVideo = String(localized: "create.imageToVideo")
    static let createAiModels = String(localized: "create.aiModels")
    static let createPromptPlaceholder = String(localized: "create.promptPlaceholder")
    static let createDurationSection = String(localized: "create.durationSection")
    static let createGenerateVideo = String(localized: "create.generateVideo")
    static let createEnhance = String(localized: "create.enhance")
    static let createRandom = String(localized: "create.random")
    static let createRecentGenerations = String(localized: "create.recentGenerations")
    static let createMyGallery = String(localized: "create.myGallery")
    static let createViewAll = String(localized: "create.viewAll")
    static let createSeconds = String(localized: "create.seconds")
    static let createSelectImage = String(localized: "create.selectImage")
    static let createChooseFromLibrary = String(localized: "create.chooseFromLibrary")
    static let createTakePhoto = String(localized: "create.takePhoto")
    static let createChangeImage = String(localized: "create.changeImage")
    static let createImagePickerHint = String(localized: "create.imagePickerHint")
    static let createImagePromptPlaceholder = String(localized: "create.imagePromptPlaceholder")
    static let createCameraUnavailable = String(localized: "create.cameraUnavailable")
    static let createCameraUnavailableMessage = String(localized: "create.cameraUnavailableMessage")

    // MARK: - AI consent
    static let aiConsentTitle = String(localized: "ai.consentTitle")
    static let aiConsentSubtitle = String(localized: "ai.consentSubtitle")
    static let aiConsentMessage = String(localized: "ai.consentMessage")
    static let aiConsentPointPrompt = String(localized: "ai.consentPointPrompt")
    static let aiConsentPointPhoto = String(localized: "ai.consentPointPhoto")
    static let aiConsentPointPurpose = String(localized: "ai.consentPointPurpose")
    static let aiConsentAllow = String(localized: "ai.consentAllow")

    // MARK: - Models
    static let modelRunwayGen4 = String(localized: "model.runwayGen4")
    static let modelRunwayGen4Desc = String(localized: "model.runwayGen4Desc")
    static let modelRunwayTurbo = String(localized: "model.runwayTurbo")
    static let modelRunwayTurboDesc = String(localized: "model.runwayTurboDesc")
    static let modelVeo31 = String(localized: "model.veo31")
    static let modelVeo31Desc = String(localized: "model.veo31Desc")
    static let badgeHD = String(localized: "model.badgeHD")
    static let badgeHDAudio = String(localized: "model.badgeHDAudio")
    static let badgeAudio = String(localized: "model.badgeAudio")
    static let badgeFast = String(localized: "model.badgeFast")

    // MARK: - Aspect
    static let aspectPortrait = String(localized: "aspect.portrait")
    static let aspectLandscape = String(localized: "aspect.landscape")
    static let aspectSquare = String(localized: "aspect.square")

    // MARK: - Gallery
    static let galleryEmptyTitle = String(localized: "gallery.emptyTitle")
    static let galleryEmptySubtitle = String(localized: "gallery.emptySubtitle")
    static let galleryFilter = String(localized: "gallery.filter")
    static let galleryWatermark = String(localized: "gallery.watermark")

    // MARK: - Generation
    static let generationStatusPreparing = String(localized: "generation.statusPreparing")
    static let generationStatusUploading = String(localized: "generation.statusUploading")
    static let generationStatusSubmitting = String(localized: "generation.statusSubmitting")
    static let generationStatusFrames = String(localized: "generation.statusFrames")
    static let generationStatusRendering = String(localized: "generation.statusRendering")
    static let generationErrorTitle = String(localized: "generation.errorTitle")
    static let generationTimeRemaining = String(localized: "generation.timeRemaining")
    static let generationPromptPreview = String(localized: "generation.promptPreview")
    static let generationCancel = String(localized: "generation.cancel")

    // MARK: - Video Detail
    static let videoShare = String(localized: "video.share")
    static let videoSave = String(localized: "video.save")
    static let videoSaved = String(localized: "video.saved")
    static let videoDelete = String(localized: "video.delete")
    static let videoPrompt = String(localized: "video.prompt")
    static let videoUnavailable = String(localized: "video.unavailable")
    static let videoSaveAccessDenied = String(localized: "video.saveAccessDenied")

    // MARK: - Subscription status
    static let profileSubscription = String(localized: "profile.subscription")
    static let profileFreePlan = String(localized: "profile.freePlan")
    static let profileProPlan = String(localized: "profile.proPlan")
    static let profileTrialPlan = String(localized: "profile.trialPlan")
    static let profileGetPro = String(localized: "profile.getPro")
    static let profileSubscribe = String(localized: "profile.subscribe")
    static let profileRestore = String(localized: "profile.restore")
    static let profilePrivacy = String(localized: "profile.privacy")
    static let profileTerms = String(localized: "profile.terms")
    static let profileSubscriptionActive = String(localized: "profile.subscriptionActive")
    static let profileTrialDaysLeft = String(localized: "profile.trialDaysLeft")

    // MARK: - Paywall
    static let paywallTitle = String(localized: "paywall.title")
    static let paywallSubtitle = String(localized: "paywall.subtitle")
    static let paywallFreeTrialBadge = String(localized: "paywall.freeTrialBadge")
    static let paywallProSubscription = String(localized: "paywall.proSubscription")
    static let paywallStartTrial = String(localized: "paywall.startTrial")
    static let paywallSubscribe = String(localized: "paywall.subscribe")
    static let paywallTrialThenPrice = String(localized: "paywall.trialThenPrice")
    static func paywallTrialThenPriceDynamic(_ price: String, _ period: String) -> String {
        String(format: String(localized: "paywall.trialThenPriceDynamic"), price, period)
    }
    static func paywallPriceDynamic(_ price: String, _ period: String) -> String {
        String(format: String(localized: "paywall.priceDynamic"), price, period)
    }
    static let paywallPriceUnavailable = String(localized: "paywall.priceUnavailable")
    static let paywallLoadingProducts = String(localized: "paywall.loadingProducts")
    static let paywallProductsLoadFailed = String(localized: "paywall.productsLoadFailed")
    static let paywallReloadProducts = String(localized: "paywall.reloadProducts")
    static let paywallAutoRenewDisclaimer = String(localized: "paywall.autoRenewDisclaimer")
    static let paywallFeatureModels = String(localized: "paywall.featureModels")
    static let paywallFeatureQuality = String(localized: "paywall.featureQuality")
    static let paywallFeatureNoWatermark = String(localized: "paywall.featureNoWatermark")
    static let paywallFeaturePriority = String(localized: "paywall.featurePriority")
    static let paywallPerWeek = String(localized: "paywall.perWeek")
    static let paywallFooterTerms = String(localized: "paywall.footerTerms")
    static let paywallFooterRestore = String(localized: "paywall.footerRestore")
    static let paywallFooterPrivacy = String(localized: "paywall.footerPrivacy")

    // MARK: - Subscription badge
    static let subscriptionTrialBadge = String(localized: "subscription.trialBadge")
    static let subscriptionPerMonth = String(localized: "subscription.perMonth")
    static let subscriptionPerYear = String(localized: "subscription.perYear")

    // MARK: - Subscription errors
    static let subscriptionErrorTitle = String(localized: "subscription.errorTitle")
    static let subscriptionErrorProductNotFound = String(localized: "subscription.errorProductNotFound")
    static let subscriptionErrorPending = String(localized: "subscription.errorPending")
    static let subscriptionErrorVerification = String(localized: "subscription.errorVerification")
    static let subscriptionErrorRestore = String(localized: "subscription.errorRestore")
    static let subscriptionErrorUnknown = String(localized: "subscription.errorUnknown")

    // MARK: - Provider filter
    static let providerRunway = String(localized: "provider.runway")
    static let providerVeo = String(localized: "provider.veo")
}
