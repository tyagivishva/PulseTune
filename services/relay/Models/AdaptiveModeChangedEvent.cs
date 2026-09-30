using System.Text.Json.Serialization;

namespace PulseTune.Relay.Models;

public sealed record AdaptiveModeChangedEvent(
    [property: JsonPropertyName("deviceId")] string DeviceId,
    [property: JsonPropertyName("adaptiveEnabled")] bool AdaptiveEnabled
);
