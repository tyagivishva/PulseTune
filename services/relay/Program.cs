using Microsoft.AspNetCore.Http.HttpResults;
using PulseTune.Relay.Hubs;
using PulseTune.Relay.Models;
using PulseTune.Relay.Services;

var builder = WebApplication.CreateBuilder(args);

LoadEnv(builder.Environment.ContentRootPath);

builder.Services.AddProblemDetails();
builder.Services.AddCors(options =>
    options.AddDefaultPolicy(policy =>
        policy
            .AllowAnyHeader()
            .AllowAnyMethod()
            .AllowCredentials()
            .SetIsOriginAllowed(_ => true)));

builder.Services.Configure<PairingOptions>(builder.Configuration.GetSection("Pairing"));
builder.Services.AddSingleton<IPairingService, PairingService>();
builder.Services.AddSignalR();

var app = builder.Build();

app.UseCors();
app.UseExceptionHandler();

app.MapGet("/health", () => Results.Ok(new { status = "ok", timestamp = DateTimeOffset.UtcNow }))
    .WithName("HealthCheck")
    .WithSummary("Basic health endpoint for readiness probes.");

app.MapPost("/pairing/start", (StartPairingRequest request, IPairingService pairingService) =>
    {
        if (string.IsNullOrWhiteSpace(request.DeviceId))
        {
            return Results.BadRequest(new { error = "DeviceId is required" });
        }

        var pairingCode = pairingService.GenerateCode(request.DeviceId);
        return Results.Ok(new PairingResponse(request.DeviceId, pairingCode.Code, pairingCode.ExpiresAt));
    })
    .WithName("StartPairing")
    .WithSummary("Generates a short-lived pairing code for local devices.");

app.MapPost("/pairing/confirm", (ConfirmPairingRequest request, IPairingService pairingService) =>
    {
        if (!pairingService.TryConfirm(request.DeviceId, request.Code, out var accessToken, out var expiresAt))
        {
            return Results.BadRequest(new { error = "Invalid or expired pairing code" });
        }

        return Results.Ok(new AccessTokenResponse(request.DeviceId, accessToken, expiresAt));
    })
    .WithName("ConfirmPairing")
    .WithSummary("Exchanges a pairing code for an access token.");

app.MapHub<PulseTuneHub>("/hub/pulsetune");

app.Run();

static void LoadEnv(string root)
{
    var envFile = Path.Combine(root, ".env");
    if (!File.Exists(envFile))
    {
        return;
    }

    foreach (var line in File.ReadAllLines(envFile))
    {
        var trimmed = line.Trim();
        if (string.IsNullOrEmpty(trimmed) || trimmed.StartsWith('#'))
        {
            continue;
        }

        var separatorIndex = trimmed.IndexOf('=');
        if (separatorIndex <= 0)
        {
            continue;
        }

        var key = trimmed[..separatorIndex];
        var value = trimmed[(separatorIndex + 1)..];
        Environment.SetEnvironmentVariable(key, value);
    }
}
