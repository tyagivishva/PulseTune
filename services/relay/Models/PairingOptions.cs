namespace PulseTune.Relay.Models;

public sealed class PairingOptions
{
    public int CodeLength { get; set; } = 6;
    public int TtlSeconds { get; set; } = 120;
}
