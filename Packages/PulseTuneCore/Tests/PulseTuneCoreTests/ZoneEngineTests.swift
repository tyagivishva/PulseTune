import Foundation
import Testing
@testable import PulseTuneCore

@Suite struct ZoneTransitionEngineTests {
    private let zoneConfig = PulseTuneCore.defaultZoneConfiguration()

    @Test func stableZoneRemainsConsistent() async throws {
        var smoother = HeartRateSmoother(configuration: .init(smoothingFactor: 0.25))
        var engine = ZoneTransitionEngine(configuration: .init(confirmationDuration: 10, hysteresisBpm: 5), zoneConfiguration: zoneConfig)

        let start = Date(timeIntervalSince1970: 0)
        var lastResult: ZoneTransitionResult?

        for index in 0..<6 {
            let sample = HeartRateSample(timestamp: start.addingTimeInterval(TimeInterval(index)), bpm: 140)
            let smoothed = smoother.ingest(sample)
            lastResult = engine.process(sample: smoothed)
        }

        #expect(lastResult?.zone.id == 3)
        #expect(lastResult?.didChange == false)
    }

    @Test func boundaryFluctuationDoesNotOscillate() async throws {
        let bpmSequence: [Double] = [149, 151, 148, 152, 150, 149]
        var smoother = HeartRateSmoother(configuration: .init(smoothingFactor: 0.25))
        var engine = ZoneTransitionEngine(configuration: .init(confirmationDuration: 10, hysteresisBpm: 5), zoneConfiguration: zoneConfig)

        let start = Date(timeIntervalSince1970: 100)
        var zoneIds: [Int] = []

        for (idx, bpm) in bpmSequence.enumerated() {
            let sample = HeartRateSample(timestamp: start.addingTimeInterval(TimeInterval(idx)), bpm: bpm)
            let result = engine.process(sample: smoother.ingest(sample))
            zoneIds.append(result.zone.id)
        }

        #expect(zoneIds.allSatisfy { $0 == 3 })
    }

    @Test func sustainedHighZoneConfirmsAfterConfirmationWindow() async throws {
        var smoother = HeartRateSmoother(configuration: .init(smoothingFactor: 0.25))
        var engine = ZoneTransitionEngine(configuration: .init(confirmationDuration: 10, hysteresisBpm: 5), zoneConfiguration: zoneConfig)

        let start = Date(timeIntervalSince1970: 200)
        let baseSample = HeartRateSample(timestamp: start, bpm: 140)
        _ = engine.process(sample: smoother.ingest(baseSample))

        var changeCount = 0
        var confirmedAt: Date?

        for offset in 1...12 {
            let sample = HeartRateSample(timestamp: start.addingTimeInterval(TimeInterval(offset)), bpm: 160)
            let result = engine.process(sample: smoother.ingest(sample))
            if result.didChange {
                changeCount += 1
                confirmedAt = sample.timestamp
            }
        }

        #expect(changeCount == 1)
        #expect(confirmedAt == start.addingTimeInterval(11))
    }

    @Test func briefSpikeDoesNotTriggerZoneChange() async throws {
        var smoother = HeartRateSmoother(configuration: .init(smoothingFactor: 0.25))
        var engine = ZoneTransitionEngine(configuration: .init(confirmationDuration: 10, hysteresisBpm: 5), zoneConfiguration: zoneConfig)

        let start = Date(timeIntervalSince1970: 400)
        let initial = HeartRateSample(timestamp: start, bpm: 140)
        _ = engine.process(sample: smoother.ingest(initial))

        var didChange = false
        for offset in 1...4 {
            let sample = HeartRateSample(timestamp: start.addingTimeInterval(TimeInterval(offset)), bpm: 162)
            let result = engine.process(sample: smoother.ingest(sample))
            didChange = didChange || result.didChange
        }

        #expect(didChange == false)
    }
}

@Suite struct AdaptiveMusicEngineTests {
    private var zoneConfig: HeartRateZoneConfiguration {
        PulseTuneCore.defaultZoneConfiguration()
    }

    @Test func cooldownPreventsImmediateFollowUpChange() async throws {
        var engine = AdaptiveMusicEngine(configuration: .init(songChangeCooldown: 60, pauseAfterManualSelection: 300))
        engine.setAdaptiveEnabled(true, timestamp: Date(timeIntervalSince1970: 0))

        let previousZone = zoneConfig.zone(for: 140)
        let newZone = zoneConfig.zone(for: 165)
        let initialResult = ZoneTransitionResult(zone: newZone, previousZone: previousZone, didChange: true, pendingZone: nil, pendingDuration: 10)

        let firstDecision = engine.decide(for: .init(timestamp: Date(timeIntervalSince1970: 0), zoneResult: initialResult, transitionMode: .smooth))
        #expect(firstDecision.shouldChangePlayback)
        #expect(firstDecision.reason == .triggered)

        let quickFollowUp = engine.decide(for: .init(timestamp: Date(timeIntervalSince1970: 30), zoneResult: initialResult, transitionMode: .immediate))
        #expect(quickFollowUp.shouldChangePlayback == false)
        #expect(quickFollowUp.reason == .cooldownActive)
    }

    @Test func adaptiveModeOffBlocksAutomation() async throws {
        var engine = AdaptiveMusicEngine(configuration: .init())
        engine.setAdaptiveEnabled(false, timestamp: Date(timeIntervalSince1970: 0))

        let zone = zoneConfig.zone(for: 165)
        let result = ZoneTransitionResult(zone: zone, previousZone: nil, didChange: true, pendingZone: nil, pendingDuration: 10)

        let decision = engine.decide(for: .init(timestamp: Date(timeIntervalSince1970: 5), zoneResult: result, transitionMode: .immediate))

        #expect(decision.shouldChangePlayback == false)
        #expect(decision.reason == .adaptiveDisabled)
    }

    @Test func manualOverridePreventsAutoPlaybackChange() async throws {
        var engine = AdaptiveMusicEngine(configuration: .init())
        engine.setAdaptiveEnabled(true, timestamp: Date(timeIntervalSince1970: 0))

        let zone = zoneConfig.zone(for: 165)
        let result = ZoneTransitionResult(zone: zone, previousZone: nil, didChange: true, pendingZone: nil, pendingDuration: 10)

        let decision = engine.decide(for: .init(timestamp: Date(timeIntervalSince1970: 10), zoneResult: result, transitionMode: .immediate, manualOverrideActive: true))

        #expect(decision.shouldChangePlayback == false)
        #expect(decision.reason == .manualOverride)
    }
}

@Suite struct MockSourceParityTests {
    @Test func mockSourceMatchesDirectSamples() async throws {
        let start = Date(timeIntervalSince1970: 800)
        let bpmSequence: [Double] = [90, 100, 110, 120, 135, 150, 160, 150, 140]
        let samples = bpmSequence.enumerated().map { index, bpm in
            HeartRateSample(timestamp: start.addingTimeInterval(TimeInterval(index)), bpm: bpm)
        }

        var smootherA = HeartRateSmoother()
        var smootherB = HeartRateSmoother()
        var engineA = ZoneTransitionEngine()
        var engineB = ZoneTransitionEngine()

        var zonesA: [Int] = []
        var zonesB: [Int] = []

        for sample in samples {
            zonesA.append(engineA.process(sample: smootherA.ingest(sample)).zone.id)
        }

        for sample in MockHeartRateSource(samples: samples) {
            zonesB.append(engineB.process(sample: smootherB.ingest(sample)).zone.id)
        }

        #expect(zonesA == zonesB)
    }
}
