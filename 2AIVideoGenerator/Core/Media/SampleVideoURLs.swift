import Foundation

enum SampleVideoURLs {
    static let samples = [
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
        "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4"
    ]

    static func at(index: Int) -> String {
        samples[index % samples.count]
    }

    static func random() -> String {
        samples.randomElement() ?? samples[0]
    }
}
