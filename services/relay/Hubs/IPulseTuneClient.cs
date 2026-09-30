using PulseTune.Relay.Models;

namespace PulseTune.Relay.Hubs;

public interface IPulseTuneClient
{
    Task ReceiveHeartbeat(HeartbeatEvent heartbeat);
    Task AdaptiveModeChanged(AdaptiveModeChangedEvent payload);
    Task ZoneChanged(ZoneChangeEvent payload);
}
