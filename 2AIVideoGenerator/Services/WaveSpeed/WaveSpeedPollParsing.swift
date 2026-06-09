import Foundation

enum WaveSpeedPollParsing {
    private static let failedStatuses: Set<String> = [
        "failed", "error", "canceled", "cancelled"
    ]

    private static let successStatuses: Set<String> = [
        "completed", "succeeded", "success"
    ]

    struct PollResult: Sendable {
        let isComplete: Bool
        let isFailed: Bool
        let output: String?
        let errorMessage: String?
    }

    static func parse(data: Data) throws -> PollResult {
        let json = try WaveSpeedJSONHelpers.object(from: data)
        try WaveSpeedJSONHelpers.validateResponseCode(in: json)

        let status = extractStatus(from: json)?.lowercased()
        let outputs = extractOutputs(from: json)
        let errorMessage = extractError(from: json)

        if let status, failedStatuses.contains(status) {
            return PollResult(isComplete: true, isFailed: true, output: nil, errorMessage: errorMessage)
        }

        if let status, successStatuses.contains(status), let output = outputs.first {
            return PollResult(isComplete: true, isFailed: false, output: output, errorMessage: nil)
        }

        if let output = outputs.first, status == nil {
            return PollResult(isComplete: true, isFailed: false, output: output, errorMessage: nil)
        }

        return PollResult(isComplete: false, isFailed: false, output: nil, errorMessage: errorMessage)
    }

    private static func extractStatus(from json: [String: Any]) -> String? {
        WaveSpeedJSONHelpers.nestedString(in: json, paths: [
            ["data", "status"],
            ["status"]
        ])
    }

    private static func extractOutputs(from json: [String: Any]) -> [String] {
        let candidates: [Any?] = [
            WaveSpeedJSONHelpers.nestedValue(in: json, path: ["data", "outputs"]),
            json["outputs"]
        ]

        for candidate in candidates {
            let strings = WaveSpeedJSONHelpers.stringArray(in: candidate)
            if !strings.isEmpty { return strings }
        }
        return []
    }

    private static func extractError(from json: [String: Any]) -> String? {
        WaveSpeedJSONHelpers.nestedString(in: json, paths: [
            ["data", "error"],
            ["data", "message"],
            ["error"],
            ["message"]
        ])
    }
}
