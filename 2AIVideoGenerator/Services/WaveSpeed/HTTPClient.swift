import Foundation

struct HTTPClient: Sendable {
    let apiKey: String
    let baseURL: URL
    let session: URLSession
    let downloadSession: URLSession

    init(
        apiKey: String,
        baseURL: URL = WaveSpeedConfiguration.baseURL,
        session: URLSession = .shared,
        downloadSession: URLSession = HTTPClient.makeDownloadSession()
    ) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.session = session
        self.downloadSession = downloadSession
    }

    static func makeDownloadSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = WaveSpeedConfiguration.downloadRequestTimeout
        configuration.timeoutIntervalForResource = WaveSpeedConfiguration.downloadResourceTimeout
        return URLSession(configuration: configuration)
    }

    func postJSONData(path: String, body: Encodable) async throws -> Data {
        let url = baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try makeEncoder().encode(AnyEncodable(body))

        WaveSpeedLogger.request("POST", url: url, bodySize: request.httpBody?.count)

        do {
            let (data, response) = try await session.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            WaveSpeedLogger.response("POST", url: url, statusCode: statusCode, data: data)
            try validate(response: response, data: data)
            return data
        } catch {
            WaveSpeedLogger.error("POST \(url.absoluteString) failed: \(error.localizedDescription)")
            throw error
        }
    }

    func getAuthorizedData(url: URL) async throws -> Data {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        WaveSpeedLogger.request("GET", url: url)

        do {
            let (data, response) = try await session.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            WaveSpeedLogger.response("GET", url: url, statusCode: statusCode, data: data)
            try validate(response: response, data: data)
            return data
        } catch {
            WaveSpeedLogger.error("GET \(url.absoluteString) failed: \(error.localizedDescription)")
            throw error
        }
    }

    func uploadMultipart(
        path: String,
        fileData: Data,
        filename: String,
        mimeType: String,
        fieldName: String = "file"
    ) async throws -> Data {
        let url = baseURL.appendingPathComponent(path)
        let boundary = "Boundary-\(UUID().uuidString)"

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.httpBody = makeMultipartBody(
            boundary: boundary,
            fieldName: fieldName,
            filename: filename,
            mimeType: mimeType,
            fileData: fileData
        )

        WaveSpeedLogger.request("POST", url: url, bodySize: request.httpBody?.count)

        do {
            let (data, response) = try await session.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
            WaveSpeedLogger.response("POST", url: url, statusCode: statusCode, data: data)
            try validate(response: response, data: data)
            return data
        } catch {
            WaveSpeedLogger.error("Upload \(url.absoluteString) failed: \(error.localizedDescription)")
            throw error
        }
    }

    func getPublicBinary(url: URL) async throws -> Data {
        var lastError: Error?

        for attempt in 0..<WaveSpeedConfiguration.downloadMaxRetries {
            WaveSpeedLogger.info("Downloading video attempt \(attempt + 1)/\(WaveSpeedConfiguration.downloadMaxRetries): \(url.absoluteString)")

            do {
                let start = Date()
                let (data, response) = try await downloadSession.data(from: url)
                let elapsed = Date().timeIntervalSince(start)
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                WaveSpeedLogger.response("DOWNLOAD", url: url, statusCode: statusCode, data: data)
                WaveSpeedLogger.info("Download finished in \(String(format: "%.1f", elapsed))s, size=\(data.count) bytes")
                try validate(response: response, data: data)
                return data
            } catch let error as WaveSpeedError {
                WaveSpeedLogger.error("Download HTTP error: \(error.localizedDescription)")
                throw error
            } catch {
                lastError = error
                let nsError = error as NSError
                let isTimeout = nsError.domain == NSURLErrorDomain &&
                    (nsError.code == NSURLErrorTimedOut || nsError.code == NSURLErrorNetworkConnectionLost)
                WaveSpeedLogger.warning(
                    "Download attempt \(attempt + 1) failed: \(error.localizedDescription) " +
                    "(domain=\(nsError.domain) code=\(nsError.code), timeout=\(isTimeout))"
                )
                guard isTimeout, attempt < WaveSpeedConfiguration.downloadMaxRetries - 1 else {
                    throw WaveSpeedError.network(statusCode: 0, message: error.localizedDescription)
                }
                try await Task.sleep(nanoseconds: UInt64(1_000_000_000 * (attempt + 1)))
            }
        }

        WaveSpeedLogger.error("Download failed after \(WaveSpeedConfiguration.downloadMaxRetries) attempts")
        throw lastError ?? WaveSpeedError.network(statusCode: 0, message: "Download failed.")
    }

    func validate(response: URLResponse, data: Data) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw WaveSpeedError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401, 403:
            throw WaveSpeedError.invalidAPIKey
        default:
            let message = String(data: data, encoding: .utf8)
            WaveSpeedLogger.error("HTTP \(httpResponse.statusCode) for \(httpResponse.url?.absoluteString ?? "?"): \(WaveSpeedLogger.bodyPreview(data))")
            throw WaveSpeedError.network(statusCode: httpResponse.statusCode, message: message)
        }
    }

    private func makeEncoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }

    private func makeMultipartBody(
        boundary: String,
        fieldName: String,
        filename: String,
        mimeType: String,
        fileData: Data
    ) -> Data {
        var body = Data()
        let lineBreak = "\r\n"

        body.append("--\(boundary)\(lineBreak)")
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(filename)\"\(lineBreak)")
        body.append("Content-Type: \(mimeType)\(lineBreak)\(lineBreak)")
        body.append(fileData)
        body.append(lineBreak)
        body.append("--\(boundary)--\(lineBreak)")
        return body
    }
}

private struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void

    init(_ value: Encodable) {
        _encode = { try value.encode(to: $0) }
    }

    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

private extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
