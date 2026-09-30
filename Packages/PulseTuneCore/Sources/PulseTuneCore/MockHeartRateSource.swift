import Foundation

public struct MockHeartRateSource: Sequence, Sendable {
    public typealias Element = HeartRateSample

    private let samples: [HeartRateSample]

    public init(samples: [HeartRateSample]) {
        self.samples = samples
    }

    public func makeIterator() -> IndexingIterator<[HeartRateSample]> {
        samples.makeIterator()
    }

    public static func ramp(startBpm: Double, endBpm: Double, step: Double, startTime: Date, interval: TimeInterval) -> MockHeartRateSource {
        guard step != 0 else {
            return MockHeartRateSource(samples: [HeartRateSample(timestamp: startTime, bpm: startBpm)])
        }
        var samples: [HeartRateSample] = []
        var current = startBpm
        var timestamp = startTime
        if step > 0 {
            while current <= endBpm {
                samples.append(HeartRateSample(timestamp: timestamp, bpm: current))
                current += step
                timestamp = timestamp.addingTimeInterval(interval)
            }
        } else {
            while current >= endBpm {
                samples.append(HeartRateSample(timestamp: timestamp, bpm: current))
                current += step
                timestamp = timestamp.addingTimeInterval(interval)
            }
        }
        return MockHeartRateSource(samples: samples)
    }
}
