import { PropsWithChildren, useState } from 'react';
import './SpotifyAuthGate.css';

export function SpotifyAuthGate({ children }: PropsWithChildren) {
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  if (isAuthenticated) {
    return <>{children}</>;
  }

  return (
    <div className="spotify-gate">
      <h2>Connect Spotify</h2>
      <p>
        PulseTune needs Spotify authorization to control playback. The current build uses mock mode until you
        complete the OAuth flow.
      </p>
      <button type="button" onClick={() => setIsAuthenticated(true)}>
        Simulate Spotify Login
      </button>
      <p className="note">
        Replace this placeholder with the real Authorization Code with PKCE implementation once Spotify credentials
        are configured.
      </p>
    </div>
  );
}
