import Foundation

enum WaveSpeedConfiguration {
    static let baseURL = URL(string: "https://api.wavespeed.ai/api/v3")!
    static let apiKey = "wsk_live_RfQQm5EOZGc7Tlxo0gBTbRrudB6-uOaoga9_GkcZrU4"

    static let pollIntervalSeconds: UInt64 = 2
    static let maxPollAttempts = 90

    static let downloadRequestTimeout: TimeInterval = 1200
    static let downloadResourceTimeout: TimeInterval = 1800
    static let downloadMaxRetries = 3

    static let defaultVideoResolution = "480p"
    static let prunaVideoResolution = "720p"
}
