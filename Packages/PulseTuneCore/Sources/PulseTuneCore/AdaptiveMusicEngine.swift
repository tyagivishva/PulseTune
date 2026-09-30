import Foundation

public struct AdaptiveMusicEngine: Sendable {
    public struct Configuration: Sendable {
        public var songChangeCooldown: TimeInterval
        public var pauseAfterManualSelection: TimeInterval

        public init(songChangeCooldown: TimeInterval = 60, pauseAfterManualSelection: TimeInterval = 300) {
            self.songChangeCooldown = max(0, songChangeCooldown)
            self.pauseAfterManualSelection = max(0, pauseAfterManualSelection)
        }
    }

    public struct State: Sendable {
        public var adaptiveEnabled: Bool
        public var pauseAutomationUntil: Date?
        public var manualOverrideUntil: Date?
        public var lastAutomaticChangeAt: Date?

        public init(adaptiveEnabled: Bool = false, pauseAutomationUntil: Date? = nil, manualOverrideUntil: Date? = nil, lastAutomaticChangeAt: Date? = nil) {
            self.adaptiveEnabled = adaptiveEnabled
            self.pauseAutomationUntil = pauseAutomationUntil
            self.manualOverrideUntil = manualOverrideUntil
            self.lastAutomaticChangeAt = lastAutomaticChangeAt
        }
    }

    public struct Input: Sendable {
        public let timestamp: Date
        public let zoneResult: ZoneTransitionResult
        public let transitionMode: TransitionMode
        public let manualOverrideActive: Bool
        public let manualSelectionPerformed: Bool

        public init(timestamp: Date, zoneResult: ZoneTransitionResult, transitionMode: TransitionMode, manualOverrideActive: Bool = false, manualSelectionPerformed: Bool = false) {
            self.timestamp = timestamp
            self.zoneResult = zoneResult
            self.transitionMode = transitionMode
            self.manualOverrideActive = manualOverrideActive
            self.manualSelectionPerformed = manualSelectionPerformed
        }
    }

    public enum DecisionReason: Sendable {
        case noZoneChange
        case adaptiveDisabled
        case automationPaused
        case manualOverride
        case cooldownActive
        case triggered
    }

    public struct Decision: Sendable {
        public let shouldChangePlayback: Bool
        public let transitionMode: TransitionMode
        public let reason: DecisionReason
        public let zone: HeartRateZone

        public init(shouldChangePlayback: Bool, transitionMode: TransitionMode, reason: DecisionReason, zone: HeartRateZone) {
            self.shouldChangePlayback = shouldChangePlayback
            self.transitionMode = transitionMode
            self.reason = reason
            self.zone = zone
        }
    }

    public let configuration: Configuration
    public private(set) var state: State

    public init(configuration: Configuration = .init(), state: State = .init()) {
        self.configuration = configuration
        self.state = state
    }

    public mutating func setAdaptiveEnabled(_ enabled: Bool, timestamp: Date) {
        state.adaptiveEnabled = enabled
        if !enabled {
            state.pauseAutomationUntil = nil
            state.manualOverrideUntil = nil
            state.lastAutomaticChangeAt = nil
        }
    }

    public mutating func pauseAutomation(until date: Date?) {
        state.pauseAutomationUntil = date
    }

    public mutating func clearManualOverride() {
        state.manualOverrideUntil = nil
    }

    public mutating func recordManualSelection(at timestamp: Date) {
        let until = timestamp.addingTimeInterval(configuration.pauseAfterManualSelection)
        if let existing = state.manualOverrideUntil {
            state.manualOverrideUntil = max(existing, until)
        } else {
            state.manualOverrideUntil = until
        }
    }

    public mutating func decide(for input: Input) -> Decision {
        if input.manualSelectionPerformed {
            recordManualSelection(at: input.timestamp)
        }

        guard state.adaptiveEnabled else {
            return Decision(shouldChangePlayback: false, transitionMode: input.transitionMode, reason: .adaptiveDisabled, zone: input.zoneResult.zone)
        }

        if let pauseUntil = state.pauseAutomationUntil, pauseUntil > input.timestamp {
            return Decision(shouldChangePlayback: false, transitionMode: input.transitionMode, reason: .automationPaused, zone: input.zoneResult.zone)
        }

        let manualOverrideActive = input.manualOverrideActive || (state.manualOverrideUntil.map { $0 > input.timestamp } ?? false)
        if manualOverrideActive {
            return Decision(shouldChangePlayback: false, transitionMode: input.transitionMode, reason: .manualOverride, zone: input.zoneResult.zone)
        }

        guard input.zoneResult.didChange else {
            return Decision(shouldChangePlayback: false, transitionMode: input.transitionMode, reason: .noZoneChange, zone: input.zoneResult.zone)
        }

        if let lastChange = state.lastAutomaticChangeAt, input.timestamp.timeIntervalSince(lastChange) < configuration.songChangeCooldown {
            return Decision(shouldChangePlayback: false, transitionMode: input.transitionMode, reason: .cooldownActive, zone: input.zoneResult.zone)
        }

        state.lastAutomaticChangeAt = input.timestamp
        return Decision(shouldChangePlayback: true, transitionMode: input.transitionMode, reason: .triggered, zone: input.zoneResult.zone)
    }
}
