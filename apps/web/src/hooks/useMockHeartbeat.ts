import { useCallback, useEffect, useMemo, useRef, useState } from 'react';

const DEFAULT_SMOOTHING_FACTOR = 0.25;

const SCENARIOS: Record<string, number[]> = {
  warmup: [90, 95, 100, 110, 120],
  steady: [120, 125, 130, 132, 135, 138, 140],
  intervals: [110, 150, 115, 155, 120, 160, 125, 165],
  sprint: [130, 150, 170, 180, 185, 170, 150],
  cooldown: [150, 145, 135, 125, 115, 105, 95]
};

type Zone = {
  id: number;
  label: string;
  min: number;
  max?: number;
};

const ZONES: Zone[] = [
  { id: 1, label: 'Recovery', min: 0, max: 100 },
  { id: 2, label: 'Light', min: 100, max: 124 },
  { id: 3, label: 'Moderate', min: 125, max: 149 },
  { id: 4, label: 'High', min: 150, max: 169 },
  { id: 5, label: 'Peak', min: 170 }
];

export interface MockHeartbeatControls {
  isScenarioRunning: boolean;
  activeScenario?: string;
  setManualBpm: (value: number) => void;
  playScenario: (name: keyof typeof SCENARIOS) => void;
  stopScenario: () => void;
}

interface UseMockHeartbeatOptions {
  enabled: boolean;
}

interface MockHeartbeatState {
  bpm: number;
  smoothedBpm: number;
  currentZone: { id: number; label: string } | undefined;
  controls: MockHeartbeatControls;
}

export function useMockHeartbeat({ enabled }: UseMockHeartbeatOptions): MockHeartbeatState {
  const [bpm, setBpm] = useState(120);
  const [smoothedBpm, setSmoothedBpm] = useState(120);
  const [activeScenario, setActiveScenario] = useState<string | undefined>();
  const scenarioIndexRef = useRef(0);
  const scenarioTimerRef = useRef<ReturnType<typeof setInterval> | null>(null);

  const clearScenarioTimer = useCallback(() => {
    if (scenarioTimerRef.current) {
      clearInterval(scenarioTimerRef.current);
      scenarioTimerRef.current = null;
    }
  }, []);

  const stopScenario = useCallback(() => {
    clearScenarioTimer();
    setActiveScenario(undefined);
    scenarioIndexRef.current = 0;
  }, [clearScenarioTimer]);

  const setManualBpm = useCallback(
    (value: number) => {
      stopScenario();
      setBpm(Math.max(50, Math.min(value, 210)));
    },
    [stopScenario]
  );

  const playScenario = useCallback(
    (name: keyof typeof SCENARIOS) => {
      stopScenario();
      const sequence = SCENARIOS[name];
      setActiveScenario(name);
      scenarioIndexRef.current = 0;
      setBpm(sequence[0]);
      scenarioTimerRef.current = setInterval(() => {
        scenarioIndexRef.current = (scenarioIndexRef.current + 1) % sequence.length;
        setBpm(sequence[scenarioIndexRef.current]);
      }, 2000);
    },
    [stopScenario]
  );

  useEffect(() => {
    if (!enabled) {
      // Pause simulation when adaptive mode is active to avoid conflicting data.
      stopScenario();
    }
  }, [enabled, stopScenario]);

  useEffect(() => {
    return () => {
      clearScenarioTimer();
    };
  }, [clearScenarioTimer]);

  useEffect(() => {
    setSmoothedBpm((previous) => {
      if (!Number.isFinite(previous)) {
        return bpm;
      }
      return DEFAULT_SMOOTHING_FACTOR * bpm + (1 - DEFAULT_SMOOTHING_FACTOR) * previous;
    });
  }, [bpm]);

  const zone = useMemo(() => {
    const value = smoothedBpm;
    return ZONES.find((candidate) => {
      const withinLower = value >= candidate.min;
      const withinUpper = candidate.max === undefined || value <= candidate.max;
      return withinLower && withinUpper;
    });
  }, [smoothedBpm]);

  const controls = useMemo<MockHeartbeatControls>(
    () => ({
      isScenarioRunning: Boolean(activeScenario),
      activeScenario,
      setManualBpm,
      playScenario,
      stopScenario
    }),
    [activeScenario, playScenario, setManualBpm, stopScenario]
  );

  return {
    bpm,
    smoothedBpm,
    currentZone: zone ? { id: zone.id, label: zone.label } : undefined,
    controls
  };
}
