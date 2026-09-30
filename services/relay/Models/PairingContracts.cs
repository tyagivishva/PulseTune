using System.ComponentModel.DataAnnotations;

namespace PulseTune.Relay.Models;

public sealed class StartPairingRequest
{
    [Required]
    public string DeviceId { get; set; } = string.Empty;
}

public sealed class ConfirmPairingRequest
{
    [Required]
    public string DeviceId { get; set; } = string.Empty;

    [Required]
    [StringLength(12, MinimumLength = 4)]
    public string Code { get; set; } = string.Empty;
}

public sealed record PairingResponse(string DeviceId, string Code, DateTime ExpiresAt);
public sealed record AccessTokenResponse(string DeviceId, string AccessToken, DateTime ExpiresAt);
