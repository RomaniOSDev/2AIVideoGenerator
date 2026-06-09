import Foundation

enum WaveSpeedJSONHelpers {
    static func object(from data: Data) throws -> [String: Any] {
        guard let object = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw WaveSpeedError.decodingFailed("Root is not a JSON object.")
        }
        return object
    }

    static func validateResponseCode(in json: [String: Any]) throws {
        guard let code = intValue(in: json, keys: ["code"]) else { return }
        guard code == 200 else {
            let message = stringValue(in: json, keys: ["message", "error", "msg"])
            throw WaveSpeedError.predictionFailed(message)
        }
    }

    static func stringValue(in json: [String: Any], keys: [String]) -> String? {
        for key in keys {
            if let value = json[key] as? String, !value.isEmpty {
                return value
            }
        }
        return nil
    }

    static func nestedString(in json: [String: Any], paths: [[String]]) -> String? {
        for path in paths {
            if let value = nestedValue(in: json, path: path) as? String, !value.isEmpty {
                return value
            }
        }
        return nil
    }

    static func nestedValue(in json: [String: Any], path: [String]) -> Any? {
        var current: Any = json
        for key in path {
            guard let dict = current as? [String: Any], let next = dict[key] else {
                return nil
            }
            current = next
        }
        return current
    }

    static func intValue(in json: [String: Any], keys: [String]) -> Int? {
        for key in keys {
            if let value = json[key] as? Int { return value }
            if let value = json[key] as? String, let intValue = Int(value) { return intValue }
        }
        return nil
    }

    static func firstString(in value: Any?) -> String? {
        if let string = value as? String, !string.isEmpty { return string }
        if let array = value as? [Any] {
            for item in array {
                if let string = item as? String, !string.isEmpty { return string }
            }
        }
        return nil
    }

    static func stringArray(in value: Any?) -> [String] {
        guard let array = value as? [Any] else { return [] }
        return array.compactMap { item in
            guard let string = item as? String, !string.isEmpty else { return nil }
            return string
        }
    }
}
