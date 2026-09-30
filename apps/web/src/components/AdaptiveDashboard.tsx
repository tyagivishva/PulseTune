import type { MockHeartbeatControls } from '../hooks/useMockHeartbeat';
import './AdaptiveDashboard.css';

interface ZoneSummary {
  id: number;
  label: string;
}

interface AdaptiveDashboardProps {
  adaptiveEnabled: boolean;
  onAdaptiveToggle: (enabled: boolean) => void;
  relayEnabled: boolean;
  onRelayToggle: (enabled: boolean) => void;
  transitionMode: 'smooth' | 'immediate';
  onTransitionModeChange: (mode: 'smooth' | 'immediate') => void;
  manualPauseSeconds: number;
  onManualPauseChange: (seconds: number) => void;
  bpm: number;
  smoothedBpm: number;
  currentZone?: ZoneSummary;
  zones: ZoneSummary[];
  mockControls: MockHeartbeatControls;
}

const PAUSE_OPTIONS = [0, 300, 900];

export function AdaptiveDashboard({
  adaptiveEnabled,
  onAdaptiveToggle,
  relayEnabled,
  onRelayToggle,
  transitionMode,
  onTransitionModeChange,
  manualPauseSeconds,
  onManualPauseChange,
  bpm,
  smoothedBpm,
  currentZone,
  zones,
  mockControls
}: AdaptiveDashboardProps) {
  return (
    <section className="dashboard">
      <div className="card master-switch">
        <h2>Adaptive Music</h2>
        <button
          className={adaptiveEnabled ? 'toggle active' : 'toggle'}
          onClick={() => onAdaptiveToggle(!adaptiveEnabled)}
          aria-pressed={adaptiveEnabled}
        >
          {adaptiveEnabled ? 'ON' : 'OFF'}
        </button>
        <p>{adaptiveEnabled ? 'Automation active' : 'Automation paused'}</p>
      </div>

      <div className="card metrics">
        <h2>Heart Rate</h2>
        <div className="metric-grid">
          <div>
            <span className="label">Raw</span>
            <span className="value">{Math.round(bpm)} BPM</span>
          </div>
          <div>
            <span className="label">Smoothed</span>
            <span className="value">{Math.round(smoothedBpm)} BPM</span>
          </div>
          <div>
            <span className="label">Zone</span>
            <span className="value">{currentZone?.label ?? '—'}</span>
          </div>
        </div>
        <div className="mock-slider">
          <label htmlFor="mock-bpm">Mock Heart Rate</label>
          <input
            id="mock-bpm"
            type="range"
            min={60}
            max={200}
            value={Math.round(bpm)}
            onChange={(event) => mockControls.setManualBpm(Number(event.target.value))}
          />
        </div>
        <div className="scenario-buttons">
          {(['warmup', 'steady', 'intervals', 'sprint', 'cooldown'] as const).map((scenario) => (
            <button
              key={scenario}
              className={mockControls.activeScenario === scenario ? 'scenario active' : 'scenario'}
              onClick={() => mockControls.playScenario(scenario)}
            >
              {scenario}
            </button>
          ))}
          <button className="scenario" onClick={mockControls.stopScenario} disabled={!mockControls.isScenarioRunning}>
            Stop
          </button>
        </div>
      </div>

      <div className="card transition">
        <h2>Transition Mode</h2>
        <div className="radio-group">
          <label>
            <input
              type="radio"
              name="transition-mode"
              value="smooth"
              checked={transitionMode === 'smooth'}
              onChange={() => onTransitionModeChange('smooth')}
            />
            Smooth (queue next song)
          </label>
          <label>
            <input
              type="radio"
              name="transition-mode"
              value="immediate"
              checked={transitionMode === 'immediate'}
              onChange={() => onTransitionModeChange('immediate')}
            />
            Immediate (skip current song)
          </label>
        </div>
      </div>

      <div className="card manual-pause">
        <h2>Manual Override</h2>
        <label htmlFor="pause-duration">Pause automation after manual song selection</label>
        <select
          id="pause-duration"
          value={manualPauseSeconds}
          onChange={(event) => onManualPauseChange(Number(event.target.value))}
        >
          {PAUSE_OPTIONS.map((seconds) => (
            <option key={seconds} value={seconds}>
              {seconds === 0 ? 'Disabled' : `${Math.round(seconds / 60)} min`}
            </option>
          ))}
        </select>
      </div>

      <div className="card relay">
        <h2>Relay Mode</h2>
        <p>Broadcast heart-rate and zone events to local devices.</p>
        <button
          className={relayEnabled ? 'toggle active' : 'toggle'}
          onClick={() => onRelayToggle(!relayEnabled)}
          aria-pressed={relayEnabled}
        >
          {relayEnabled ? 'Enabled' : 'Disabled'}
        </button>
      </div>

      <div className="card zones">
        <h2>Zones</h2>
        <ol>
          {zones.map((zone) => (
            <li key={zone.id} className={ zone.id === currentZone?.id ? 'active' : undefined }>
              <span className="zone-index">{zone.id}</span>
              <span>{zone.label}</span>
            </li>
          ))}
        </ol>
      </div>
    </section>
  );
}
