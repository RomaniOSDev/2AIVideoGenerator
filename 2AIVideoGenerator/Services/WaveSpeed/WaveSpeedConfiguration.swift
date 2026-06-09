import Foundation

enum WaveSpeedConfiguration {
    static let baseURL = URL(string: "https://api.wavespeed.ai/api/v3")!
    static let apiKey = "7ccf6b1f435db7e53d022eb21e947bd45062573393457ff5c47d8e3da310dcaf"

    static let pollIntervalSeconds: UInt64 = 2
    static let maxPollAttempts = 90

    static let downloadRequestTimeout: TimeInterval = 1200
    static let downloadResourceTimeout: TimeInterval = 1800
    static let downloadMaxRetries = 3

    static let defaultVideoResolution = "480p"
    static let prunaVideoResolution = "720p"
}
