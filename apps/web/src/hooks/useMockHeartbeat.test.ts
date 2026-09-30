import { act, renderHook } from '@testing-library/react';
import { beforeEach, describe, expect, test, vi } from 'vitest';
import { useMockHeartbeat } from './useMockHeartbeat';

describe('useMockHeartbeat', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });

  test('applies smoothing when BPM changes', () => {
    const { result } = renderHook(() => useMockHeartbeat({ enabled: true }));

    act(() => {
      result.current.controls.setManualBpm(160);
    });

    expect(result.current.bpm).toBe(160);
    expect(Math.round(result.current.smoothedBpm)).toBeGreaterThan(120);

    act(() => {
      vi.advanceTimersByTime(2000);
      result.current.controls.setManualBpm(180);
    });

    expect(result.current.bpm).toBe(180);
    expect(Math.round(result.current.smoothedBpm)).toBeGreaterThan(150);
  });

  test('plays interval scenario sequentially', () => {
    const { result } = renderHook(() => useMockHeartbeat({ enabled: true }));

    act(() => {
      result.current.controls.playScenario('intervals');
    });

    const firstBpm = result.current.bpm;
    act(() => {
      vi.advanceTimersByTime(2000);
    });
    const secondBpm = result.current.bpm;

    expect(result.current.controls.activeScenario).toBe('intervals');
    expect(firstBpm).not.toBe(secondBpm);

    act(() => {
      result.current.controls.stopScenario();
    });

    expect(result.current.controls.isScenarioRunning).toBe(false);
  });
});
