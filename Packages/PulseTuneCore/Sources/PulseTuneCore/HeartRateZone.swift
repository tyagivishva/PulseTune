import Foundation

public struct HeartRateZone: Equatable, Hashable, Codable, Sendable {
    public let id: Int
    public let name: String
    public let lowerBound: Double
    public let upperBound: Double?

    public init(id: Int, name: String, lowerBound: Double, upperBound: Double?) {
        self.id = id
        self.name = name
        self.lowerBound = max(0, lowerBound)
        self.upperBound = upperBound?.isFinite == true ? upperBound : nil
    }

    public func contains(_ bpm: Double) -> Bool {
        let bounded = bpm
        if let upperBound {
            return bounded >= lowerBound && bounded <= upperBound
        } else {
            return bounded >= lowerBound
        }
    }
}

public struct HeartRateZoneConfiguration: Sendable {
    public enum ValidationError: Error, Equatable {
        case emptyZones
        case nonIncreasingBounds
    }

    public let zones: [HeartRateZone]

    public init(zones: [HeartRateZone]) throws {
        guard !zones.isEmpty else {
            throw ValidationError.emptyZones
        }

        for index in zones.indices.dropFirst() {
            let previous = zones[zones.index(before: index)]
            let current = zones[index]
            let previousUpper = previous.upperBound ?? previous.lowerBound
            if current.lowerBound < previousUpper {
                throw ValidationError.nonIncreasingBounds
            }
        }

        // Ensure IDs are sequential to avoid mismatches
        self.zones = zones.enumerated().map { offset, zone in
            HeartRateZone(
                id: offset + 1,
                name: zone.name,
                lowerBound: zone.lowerBound,
                upperBound: zone.upperBound
            )
        }
    }

    public func zone(for bpm: Double) -> HeartRateZone {
        let clamped = max(0, bpm)
        for zone in zones {
            if zone.contains(clamped) {
                return zone
            }
        }
        // If bpm exceeds all upper bounds, return last zone
        return zones.last!
    }

    public static func defaultFiveZoneConfiguration() -> HeartRateZoneConfiguration {
        try! HeartRateZoneConfiguration(
            zones: [
                HeartRateZone(id: 1, name: "Recovery", lowerBound: 0, upperBound: 100),
                HeartRateZone(id: 2, name: "Light", lowerBound: 100, upperBound: 124),
                HeartRateZone(id: 3, name: "Moderate", lowerBound: 125, upperBound: 149),
                HeartRateZone(id: 4, name: "High", lowerBound: 150, upperBound: 169),
                HeartRateZone(id: 5, name: "Peak", lowerBound: 170, upperBound: nil)
            ]
        )
    }
}
