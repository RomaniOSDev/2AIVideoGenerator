import Foundation

struct WaveSpeedRequestBody: Encodable, Sendable {
    private let _encode: @Sendable (Encoder) throws -> Void

    init(_ encode: @escaping @Sendable (Encoder) throws -> Void) {
        _encode = encode
    }

    nonisolated func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}
