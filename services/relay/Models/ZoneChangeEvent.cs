using System.Text.Json.Serialization;

namespace PulseTune.Relay.Models;

public sealed record ZoneChangeEvent(
    [property: JsonPropertyName("deviceId")] string DeviceId,
    [property: JsonPropertyName("zone")] int Zone,
    [property: JsonPropertyName("zoneName")] string ZoneName
);
