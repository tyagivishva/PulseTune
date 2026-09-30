# Spotify Setup Guide

_Last updated: Wednesday, September 30, 2026_

PulseTune relies on Spotify Premium features and official developer tooling. Follow this guide to configure OAuth, playback permissions, and development settings without exposing secrets.

## 1. Spotify Developer Dashboard
1. Navigate to the [Spotify Developer Dashboard](https://developer.spotify.com/dashboard/).
2. Log in with the Spotify account that owns a Premium subscription.
3. Create a new application named **PulseTune** (or reuse an existing app).
4. Note the **Client ID**. You will configure this value in PulseTune later.
5. Do **not** copy the client secret into source control; it should remain private.

## 2. Redirect URIs
Add redirect URIs required by each PulseTune surface:

| Platform | Redirect URI (example) | Notes |
|----------|------------------------|-------|
| iOS app  | `pulsetune://auth/spotify` | Configure in app plist + Spotify dashboard. |
| iOS mock (simulator testing) | `pulsetune-dev://auth/spotify` | Optional alternate scheme. |
| ASP.NET Core relay (PKCE fallback) | `http://localhost:5218/auth/callback` | Adjust port to match local launchSettings. |
| Web PWA | `http://localhost:5173/auth/callback` | Matches default Vite dev server. |

Add each URI under **Edit Settings → Redirect URIs → Add**.

## 3. Required Spotify Scopes
PulseTune adheres to least privilege. Confirm these scopes against the latest Spotify documentation before final release:

| Scope | Purpose |
|-------|---------|
| `user-read-playback-state` | Read current playback state and active device. |
| `user-modify-playback-state` | Control playback (play/pause/next/previous). |
| `user-read-currently-playing` | Retrieve current track metadata and progress. |
| `playlist-read-private` | Access user playlists for zone configuration. |
| `streaming` | Required for Web Playback SDK (web client). |
| `user-read-email` *(optional)* | Only if verifying account identity is necessary; omit if not required. |

Document any changes in `docs/DEVELOPMENT.md` with rationale.

## 4. OAuth Flow Overview
- **Mobile & Web Clients**: Use **Authorization Code with PKCE** flow.
- **ASP.NET Relay (optional)**: May use PKCE or standard Authorization Code flow if server stores refresh tokens securely.
- Tokens are short-lived; use refresh tokens and keep them in secure storage.

### PKCE Steps
1. Generate code verifier (`CryptoKit` on iOS, Web Crypto in browsers).
2. Derive code challenge (S256).
3. Initiate authorization request in the system browser/SFSafariViewController.
4. Handle redirect URI and exchange code for tokens.
5. Store access token (Keychain / secure storage) and refresh token (Keychain / secure store).

## 5. Local Configuration Files
Create environment configuration files that are **never committed**.

### iOS / watchOS
1. Duplicate `Config/Secrets.template.xcconfig` → `Config/Secrets.xcconfig` (template will be added later).
2. Add:
   ```
   SPOTIFY_CLIENT_ID = <your client id>
   SPOTIFY_REDIRECT_URI = pulsetune://auth/spotify
   ```
3. Reference `Secrets.xcconfig` from the project build settings.

### Relay (.NET)
Create `services/relay/.env` (ignored by `.gitignore`):
```
SPOTIFY_CLIENT_ID=your-client-id
SPOTIFY_REDIRECT_URI=http://localhost:5218/auth/callback
SPOTIFY_CLIENT_SECRET=your-client-secret   # only if server-side flow is required
```

### Web PWA
Create `apps/web/.env.local` (ignored by `.gitignore`):
```
VITE_SPOTIFY_CLIENT_ID=your-client-id
VITE_SPOTIFY_REDIRECT_URI=http://localhost:5173/auth/callback
```

Ensure these files are listed in `.gitignore`.

## 6. Testing Authentication
1. Start the relevant PulseTune component (iOS app, relay, or web).
2. Trigger Spotify login; the system browser opens to Spotify authorization.
3. Approve requested scopes.
4. Verify tokens are stored securely and playback APIs respond.

## 7. Selecting a Spotify Playback Device
- PulseTune can control any active Spotify Connect device (phone, desktop app, smart speaker) tied to the same account.
- Provide UI for selecting the active device (iOS app + web client).
- If no active device is available, instruct the user to start playback via the Spotify app once; PulseTune can then resume control.

## 8. Common Issues
| Symptom | Resolution |
|---------|------------|
| `403 Forbidden` on playback control | Ensure the account is Premium and the requested scope includes `user-modify-playback-state`. |
| Web Playback SDK refuses to start | Confirm `streaming` scope is granted and Chrome/Edge (not Safari) is used due to DRM restrictions. |
| Access token expires quickly | Implement refresh token rotation and retry logic. |
| Invalid redirect URI | Double-check the URI in Spotify dashboard matches exactly (including trailing slash). |

## 9. Security Checklist
- Never print tokens in logs.
- Store refresh tokens only where secure (Keychain on iOS, secure cookies/server DB for relay).
- Do not share the client secret with mobile or web clients.
- Rotate client secret if it is ever exposed.

## 10. Next Steps
- Complete adaptive engine integration with Spotify playback service.
- Implement device picker, playlist zone mapping, and manual override controls.
- Update `docs/README.md` once end-to-end Spotify playback is validated.
