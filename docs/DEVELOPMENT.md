# Development Workflow

_Last updated: Wednesday, September 30, 2026_

This document tracks implementation details, tooling decisions, and known limitations encountered during development.

## Toolchain Summary
- Xcode 26.6 (Swift 6.3.3)
- .NET SDK 10.0.401
- Node.js 25.3.0 / pnpm 11.3.0
- Vite for the web PWA
- Swift Package Manager for shared domain logic

## Building Components
### iOS & watchOS
```
cd apps/ios
xed .   # open Xcode once project exists
```
- Use SwiftUI + Combine.
- Target iOS 18 / watchOS 11 (adjust per actual SDK availability).
- Shared Swift package lives in `Packages/PulseTuneCore` (to be created).

### ASP.NET Core Relay
```
cd services/relay
 dotnet restore
 dotnet run
```
- Project template will use minimal APIs + SignalR.
- Environment configuration pulled from `.env` using `Microsoft.Extensions.Configuration`.

### React/Vite PWA
```
cd apps/web
pnpm install
pnpm dev
```
- TypeScript strict mode enabled.
- Vitest + Testing Library for tests.
- Service worker via Vite PWA plugin.

## Spotify Migration Notes
- All MusicKit dependencies removed; Spotify services under construction.
- `MusicPlaybackService` abstraction retained for testability.
- iOS Spotify integration will use **Spotify App Remote SDK** for low-latency control plus Web API for playlist management where necessary.
- Web client relies on **Spotify Web Playback SDK** (requires Chromium-based browser).

## OAuth & Secrets
- PKCE flow implemented client-side; no client secret stored in mobile/web apps.
- Relay may optionally hold the client secret in local `.env` for server-side refresh token management.
- `.gitignore` covers `.env` and `.xcconfig` secrets.

## Personal Team Findings
- HealthKit + watchOS deployment allowed under Personal Team. Background workout processing TBD (confirm during implementation).
- Document any entitlements that fail with Personal Team in this section.

## Pending Tasks
- Scaffold Swift Package for adaptive engine.
- Implement smoothing/zone logic tests across Swift/xUnit/Vitest.
- Integrate Spotify authentication service (PKCE) on iOS with ASWebAuthenticationSession.
- Set up React PWA authentication wrapper using Spotify PKCE helper.
- Build SignalR hub with pairing/tokens.
- Flesh out documentation for troubleshooting and privacy.

Update this file as milestones complete or new tooling adjustments are made.
