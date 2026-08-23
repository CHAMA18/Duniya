import React, { useMemo } from 'react';
import { useCurrentFrame, useVideoConfig } from 'remotion';
import { PALETTE, rgba } from '../lib/palette';
import { mulberry32 } from '../lib/rng';

/** Shared ECG geometry — must mirror EcgField constants. */
const ECG = {
  yCenterFrac: 0.34, // yCenter = width * 0.34
  amplitudeFrac: 0.045,
  beatsVisible: 2.6, // beatWidth = width / 2.6
  totalBeats: 8, // beats per loop
  rPeakPhase: 0.315, // phase within a beat of the R spike
  fireX: 0.62, // x (as width fraction) where rings fire
};

type RingSpec = {
  kind: 'beat' | 'ambient';
  x: number;
  y: number;
  birth: number;
  maxR: number;
  dur: number;
  width: number;
  color: string;
  opacity: number;
  // For beat rings: scroll left with the R peak.
  beatK?: number;
};

/**
 * PulseRings — sonar blooms, synchronized to the heartbeat.
 *
 * BEAT RINGS fire the instant an ECG R-peak crosses x=62% of the
 * frame (the write-head zone), then expand and scroll left WITH the
 * peak — the whole scene visibly beats as one organism. Birth frames
 * tile the loop boundary exactly (8 beats / 900 frames -> period
 * 112.5 frames, wrapping cleanly), so the loop stays seamless.
 *
 * AMBIENT rings bloom more quietly from peripheral anchors.
 */
export const PulseRings: React.FC = () => {
  const frame = useCurrentFrame();
  const { durationInFrames: D, width, height } = useVideoConfig();

  const rings = useMemo<RingSpec[]>(() => {
    const rand = mulberry32(31415);
    const list: RingSpec[] = [];

    // — Beat-synced rings ————————————————————————————————
    const beatPeriod = D / ECG.totalBeats; // 112.5 frames
    const beatWidth = width / ECG.beatsVisible;
    // frame at which R-peak of beat k crosses fireX:
    //   (k + rPeakPhase - (f/D)*totalBeats) * beatWidth = fireX*width
    //   f = (k + rPeakPhase - fireX*beatsVisible) * beatPeriod
    for (let k = 0; k < ECG.totalBeats; k++) {
      const fire =
        (k + ECG.rPeakPhase - ECG.fireX * ECG.beatsVisible) * beatPeriod;
      list.push({
        kind: 'beat',
        x: 0,
        y: 0, // computed live
        birth: ((fire % D) + D) % D,
        maxR: (170 + rand() * 60) * (width / 1920),
        dur: 78 + Math.floor(rand() * 26),
        width: 1.6 + rand() * 0.8,
        color: PALETTE.purpleLight,
        opacity: 0.16 + rand() * 0.06,
        beatK: Math.round(
          fire / beatPeriod + ECG.fireX * ECG.beatsVisible - ECG.rPeakPhase,
        ),
      });
    }

    // — Ambient peripheral rings ——————————————————————————
    const anchors = [
      { x: width * 0.16, y: height * 0.24 },
      { x: width * 0.87, y: height * 0.3 },
      { x: width * 0.72, y: height * 0.8 },
      { x: width * 0.24, y: height * 0.74 },
    ];
    anchors.forEach((a, ai) => {
      for (let k = 0; k < 2; k++) {
        const colorRoll = rand();
        list.push({
          kind: 'ambient',
          x: a.x + (rand() - 0.5) * 40,
          y: a.y + (rand() - 0.5) * 30,
          birth: (ai * D) / anchors.length + (k * D) / 2 - rand() * 30,
          maxR: (150 + rand() * 190) * (width / 1920),
          dur: 72 + Math.floor(rand() * 40),
          width: 1 + rand() * 1.4,
          color:
            colorRoll < 0.55
              ? PALETTE.violet
              : colorRoll < 0.85
                ? PALETTE.purpleLight
                : PALETTE.blue,
          opacity: 0.10 + rand() * 0.08,
        });
      }
    });
    return list;
  }, [width, height, D]);

  const yCenter = width * ECG.yCenterFrac;
  const amplitude = width * ECG.amplitudeFrac;
  const beatWidth = width / ECG.beatsVisible;
  const beatPhase = (frame / D) * ECG.totalBeats;

  const livePosition = (r: RingSpec): { x: number; y: number } => {
    if (r.kind === 'beat' && r.beatK !== undefined) {
      // R-peak x scrolls left as beatPhase grows.
      return { x: (r.beatK + ECG.rPeakPhase - beatPhase) * beatWidth, y: yCenter - amplitude };
    }
    return { x: r.x, y: r.y };
  };

  return (
    <svg
      width={width}
      height={height}
      style={{ position: 'absolute', inset: 0, mixBlendMode: 'screen' }}
    >
      {rings.map((r, i) => {
        let age = frame - r.birth;
        if (age < -r.dur) age += D; // ring born before loop start
        if (age < 0 || age > r.dur) return null;
        const p = age / r.dur;
        const pos = livePosition(r);
        // Sharper leading edge than a plain sine fade — reads intentional.
        const envelope =
          Math.pow(Math.sin(Math.min(p, 1) * Math.PI), 0.72);
        const alpha = r.opacity * envelope;
        const radius = r.maxR * (0.1 + 0.9 * Math.pow(p, 0.5));
        return (
          <g key={`r${i}`}>
            <circle
              cx={pos.x}
              cy={pos.y}
              r={radius}
              fill="none"
              stroke={rgba(r.color, alpha)}
              strokeWidth={r.width * (1 - p * 0.55)}
            />
            {/* crisp leading edge for sharper, more deliberate rings */}
            {r.kind === 'beat' && (
              <circle
                cx={pos.x}
                cy={pos.y}
                r={radius}
                fill="none"
                stroke={rgba('#FFFFFF', alpha * 0.35)}
                strokeWidth={0.7}
              />
            )}
          </g>
        );
      })}
    </svg>
  );
};
