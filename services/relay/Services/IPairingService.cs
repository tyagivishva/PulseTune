using PulseTune.Relay.Models;

namespace PulseTune.Relay.Services;

public interface IPairingService
{
    PairingCode GenerateCode(string deviceId);
    bool TryConfirm(string deviceId, string code, out string accessToken, out DateTime expiresAt);
    bool IsAuthorized(string deviceId, string accessToken);
    void Revoke(string deviceId);
}

public sealed record PairingCode(string Code, DateTime ExpiresAt);
