import Foundation

public struct HeartRateSmoother {
    public struct Configuration: Sendable {
        public var smoothingFactor: Double

        public init(smoothingFactor: Double = 0.25) {
            self.smoothingFactor = max(0, min(1, smoothingFactor))
        }
    }

    private let configuration: Configuration
    private var lastSmoothedBpm: Double?

    public init(configuration: Configuration = .init()) {
        self.configuration = configuration
        self.lastSmoothedBpm = nil
    }

    public mutating func reset() {
        lastSmoothedBpm = nil
    }

    public mutating func ingest(_ sample: HeartRateSample) -> SmoothedHeartRateSample {
        let smoothed: Double
        if let previous = lastSmoothedBpm {
            let alpha = configuration.smoothingFactor
            smoothed = (alpha * sample.bpm) + ((1 - alpha) * previous)
        } else {
            smoothed = sample.bpm
        }
        lastSmoothedBpm = smoothed
        return SmoothedHeartRateSample(rawSample: sample, smoothedBpm: smoothed)
    }
}
