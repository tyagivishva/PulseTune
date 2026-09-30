# PulseTune

PulseTune is a heart-rate–adaptive Spotify workout controller optimized for Apple Watch–tracked workouts. It continuously interprets live heart-rate measurements, determines workout intensity zones, and adjusts Spotify playback accordingly while always keeping the listener in control.

## Current Status (September 30, 2026)
- ✅ Repository scaffolded for iOS, watchOS, web PWA, and ASP.NET Core relay apps.
- ✅ Domain model and adaptive engine design in progress with mock implementations.
- 🔄 Migrating music playback to Spotify (replacing prior Apple Music architecture).
- 🔄 Implementing HealthKit-driven heart-rate ingestion with simulator-friendly mock mode.

## Monorepo Layout
```
PulseTune/
├─ apps/
│  ├─ ios/            # SwiftUI iPhone/iPad app
│  ├─ watchos/        # SwiftUI watchOS workout companion
│  └─ web/            # React + Vite PWA client (Spotify + SignalR)
├─ services/
│  └─ relay/          # ASP.NET Core SignalR relay
├─ contracts/         # Shared JSON schemas and message contracts
├─ docs/              # Architecture and setup documentation (Spotify-focused)
├─ README.md          # Project overview (this file)
├─ .gitignore
└─ package.json / etc (to be added per component)
```

## Primary Capabilities
1. **Apple Watch Heart Rate** – Collect live heart-rate data using HealthKit workout sessions (HKWorkoutSession + HKLiveWorkoutBuilder) or simulator/mock sources.
2. **Adaptive Engine** – Smooth raw BPM, compute zone transitions with hysteresis/cooldowns, and select playlists based on intensity zones.
3. **Spotify Control** – Authenticate via Spotify OAuth (Authorization Code with PKCE), fetch playlists, and drive playback through Spotify App Remote / Web API / Web Playback SDK depending on platform.
4. **Cross-Platform Relay** – Optional local SignalR relay broadcasting normalized events to web/desktop clients over the LAN.
5. **Mock & Developer Mode** – Full simulation of heart-rate patterns and playback decisions, enabling development without a real workout.

## Requirements
- **Devices**: Apple Watch + iPhone for live workouts (Deployment requires Personal Team or better; see `docs/APPLE_SETUP.md`).
- **Spotify**: Spotify Premium account and Developer application (see `docs/SPOTIFY_SETUP.md`).
- **Tooling**: Xcode 16+, Swift 6.x, .NET SDK 10, Node 18+, pnpm, Vite.

## Getting Started
1. Clone the repository.
2. Install toolchains (Xcode command line tools, .NET SDK, Node/pnpm).
3. Read `docs/SPOTIFY_SETUP.md` to configure OAuth client ID/redirects.
4. Build and run the iOS app in the simulator using Mock Mode to verify the adaptive engine before moving to device testing.

## Roadmap Highlights
- [ ] Implement shared Swift package `PulseTuneCore` with smoothing/zone engine + tests.
- [ ] Scaffold Spotify authentication service with PKCE and secure token storage.
- [ ] Watch → iPhone heart-rate mirroring using HealthKit and WatchConnectivity fallback.
- [ ] ASP.NET Core SignalR relay with pairing and Spotify-neutral events.
- [ ] React PWA featuring Spotify Web Playback SDK (with mock fallback) and PWA install support.
- [ ] Comprehensive documentation covering privacy, troubleshooting, and cross-platform setup.

## Contributing
Please follow conventional commits (e.g., `feat:`, `fix:`, `docs:`) and ensure tests (`swift test`, `dotnet test`, `pnpm test`) pass before submitting changes.

## License
TBD – choose an open-source license before public release.
