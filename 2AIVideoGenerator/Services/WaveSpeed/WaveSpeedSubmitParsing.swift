import Foundation

enum WaveSpeedSubmitParsing {
    private static let taskIDKeys = ["id", "task_id", "taskId", "request_id", "prediction_id"]
    private static let taskIDPaths: [[String]] = [
        ["data", "id"],
        ["data", "task_id"],
        ["data", "taskId"],
        ["data", "request_id"],
        ["data", "prediction_id"],
        ["result", "id"],
        ["result", "task_id"],
        ["result", "taskId"],
        ["result", "request_id"],
        ["result", "prediction_id"]
    ]

    static func parse(data: Data, baseURL: URL) throws -> SubmitOutcome {
        let json = try WaveSpeedJSONHelpers.object(from: data)
        try WaveSpeedJSONHelpers.validateResponseCode(in: json)

        guard let taskID = extractTaskID(from: json) else {
            throw WaveSpeedError.missingTaskID
        }

        let pollURL = extractPollURL(from: json, taskID: taskID, baseURL: baseURL)
        return SubmitOutcome(taskID: taskID, pollURL: pollURL)
    }

    private static func extractTaskID(from json: [String: Any]) -> String? {
        if let value = WaveSpeedJSONHelpers.stringValue(in: json, keys: taskIDKeys) {
            return value
        }
        return WaveSpeedJSONHelpers.nestedString(in: json, paths: taskIDPaths)
    }

    private static func extractPollURL(from json: [String: Any], taskID: String, baseURL: URL) -> URL {
        if let urlString = WaveSpeedJSONHelpers.nestedString(in: json, paths: [["data", "urls", "get"]]),
           let url = URL(string: urlString) {
            return url
        }
        return baseURL.appendingPathComponent("predictions/\(taskID)/result")
    }
}
