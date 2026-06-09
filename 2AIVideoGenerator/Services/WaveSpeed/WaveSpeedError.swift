import Foundation

enum WaveSpeedError: Error, LocalizedError, Sendable {
    case invalidAPIKey
    case invalidResponse
    case decodingFailed(String?)
    case network(statusCode: Int, message: String?)
    case missingTaskID
    case predictionFailed(String?)
    case timeout
    case emptyOutputs
    case unsupportedOutputFormat
    case invalidVideoData
    case cancelled

    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            "Invalid WaveSpeed API key."
        case .invalidResponse:
            "Invalid server response."
        case .decodingFailed(let detail):
            detail.map { "Failed to decode response: \($0)" } ?? "Failed to decode response."
        case .network(let code, let message):
            message.map { "Network error (\(code)): \($0)" } ?? "Network error (\(code))."
        case .missingTaskID:
            "Missing task ID in submit response."
        case .predictionFailed(let message):
            message.map { "Generation failed: \($0)" } ?? "Generation failed."
        case .timeout:
            "Generation timed out."
        case .emptyOutputs:
            "Generation completed without output."
        case .unsupportedOutputFormat:
            "Unsupported output format."
        case .invalidVideoData:
            "Downloaded data is not a valid video file."
        case .cancelled:
            "Generation was cancelled."
        }
    }
}
