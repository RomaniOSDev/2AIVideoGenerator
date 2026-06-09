import Foundation

enum WaveSpeedUploadParsing {
    private static let urlKeys = [
        "download_url", "downloadUrl", "url", "file_url", "link", "file", "href"
    ]

    private static let nestedPaths: [[String]] = [
        ["data", "download_url"],
        ["data", "downloadUrl"],
        ["data", "url"],
        ["data", "file_url"],
        ["data", "link"],
        ["data", "file"],
        ["data", "href"]
    ]

    static func parseURL(from data: Data) throws -> String {
        let json = try WaveSpeedJSONHelpers.object(from: data)
        try WaveSpeedJSONHelpers.validateResponseCode(in: json)

        if let value = WaveSpeedJSONHelpers.stringValue(in: json, keys: urlKeys) {
            return value
        }

        if let value = WaveSpeedJSONHelpers.nestedString(in: json, paths: nestedPaths) {
            return value
        }

        throw WaveSpeedError.decodingFailed("Upload response missing media URL.")
    }
}
