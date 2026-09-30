import Foundation

public enum PulseTuneCore {
    public static func defaultZoneConfiguration() -> HeartRateZoneConfiguration {
        HeartRateZoneConfiguration.defaultFiveZoneConfiguration()
    }
}
