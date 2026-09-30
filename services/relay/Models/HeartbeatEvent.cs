using System.Text.Json.Serialization;

namespace PulseTune.Relay.Models;

public sealed record PlaybackSnapshot(
    [property: JsonPropertyName("trackUri")] string TrackUri,
    [property: JsonPropertyName("trackName")] string? TrackName,
    [property: JsonPropertyName("artistName")] string? ArtistName,
    [property: JsonPropertyName("albumName")] string? AlbumName,
    [property: JsonPropertyName("playlistName")] string? PlaylistName,
    [property: JsonPropertyName("isPlaying")] bool IsPlaying,
    [property: JsonPropertyName("progressMs")] int? ProgressMs,
    [property: JsonPropertyName("durationMs")] int? DurationMs
);

public sealed record HeartbeatEvent(
    [property: JsonPropertyName("version")] int Version,
    [property: JsonPropertyName("deviceId")] string DeviceId,
    [property: JsonPropertyName("timestamp")] DateTime Timestamp,
    [property: JsonPropertyName("rawBpm")] double RawBpm,
    [property: JsonPropertyName("smoothedBpm")] double SmoothedBpm,
    [property: JsonPropertyName("zone")] int Zone,
    [property: JsonPropertyName("zoneName")] string ZoneName,
    [property: JsonPropertyName("adaptiveEnabled")] bool AdaptiveEnabled,
    [property: JsonPropertyName("transitionMode")] string? TransitionMode,
    [property: JsonPropertyName("playbackState")] PlaybackSnapshot? PlaybackState
) {
    public bool TryValidate(out string? error)
    {
        if (Version < 1)
        {
            error = "Version must be >= 1";
            return false;
        }

        if (string.IsNullOrWhiteSpace(DeviceId))
        {
            error = "DeviceId is required";
            return false;
        }

        if (RawBpm < 0 || RawBpm > 250)
        {
            error = "Raw BPM out of expected range";
            return false;
        }

        if (SmoothedBpm < 0 || SmoothedBpm > 250)
        {
            error = "Smoothed BPM out of expected range";
            return false;
        }

        if (Zone is < 1 or > 5)
        {
            error = "Zone must be between 1 and 5";
            return false;
        }

        if (string.IsNullOrWhiteSpace(ZoneName))
        {
            error = "Zone name is required";
            return false;
        }

        if (TransitionMode is not null && TransitionMode is not ("smooth" or "immediate"))
        {
            error = "Transition mode must be 'smooth' or 'immediate'";
            return false;
        }

        error = null;
        return true;
    }
}
