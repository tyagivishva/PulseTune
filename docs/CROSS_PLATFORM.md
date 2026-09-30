# Cross-Platform Status

_Last updated: Wednesday, September 30, 2026_

PulseTune is designed to operate across Apple and non-Apple devices with two primary modes: standalone iPhone/Apple Watch mode and cross-platform relay mode. This document tracks platform-specific support and limitations.

## Platform Matrix
| Platform | Role | Status | Notes |
|----------|------|--------|-------|
| iPhone (iOS) | Adaptive engine host + Spotify controller | 🚧 In progress | Mock Mode available in simulator; HealthKit + Spotify integration pending. |
| Apple Watch (watchOS) | Workout UI + heart-rate collection | 🚧 In progress | Requires physical watch for live HR. Mock workouts used in simulator. |
| macOS | Development host; optional relay | ✅ Toolchain ready | Spotify control via Relay + PWA planned. |
| Windows | Relay host + PWA | ✅ Planned | .NET 10 and browser support ready; requires local network. |
| Linux | Relay host + PWA | ✅ Planned | .NET and browsers supported. |
| Android | Spotify playback client via PWA | ✅ Planned | Installable PWA for dashboards and manual overrides. |
| Web Browsers (Chromium) | PWA client + Spotify Web Playback | ✅ Planned | Requires `streaming` scope and DRM support. |

## Mode A — Standalone Apple Mode
- Runs entirely on Apple Watch + iPhone.
- Spotify control via App Remote (when Spotify app running) and Web API for playlists.
- Requires live HealthKit access (personal team provisioning acceptable).
- Mock Mode ensures functionality without hardware.

## Mode B — Relay Mode
- iPhone streams normalized events to ASP.NET Core Relay over LAN (SignalR).
- Relay broadcasts to React PWA clients with optional Spotify Web Playback control.
- Pairing protects against unauthorized local control.

## Installation Footprint
- **iOS/watchOS**: Xcode build artifacts; no extra services.
- **Relay**: .NET console app; no database required.
- **Web PWA**: Static assets served by Vite dev server or SSG.

## Offline/Low Connectivity
- Standalone Mode tolerates temporary network drops; Spotify commands queue when offline.
- Relay Mode requires local network connectivity; fails gracefully to standalone mode when disconnected.

## Next Steps
- Implement cross-platform pairing UX.
- Validate Spotify device selection flows for non-Apple clients.
- Add automated integration tests across Swift/C#/TS to ensure domain parity.
