# Apple Platform Setup

_Last updated: Wednesday, September 30, 2026_

This guide explains how to run PulseTune on Apple Watch and iPhone using free Personal Team provisioning whenever possible. Apple features that require a paid Developer Program membership are clearly marked.

## Prerequisites
- macOS with Xcode 16 or later installed
- Apple ID (free) signed into Xcode
- Apple Watch + iPhone paired to the same Apple ID
- Optional: Paid Apple Developer Program membership (USD 99/year) for advanced capabilities

## Recommended Toolchain Installation
1. Install Xcode from the Mac App Store.
2. Launch Xcode once to accept the license and install command-line tools.
3. Confirm command-line tools: `xcode-select -p` should point to `/Applications/Xcode.app/Contents/Developer`.
4. Verify Swift version: `swift --version`.

## Creating the Workspace
```
open PulseTune.xcodeproj   # to be added in the repo
```

> ⚠️ The iOS and watchOS targets will be created during implementation. Keep this document handy for provisioning steps once the Xcode project lands in `apps/ios`.

## Personal Team Provisioning (Free)
1. Open Xcode → Settings → Accounts → sign in with your Apple ID.
2. Select **Managed Teams** → your Personal Team should appear.
3. For each target (iOS & watchOS):
   - Select the target in Xcode.
   - Navigate to **Signing & Capabilities**.
   - Enable **Automatically manage signing**.
   - Choose your **Personal Team**.
4. Add required capabilities:
   - **HealthKit** (iOS & watchOS targets).
   - **Workout Processing** (watchOS target, if available under Personal Team).
   - **Background Modes → Audio, Location updates** (only if Xcode allows under Personal Team; for personal provisioning some background modes may be restricted).

### Limitations Without Paid Membership
| Capability | Personal Team | Paid Program |
|------------|----------------|--------------|
| HealthKit access on physical devices | ✅ | ✅ |
| watchOS app deployment to paired watch | ✅ (with device registration) | ✅ |
| Access to advanced background modes (e.g., `Processing`) | ⚠️ Sometimes limited | ✅ |
| TestFlight distribution | ❌ | ✅ |
| MusicKit developer tokens | ❌ (not needed anymore) | ✅ |
| Push notifications | ❌ | ✅ |

If Xcode refuses to enable a capability under Personal Team, document the error in `docs/DEVELOPMENT.md` and continue using Mock Mode until a paid membership is available.

## Register Devices
Personal Team accounts can deploy to up to three devices per platform. Plug in your iPhone and Apple Watch, allow device pairing, and trust the Mac. Xcode will register them automatically.

## Running on Simulator (No Membership Needed)
1. Build the iOS target for an iPhone simulator.
2. Use Mock Mode to simulate heart-rate data (Settings → Developer Mode → Mock Heart Rate).
3. Spotify playback controls will operate in Mock mode unless real tokens are supplied.

## Deploying to Physical Devices
1. Connect iPhone via USB or Wi-Fi.
2. Select the iPhone as the run destination in Xcode.
3. Build & run. The watchOS app should automatically install if configured as a companion app.
4. On first launch, grant Health permissions and motion/fitness access.
5. If build fails due to entitlements (e.g., Background Modes), temporarily disable the capability and note the limitation.

## Health Permissions Checklist
- `HKQuantityTypeIdentifierHeartRate`
- `HKWorkoutTypeIdentifier`
- **Optional**: `HKQuantityTypeIdentifierActiveEnergyBurned`, `HKQuantityTypeIdentifierDistanceCycling`, etc., if future features need them.

## Troubleshooting
- **“A valid provisioning profile for this executable was not found”**: Clean build folder (`Shift+Cmd+K`), plug device directly via USB, ensure Personal Team is selected.
- **HealthKit entitlement errors**: Remove HealthKit capability, clean, re-add capability, rebuild.
- **Background runtime errors**: Personal Team accounts cannot enable Background Tasks. Use Mock Mode or keep the app in foreground during workouts.
- **Watch app not installing**: Ensure the Watch target’s bundle identifier shares the same prefix as the iOS app and that both use the same team.

## Next Steps
- Complete Spotify configuration (`docs/SPOTIFY_SETUP.md`).
- Implement HealthKit workout session and testing with Personal Team provisioning.
- Document any additional Personal Team limitations in `docs/DEVELOPMENT.md` during implementation.
