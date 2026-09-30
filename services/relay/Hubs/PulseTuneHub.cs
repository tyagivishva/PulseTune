using Microsoft.AspNetCore.SignalR;
using PulseTune.Relay.Models;
using PulseTune.Relay.Services;

namespace PulseTune.Relay.Hubs;

public sealed class PulseTuneHub(IPairingService pairingService) : Hub<IPulseTuneClient>
{
    private const string DeviceIdContextKey = "deviceId";

    public override async Task OnConnectedAsync()
    {
        var httpContext = Context.GetHttpContext();
        var deviceId = httpContext?.Request.Query["deviceId"].ToString();
        var token = httpContext?.Request.Query["accessToken"].ToString();

        if (string.IsNullOrWhiteSpace(deviceId) || string.IsNullOrWhiteSpace(token) || !pairingService.IsAuthorized(deviceId, token))
        {
            Context.Abort();
            return;
        }

        Context.Items[DeviceIdContextKey] = deviceId;
        await Groups.AddToGroupAsync(Context.ConnectionId, deviceId);
        await base.OnConnectedAsync();
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        if (Context.Items.TryGetValue(DeviceIdContextKey, out var value) && value is string deviceId)
        {
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, deviceId);
        }

        await base.OnDisconnectedAsync(exception);
    }

    public async Task SendHeartbeat(HeartbeatEvent heartbeat)
    {
        EnsureAuthorizedForDevice(heartbeat.DeviceId);

        if (!heartbeat.TryValidate(out var error))
        {
            throw new HubException(error ?? "Invalid heartbeat payload");
        }

        await Clients.Group(heartbeat.DeviceId).ReceiveHeartbeat(heartbeat);
    }

    public async Task NotifyAdaptiveMode(AdaptiveModeChangedEvent payload)
    {
        EnsureAuthorizedForDevice(payload.DeviceId);
        await Clients.Group(payload.DeviceId).AdaptiveModeChanged(payload);
    }

    public async Task NotifyZoneChange(ZoneChangeEvent payload)
    {
        EnsureAuthorizedForDevice(payload.DeviceId);
        await Clients.Group(payload.DeviceId).ZoneChanged(payload);
    }

    private void EnsureAuthorizedForDevice(string deviceId)
    {
        if (!Context.Items.TryGetValue(DeviceIdContextKey, out var value) || value is not string activeDeviceId || !string.Equals(activeDeviceId, deviceId, StringComparison.Ordinal))
        {
            throw new HubException("Connection is not authorized for this device");
        }
    }
}
