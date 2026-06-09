import Foundation

struct UploadInput: Sendable {
    let data: Data
    let filename: String
    let mimeType: String
}

actor AIService {
    enum Mode: Sendable {
        case mock
        case live
    }

    private let mode: Mode
    private let client: HTTPClient

    init(mode: Mode = .live, apiKey: String = WaveSpeedConfiguration.apiKey) {
        self.mode = mode
        self.client = HTTPClient(apiKey: apiKey)
    }

    func uploadMedia(data: Data, filename: String, mimeType: String) async throws -> String {
        WaveSpeedLogger.info("Upload media: \(filename), \(data.count) bytes, \(mimeType)")
        switch mode {
        case .mock:
            try await Task.sleep(nanoseconds: 300_000_000)
            return "https://mock.wavespeed.local/upload/\(filename)"
        case .live:
            let responseData = try await client.uploadMultipart(
                path: "media/upload/binary",
                fileData: data,
                filename: filename,
                mimeType: mimeType
            )
            let url = try WaveSpeedUploadParsing.parseURL(from: responseData)
            WaveSpeedLogger.info("Upload success → \(url)")
            return url
        }
    }

    func uploadMediaBatch(_ inputs: [UploadInput]) async throws -> [String] {
        try await withThrowingTaskGroup(of: (Int, String).self) { group in
            for (index, input) in inputs.enumerated() {
                group.addTask {
                    let url = try await self.uploadMedia(
                        data: input.data,
                        filename: input.filename,
                        mimeType: input.mimeType
                    )
                    return (index, url)
                }
            }

            var results = Array(repeating: "", count: inputs.count)
            for try await (index, url) in group {
                results[index] = url
            }
            return results
        }
    }

    func submitJob(model: VideoModelConfig, body: Encodable) async throws -> SubmitOutcome {
        switch mode {
        case .mock:
            try await Task.sleep(nanoseconds: 400_000_000)
            let taskID = UUID().uuidString
            return SubmitOutcome(
                taskID: taskID,
                pollURL: WaveSpeedConfiguration.baseURL.appendingPathComponent("predictions/\(taskID)/result")
            )
        case .live:
            WaveSpeedLogger.info("Submit job → \(model.endpointPath)")
            let data = try await client.postJSONData(path: model.endpointPath, body: body)
            let outcome = try WaveSpeedSubmitParsing.parse(data: data, baseURL: WaveSpeedConfiguration.baseURL)
            WaveSpeedLogger.info("Submit success: taskID=\(outcome.taskID), pollURL=\(outcome.pollURL.absoluteString)")
            return outcome
        }
    }

    func pollForResult(
        taskID: String,
        resultPollURL: URL,
        onProgress: (@Sendable (GenerationProgressUpdate) -> Void)? = nil
    ) async throws -> String {
        switch mode {
        case .mock:
            for attempt in 1...8 {
                try Task.checkCancellation()
                try await Task.sleep(nanoseconds: 400_000_000)
                let progress = pollProgress(for: attempt, maxAttempts: 8)
                onProgress?(GenerationProgressUpdate(value: progress, label: "Generating frames"))
            }
            return SampleVideoURLs.random()
        case .live:
            for attempt in 1...WaveSpeedConfiguration.maxPollAttempts {
                try Task.checkCancellation()

                let data = try await client.getAuthorizedData(url: resultPollURL)
                let result = try WaveSpeedPollParsing.parse(data: data)

                WaveSpeedLogger.debug(
                    "Poll \(attempt)/\(WaveSpeedConfiguration.maxPollAttempts) taskID=\(taskID): " +
                    "complete=\(result.isComplete) failed=\(result.isFailed) " +
                    "output=\(result.output.map(WaveSpeedLogger.outputPreview) ?? "nil") " +
                    "error=\(result.errorMessage ?? "nil")"
                )

                let progress = pollProgress(for: attempt, maxAttempts: WaveSpeedConfiguration.maxPollAttempts)
                onProgress?(GenerationProgressUpdate(value: progress, label: pollStatusLabel(for: result)))

                if result.isFailed {
                    WaveSpeedLogger.error("Prediction failed: \(result.errorMessage ?? "unknown")")
                    throw WaveSpeedError.predictionFailed(result.errorMessage)
                }

                if result.isComplete {
                    guard let output = result.output, !output.isEmpty else {
                        WaveSpeedLogger.error("Prediction completed but outputs array is empty")
                        throw WaveSpeedError.emptyOutputs
                    }
                    WaveSpeedLogger.info("Prediction complete, output: \(WaveSpeedLogger.outputPreview(output))")
                    return output
                }

                try await Task.sleep(nanoseconds: WaveSpeedConfiguration.pollIntervalSeconds * 1_000_000_000)
            }
            WaveSpeedLogger.error("Poll timeout after \(WaveSpeedConfiguration.maxPollAttempts) attempts for taskID=\(taskID)")
            throw WaveSpeedError.timeout
        }
    }

    func downloadOutput(from output: String) async throws -> Data {
        WaveSpeedLogger.info("Download output: \(WaveSpeedLogger.outputPreview(output))")

        if output.hasPrefix("http://") || output.hasPrefix("https://") {
            guard let url = URL(string: output) else {
                WaveSpeedLogger.error("Invalid output URL string")
                throw WaveSpeedError.unsupportedOutputFormat
            }
            return try await client.getPublicBinary(url: url)
        }

        if output.hasPrefix("data:") {
            WaveSpeedLogger.info("Decoding data URI output")
            return try decodeDataURI(output)
        }

        WaveSpeedLogger.info("Decoding base64 output")
        return try decodeBase64(output)
    }

    func generateVideo(
        model: VideoModelConfig,
        params: GenerationParams,
        uploads: [UploadInput] = [],
        onProgress: (@Sendable (GenerationProgressUpdate) -> Void)? = nil
    ) async throws -> URL {
        WaveSpeedLogger.info("━━━ generateVideo start: model=\(model.id) endpoint=\(model.endpointPath) ━━━")

        do {
            onProgress?(GenerationProgressUpdate(value: 0.02, label: "Preparing generation"))

            var imageURLs = params.imageURLs ?? []
            if !uploads.isEmpty {
                onProgress?(GenerationProgressUpdate(value: 0.05, label: "Uploading media"))
                let uploaded = try await uploadMediaBatch(uploads)
                imageURLs.append(contentsOf: uploaded)
            }

            var resolvedParams = params
            resolvedParams.imageURLs = imageURLs.isEmpty ? nil : imageURLs

            onProgress?(GenerationProgressUpdate(value: 0.12, label: "Submitting job"))
            let requestBody = model.buildRequest(imageURLs, resolvedParams)
            let submitOutcome = try await submitJob(model: model, body: requestBody)

            onProgress?(GenerationProgressUpdate(value: 0.28, label: "Generating frames"))
            let output = try await pollForResult(
                taskID: submitOutcome.taskID,
                resultPollURL: submitOutcome.pollURL,
                onProgress: onProgress
            )

            onProgress?(GenerationProgressUpdate(value: 0.92, label: "Downloading video"))
            WaveSpeedLogger.info("Step: download (progress 92%)")
            let videoData = try await downloadOutput(from: output)

            WaveSpeedLogger.info("Step: validate video data (\(videoData.count) bytes)")
            try validateVideoData(videoData)

            onProgress?(GenerationProgressUpdate(value: 0.98, label: "Saving video"))
            WaveSpeedLogger.info("Step: save to Documents")
            let fileName = try VideoStorageService.shared.saveGeneratedVideoData(videoData)
            let localURL = VideoStorageService.shared.fileURL(for: fileName)
            WaveSpeedLogger.info("Saved video → \(localURL.path)")

            onProgress?(GenerationProgressUpdate(value: 1.0, label: "Rendering video"))
            WaveSpeedLogger.info("━━━ generateVideo success ━━━")
            return localURL
        } catch {
            WaveSpeedLogger.error("━━━ generateVideo failed: \(error.localizedDescription) ━━━")
            throw error
        }
    }

    // MARK: - Private

    private func pollProgress(for attempt: Int, maxAttempts: Int) -> Double {
        let normalized = Double(attempt) / Double(maxAttempts)
        let eased = 1 - pow(1 - normalized, 1.35)
        return 0.30 + eased * 0.60
    }

    private func pollStatusLabel(for result: WaveSpeedPollParsing.PollResult) -> String {
        if result.isComplete { return "Rendering video" }
        return "Generating frames"
    }

    private func decodeDataURI(_ value: String) throws -> Data {
        guard let commaIndex = value.firstIndex(of: ",") else {
            throw WaveSpeedError.unsupportedOutputFormat
        }
        let payload = String(value[value.index(after: commaIndex)...])
        return try decodeBase64(payload)
    }

    private func decodeBase64(_ value: String) throws -> Data {
        guard let data = Data(base64Encoded: value) else {
            throw WaveSpeedError.unsupportedOutputFormat
        }
        return data
    }

    private func validateVideoData(_ data: Data) throws {
        guard data.count >= 12 else {
            WaveSpeedLogger.error("Video validation failed: data too small (\(data.count) bytes)")
            throw WaveSpeedError.invalidVideoData
        }

        let signature = data.prefix(4)
        let hasMP4 = data.range(of: Data("ftyp".utf8), in: 0..<min(32, data.count)) != nil
        let hasWebM = signature == Data([0x1A, 0x45, 0xDF, 0xA3])

        guard hasMP4 || hasWebM else {
            WaveSpeedLogger.error(
                "Video validation failed: unrecognized format. " +
                "size=\(data.count) hex=\(WaveSpeedLogger.hexPreview(data)) " +
                "textPreview=\(WaveSpeedLogger.bodyPreview(data))"
            )
            throw WaveSpeedError.invalidVideoData
        }

        WaveSpeedLogger.info("Video validation OK: mp4=\(hasMP4) webm=\(hasWebM)")
    }

}
