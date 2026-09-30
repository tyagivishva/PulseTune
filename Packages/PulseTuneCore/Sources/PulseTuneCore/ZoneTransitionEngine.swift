import Foundation

public struct ZoneTransitionResult: Sendable {
    public let zone: HeartRateZone
    public let previousZone: HeartRateZone?
    public let didChange: Bool
    public let pendingZone: HeartRateZone?
    public let pendingDuration: TimeInterval

    public init(zone: HeartRateZone, previousZone: HeartRateZone?, didChange: Bool, pendingZone: HeartRateZone?, pendingDuration: TimeInterval) {
        self.zone = zone
        self.previousZone = previousZone
        self.didChange = didChange
        self.pendingZone = pendingZone
        self.pendingDuration = pendingDuration
    }
}

public struct ZoneTransitionEngine: Sendable {
    public struct Configuration: Sendable {
        public var confirmationDuration: TimeInterval
        public var hysteresisBpm: Double

        public init(confirmationDuration: TimeInterval = 10, hysteresisBpm: Double = 5) {
            self.confirmationDuration = max(0, confirmationDuration)
            self.hysteresisBpm = max(0, hysteresisBpm)
        }
    }

    private struct Pending: Sendable {
        let zone: HeartRateZone
        let since: Date
    }

    public let configuration: Configuration
    public let zoneConfiguration: HeartRateZoneConfiguration

    private var currentZone: HeartRateZone?
    private var pending: Pending?

    public init(configuration: Configuration = .init(), zoneConfiguration: HeartRateZoneConfiguration = .defaultFiveZoneConfiguration()) {
        self.configuration = configuration
        self.zoneConfiguration = zoneConfiguration
        self.currentZone = nil
        self.pending = nil
    }

    public mutating func reset() {
        currentZone = nil
        pending = nil
    }

    public mutating func process(sample: SmoothedHeartRateSample) -> ZoneTransitionResult {
        let timestamp = sample.rawSample.timestamp
        let candidateZone = zoneConfiguration.zone(for: sample.smoothedBpm)

        if currentZone == nil {
            currentZone = candidateZone
            pending = nil
            return ZoneTransitionResult(zone: candidateZone, previousZone: nil, didChange: true, pendingZone: nil, pendingDuration: 0)
        }

        guard let activeZone = currentZone else {
            fatalError("Invariant violated: currentZone should not be nil")
        }

        if candidateZone == activeZone {
            pending = nil
            return ZoneTransitionResult(zone: activeZone, previousZone: activeZone, didChange: false, pendingZone: nil, pendingDuration: 0)
        }

        guard meetsHysteresis(from: activeZone, to: candidateZone, bpm: sample.smoothedBpm) else {
            pending = nil
            return ZoneTransitionResult(zone: activeZone, previousZone: activeZone, didChange: false, pendingZone: nil, pendingDuration: 0)
        }

        if let pending, pending.zone == candidateZone {
            let duration = timestamp.timeIntervalSince(pending.since)
            if duration >= configuration.confirmationDuration {
                let previous = currentZone
                currentZone = candidateZone
                self.pending = nil
                return ZoneTransitionResult(zone: candidateZone, previousZone: previous, didChange: true, pendingZone: nil, pendingDuration: duration)
            }
            return ZoneTransitionResult(zone: activeZone, previousZone: activeZone, didChange: false, pendingZone: pending.zone, pendingDuration: duration)
        } else {
            self.pending = Pending(zone: candidateZone, since: timestamp)
            return ZoneTransitionResult(zone: activeZone, previousZone: activeZone, didChange: false, pendingZone: candidateZone, pendingDuration: 0)
        }
    }

    private func meetsHysteresis(from current: HeartRateZone, to candidate: HeartRateZone, bpm: Double) -> Bool {
        if candidate.id == current.id {
            return true
        }

        if candidate.id > current.id {
            let boundary = (current.upperBound ?? candidate.lowerBound) + configuration.hysteresisBpm
            return bpm >= boundary
        } else {
            let candidateUpper = candidate.upperBound ?? candidate.lowerBound
            let boundary = max(0, candidateUpper - configuration.hysteresisBpm)
            return bpm <= boundary
        }
    }
}
