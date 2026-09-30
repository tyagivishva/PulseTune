import { useMemo, useState } from 'react';
import { AdaptiveDashboard } from './components/AdaptiveDashboard';
import { SpotifyAuthGate } from './components/SpotifyAuthGate';
import { useMockHeartbeat } from './hooks/useMockHeartbeat';
import './styles/app.css';

const DEFAULT_ZONE_LABELS = ['Recovery', 'Light', 'Moderate', 'High', 'Peak'] as const;

export default function App() {
  const [adaptiveEnabled, setAdaptiveEnabled] = useState(false);
  const [transitionMode, setTransitionMode] = useState<'smooth' | 'immediate'>('smooth');
  const [relayEnabled, setRelayEnabled] = useState(false);
  const [manualPauseSeconds, setManualPauseSeconds] = useState(300);

  const mock = useMockHeartbeat({ enabled: !adaptiveEnabled });

  const zones = useMemo(
    () =>
      DEFAULT_ZONE_LABELS.map((label, index) => ({
        id: index + 1,
        label
      })),
    []
  );

  return (
    <div className="app-shell">
      <header>
        <h1>PulseTune</h1>
        <p className="subtitle">Heart-rate adaptive Spotify workout controller</p>
      </header>

      <main>
        <SpotifyAuthGate>
          <AdaptiveDashboard
            adaptiveEnabled={adaptiveEnabled}
            onAdaptiveToggle={setAdaptiveEnabled}
            relayEnabled={relayEnabled}
            onRelayToggle={setRelayEnabled}
            transitionMode={transitionMode}
            onTransitionModeChange={setTransitionMode}
            manualPauseSeconds={manualPauseSeconds}
            onManualPauseChange={setManualPauseSeconds}
            currentZone={mock.currentZone}
            bpm={mock.bpm}
            smoothedBpm={mock.smoothedBpm}
            zones={zones}
            mockControls={mock.controls}
          />
        </SpotifyAuthGate>
      </main>

      <footer>
        <p>
          Developer Mode is active using simulated heart-rate data. Connect the relay and Apple Watch to
          stream live workouts.
        </p>
      </footer>
    </div>
  );
}
