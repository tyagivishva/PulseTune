using System.Collections.Concurrent;
using System.Security.Cryptography;
using Microsoft.Extensions.Options;
using PulseTune.Relay.Models;

namespace PulseTune.Relay.Services;

internal sealed class PairingService : IPairingService
{
    private readonly PairingOptions _options;
    private readonly ConcurrentDictionary<string, PairingSession> _sessions = new();

    public PairingService(IOptions<PairingOptions> options)
    {
        _options = options.Value;
    }

    public PairingCode GenerateCode(string deviceId)
    {
        var normalized = NormalizeDeviceId(deviceId);
        var code = GenerateNumericCode(_options.CodeLength);
        var expiresAt = DateTime.UtcNow.AddSeconds(_options.TtlSeconds);
        var session = new PairingSession
        {
            DeviceId = normalized,
            Code = code,
            CodeExpiresAt = expiresAt
        };

        _sessions[normalized] = session;

        return new PairingCode(code, expiresAt);
    }

    public bool TryConfirm(string deviceId, string code, out string accessToken, out DateTime expiresAt)
    {
        accessToken = string.Empty;
        expiresAt = DateTime.MinValue;
        var normalized = NormalizeDeviceId(deviceId);

        if (!_sessions.TryGetValue(normalized, out var session))
        {
            return false;
        }

        if (session.CodeExpiresAt <= DateTime.UtcNow)
        {
            _sessions.TryRemove(normalized, out _);
            return false;
        }

        if (!string.Equals(session.Code, code, StringComparison.Ordinal))
        {
            return false;
        }

        accessToken = GenerateToken();
        session.AccessToken = accessToken;
        session.AccessTokenExpiresAt = DateTime.UtcNow.AddHours(12);
        expiresAt = session.AccessTokenExpiresAt;
        _sessions[normalized] = session;
        return true;
    }

    public bool IsAuthorized(string deviceId, string accessToken)
    {
        var normalized = NormalizeDeviceId(deviceId);
        if (!_sessions.TryGetValue(normalized, out var session))
        {
            return false;
        }

        if (session.AccessTokenExpiresAt <= DateTime.UtcNow)
        {
            _sessions.TryRemove(normalized, out _);
            return false;
        }

        return string.Equals(session.AccessToken, accessToken, StringComparison.Ordinal);
    }

    public void Revoke(string deviceId)
    {
        var normalized = NormalizeDeviceId(deviceId);
        _sessions.TryRemove(normalized, out _);
    }

    private static string NormalizeDeviceId(string deviceId)
    {
        return deviceId.Trim().ToLowerInvariant();
    }

    private static string GenerateNumericCode(int length)
    {
        if (length <= 0)
        {
            length = 6;
        }

        var digits = new char[length];
        for (var index = 0; index < length; index++)
        {
            digits[index] = (char)('0' + RandomNumberGenerator.GetInt32(0, 10));
        }

        return new string(digits);
    }

    private static string GenerateToken()
    {
        Span<byte> buffer = stackalloc byte[32];
        RandomNumberGenerator.Fill(buffer);
        return Convert.ToHexString(buffer);
    }

    private sealed class PairingSession
    {
        public required string DeviceId { get; init; }
        public required string Code { get; set; }
        public DateTime CodeExpiresAt { get; set; }
        public string? AccessToken { get; set; }
        public DateTime AccessTokenExpiresAt { get; set; } = DateTime.MinValue;
    }
}
