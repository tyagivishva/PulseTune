import Foundation

public struct HeartRateSample: Equatable, Sendable {
    public let timestamp: Date
    public let bpm: Double

    public init(timestamp: Date, bpm: Double) {
        self.timestamp = timestamp
        self.bpm = bpm.isFinite && bpm >= 0 ? bpm : 0
    }
}

public struct SmoothedHeartRateSample: Equatable, Sendable {
    public let rawSample: HeartRateSample
    public let smoothedBpm: Double

    public init(rawSample: HeartRateSample, smoothedBpm: Double) {
        self.rawSample = rawSample
        self.smoothedBpm = smoothedBpm.isFinite && smoothedBpm >= 0 ? smoothedBpm : 0
    }
}

public enum TransitionMode: String, Sendable {
    case smooth
    case immediate
}
