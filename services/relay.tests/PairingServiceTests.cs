using Microsoft.Extensions.Options;
using PulseTune.Relay.Models;
using PulseTune.Relay.Services;

namespace PulseTune.Relay.Tests;

public class PairingServiceTests
{
    [Fact]
    public void GenerateCode_ProducesExpectedLength()
    {
        var service = CreateService(codeLength: 6);
        var code = service.GenerateCode("device-123");

        Assert.Equal(6, code.Code.Length);
        Assert.True(code.ExpiresAt > DateTime.UtcNow);
    }

    [Fact]
    public void TryConfirm_SucceedsWithValidCode()
    {
        var service = CreateService();
        var pairingCode = service.GenerateCode("device-abc");

        var succeeded = service.TryConfirm("device-abc", pairingCode.Code, out var token, out var expiresAt);

        Assert.True(succeeded);
        Assert.False(string.IsNullOrWhiteSpace(token));
        Assert.True(service.IsAuthorized("device-abc", token));
        Assert.True(expiresAt > DateTime.UtcNow);
    }

    [Fact]
    public void TryConfirm_FailsWithIncorrectCode()
    {
        var service = CreateService();
        _ = service.GenerateCode("device-abc");

        var succeeded = service.TryConfirm("device-abc", "111111", out _, out _);

        Assert.False(succeeded);
    }

    [Fact]
    public void TryConfirm_FailsWhenExpired()
    {
        var options = Options.Create(new PairingOptions { CodeLength = 6, TtlSeconds = -10 });
        var service = new PairingService(options);
        var code = service.GenerateCode("device-xyz");

        var succeeded = service.TryConfirm("device-xyz", code.Code, out _, out _);

        Assert.False(succeeded);
    }

    [Fact]
    public void IsAuthorized_RejectsUnknownToken()
    {
        var service = CreateService();
        var code = service.GenerateCode("device-xyz");
        _ = service.TryConfirm("device-xyz", code.Code, out _, out _);

        Assert.False(service.IsAuthorized("device-xyz", "deadbeef"));
    }

    [Fact]
    public void HeartbeatValidationRejectsInvalidZone()
    {
        var heartbeat = new HeartbeatEvent(
            Version: 1,
            DeviceId: "device-1",
            Timestamp: DateTime.UtcNow,
            RawBpm: 120,
            SmoothedBpm: 118,
            Zone: 7,
            ZoneName: "Invalid",
            AdaptiveEnabled: true,
            TransitionMode: "smooth",
            PlaybackState: null
        );

        Assert.False(heartbeat.TryValidate(out var message));
        Assert.Equal("Zone must be between 1 and 5", message);
    }

    private static PairingService CreateService(int codeLength = 6)
    {
        var options = Options.Create(new PairingOptions
        {
            CodeLength = codeLength,
            TtlSeconds = 120
        });

        return new PairingService(options);
    }
}
