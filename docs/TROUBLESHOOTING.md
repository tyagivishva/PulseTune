# Troubleshooting Guide

_Last updated: Wednesday, September 30, 2026_

This guide captures common issues encountered while developing and running PulseTune across platforms.

## Spotify Authentication
- **Symptom**: Browser shows `INVALID_CLIENT`.
  - **Fix**: Ensure redirect URI matches exactly (case-sensitive) in the Spotify dashboard and local config.
- **Symptom**: Authorization screen reports missing Premium.
  - **Fix**: Spotify playback control requires Premium; verify account tier.
- **Symptom**: Web Playback SDK fails to initialize.
  - **Fix**: Use Chrome/Edge; Safari lacks EME support. Confirm `streaming` scope granted.

## Spotify Playback
- **Symptom**: `403 Forbidden` on `player/next` endpoint.
  - **Fix**: User must have an active Spotify Connect device. Start playback from Spotify app once to register device.
- **Symptom**: App Remote disconnects on iOS.
  - **Fix**: Ensure Spotify app is installed and running in the foreground/background. Reconnect using `SpotifyAppRemote` connection flow.

## HealthKit & Workouts
- **Symptom**: Permission denied dialog.
  - **Fix**: Update `Info.plist` usage descriptions for HealthKit. In Health app, toggle access for PulseTune.
- **Symptom**: Heart-rate values stop during background execution.
  - **Fix**: Personal Team accounts may lack full background workout entitlement. Keep app foregrounded or acquire paid membership. Document the limitation in `docs/DEVELOPMENT.md`.

## watchOS Deployment
- **Symptom**: "WatchKit companion not found" error.
  - **Fix**: Ensure iOS and watchOS bundle identifiers share the same prefix and use the same provisioning team.
- **Symptom**: App does not auto-install on the watch.
  - **Fix**: In the Watch app on iPhone, enable "Show App on Apple Watch" manually.

## Relay & SignalR
- **Symptom**: Relay clients cannot connect.
  - **Fix**: Confirm the relay is running and accessible via LAN. Check firewall rules on Windows/macOS/Linux.
- **Symptom**: Pairing times out.
  - **Fix**: Verify desktop and phone are on the same network. Regenerate pairing code and retry.

## Web PWA
- **Symptom**: Install prompt not showing.
  - **Fix**: Ensure served over HTTPS (or `localhost`) and all specified assets exist. For development, Vite must run on `http://localhost`.
- **Symptom**: PWA shows blank screen offline.
  - **Fix**: Rebuild service worker after adding new assets. `pnpm build` + `pnpm preview` to verify offline caching.

## General Debugging Tips
- Use Mock Mode to reproduce heart-rate edge cases without hardware.
- Enable verbose logging in Developer Mode (avoid logging tokens/raw HealthKit data).
- Run unit tests regularly: `swift test`, `dotnet test`, `pnpm test`.
- Document new issues here as implementation progresses.
