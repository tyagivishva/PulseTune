# Privacy Principles

_Last updated: Wednesday, September 30, 2026_

PulseTune handles sensitive health and playback data. This document outlines the privacy guarantees and configurable options.

## Data Collection
- **Heart Rate**: Collected via HealthKit during active workouts. Samples remain on-device unless Relay Mode is enabled.
- **Workout Metadata**: Start/end time, duration, zone summaries, and optional playback history stored locally when the user enables history retention.
- **Spotify Data**: Access tokens, playback state, playlist metadata fetched securely via Spotify APIs.

## Default Behavior
- Adaptive Mode is opt-in and disabled on first launch.
- Relay Mode is disabled by default; enabling it requires explicit confirmation and pairing.
- Workout history persistence is disabled by default; no long-term storage unless user enables "Save Workout History".

## Storage Locations
| Data | Location | Retention |
|------|----------|-----------|
| Heart-rate samples (live) | In-memory only | Discarded after processing |
| Workout summaries | Local database (Core Data/SQLite) | Optional; user can delete |
| Spotify tokens | iOS Keychain / secure storage | Revoked on logout |
| Relay pairing tokens | In-memory + volatile file | Expires when session ends |
| PWA auth state | Browser secure storage (PKCE) | Cleared on logout |

## Sharing & Transmission
- Relay broadcasts contain only pseudonymous device IDs, smoothed BPM, zone data, and playback summary. Personal identifiers, Apple IDs, or Spotify tokens are never transmitted.
- HTTPS/TLS is recommended when hosting relay/control endpoints outside the local network. Default LAN setup uses HTTP; document the security trade-off in `docs/TROUBLESHOOTING.md`.

## User Controls
- **Adaptive Music ON/OFF**: Master switch halts automation instantly.
- **Pause Automation**: Temporarily suspends automatic song changes.
- **Relay Mode**: Toggle to enable/disable LAN broadcasting.
- **Save Workout History**: Off by default; when enabled, users can delete history from the History screen.
- **Developer Mode**: Grants access to mock heart-rate generators and verbose logging. Logging of raw samples remains opt-in.

## Compliance Notes
- PulseTune is not a medical device. Display disclaimers in-app and documentation.
- HealthKit data must never leave the device without explicit user action. Ensure HealthKit usage descriptions are accurate (`NSHealthShareUsageDescription`, etc.).
- Spotify Terms of Service prohibit storing user passwords; rely solely on OAuth.

## Future Work
- Encrypt local workout history database (SQLCipher) if security requirements increase.
- Implement optional passcode/biometric lock for opening the app before workout data is shown.
- Provide export tools compliant with GDPR/CCPA should the app be distributed internationally.
