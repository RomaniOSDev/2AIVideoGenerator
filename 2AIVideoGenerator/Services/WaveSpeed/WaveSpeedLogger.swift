import Foundation
import os

enum WaveSpeedLogger {
    private static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "AIVideoGenerator",
        category: "WaveSpeed"
    )

    static func info(_ message: String) {
        logger.info("\(message, privacy: .public)")
        debugPrint("[WaveSpeed] ℹ️ \(message)")
    }

    static func debug(_ message: String) {
        logger.debug("\(message, privacy: .public)")
        debugPrint("[WaveSpeed] 🔍 \(message)")
    }

    static func warning(_ message: String) {
        logger.warning("\(message, privacy: .public)")
        debugPrint("[WaveSpeed] ⚠️ \(message)")
    }

    static func error(_ message: String) {
        logger.error("\(message, privacy: .public)")
        debugPrint("[WaveSpeed] ❌ \(message)")
    }

    static func request(_ method: String, url: URL, bodySize: Int? = nil) {
        var message = "\(method) \(url.absoluteString)"
        if let bodySize {
            message += " body=\(bodySize) bytes"
        }
        info(message)
    }

    static func response(_ method: String, url: URL, statusCode: Int, data: Data) {
        let preview = bodyPreview(data)
        info("\(method) \(url.absoluteString) → HTTP \(statusCode), \(data.count) bytes")
        debug("Response preview: \(preview)")
    }

    static func bodyPreview(_ data: Data, maxLength: Int = 1500) -> String {
        if data.isEmpty { return "<empty>" }

        if let text = String(data: data.prefix(maxLength), encoding: .utf8),
           text.contains("{") || text.contains("<") {
            return text
        }

        return "<binary \(data.count) bytes, hex: \(hexPreview(data, length: 24))>"
    }

    static func hexPreview(_ data: Data, length: Int = 16) -> String {
        data.prefix(length).map { String(format: "%02X", $0) }.joined(separator: " ")
    }

    static func outputPreview(_ output: String) -> String {
        if output.hasPrefix("http://") || output.hasPrefix("https://") {
            return output
        }
        if output.hasPrefix("data:") {
            return "data URI (\(output.count) chars)"
        }
        return "base64 (\(output.count) chars), prefix: \(output.prefix(40))..."
    }
}
