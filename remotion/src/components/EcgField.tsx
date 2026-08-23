import React, { useMemo } from 'react';
import { useCurrentFrame, useVideoConfig } from 'remotion';
import { PALETTE, rgba } from '../lib/palette';
import { buildEcgPath } from '../lib/ecg';

/**
 * EcgField — THE signature Pulse motif.
 * A luminous electrocardiogram tracing left-to-right across the frame,
 * built from three layered passes: a wide soft "bloom" stroke, the
 * crisp core line, and a leading "pen" glow at the write-head.
 *
 * Loop math: the path offset moves exactly (beats on screen + 1) beats
 * per loop so frame 0 and frame D draw the identical path.
 */
export const EcgField: React.FC = () => {
  const frame = useCurrentFrame();
  const { durationInFrames: D, width } = useVideoConfig();

  // Elevated to the vertical golden ratio (~60.4% of height) per director
  // review — more heroic tension, less "footer graphic".
  const yCenter = width * 0.34;
  const amplitude = width * 0.045;
  const beatWidth = width / 2.6; // ~2.6 beats visible
  const totalBeats = 8; // beats traversed per loop
  const offset = (frame / D) * beatWidth * totalBeats;

  // Layered strokes: [width, blur, opacity, color]
  const passes = [
    { w: 26, blur: 26, opacity: 0.10, color: PALETTE.purple },
    { w: 12, blur: 12, opacity: 0.16, color: PALETTE.violet },
    { w: 4.5, blur: 4, opacity: 0.62, color: PALETTE.purpleLight },
    { w: 1.6, blur: 0, opacity: 0.95, color: '#F4EBFF' },
  ] as const;

  const path = useMemo(
    () => buildEcgPath({ width, yCenter, amplitude, beatWidth, offset }),
    [width, yCenter, amplitude, beatWidth, offset],
  );

  /**
   * Write-head — rides the REAL R-peak nearest the right of screen.
   * R peaks sit at x = (k + 0.315 - offset/beatWidth) * beatWidth;
   * they scroll left as offset grows, so the head crosses the frame
   * like a living monitor trace. A soft trailing streak implies speed.
   */
  const beatPhase = offset / beatWidth;
  const rPeakXofBeat = (k: number) => (k + 0.315 - beatPhase) * beatWidth;
  let headK = Math.ceil(beatPhase - 0.315 + (width * 0.9) / beatWidth);
  for (let k = headK + 3; k >= headK - 3; k--) {
    if (rPeakXofBeat(k) <= width * 0.9) {
      headK = k;
      break;
    }
  }
  const headX = rPeakXofBeat(headK);
  const headY = yCenter - amplitude; // R peak apex

  return (
    <svg
      width={width}
      height={1080}
      style={{ position: 'absolute', inset: 0, mixBlendMode: 'screen' }}
    >
      {passes.map((p, i) => (
        <path
          key={i}
          d={path}
          fill="none"
          stroke={p.color}
          strokeWidth={p.w}
          strokeOpacity={p.opacity}
          filter={p.blur > 0 ? `blur(${p.blur}px)` : undefined}
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      ))}
      {/* write-head glow riding the R peak */}
      <circle cx={headX} cy={headY} r={6} fill={rgba('#FFFFFF', 0.95)} />
      <circle
        cx={headX}
        cy={headY}
        r={16}
        fill={rgba(PALETTE.purpleLight, 0.4)}
        filter="blur(9px)"
      />
      <circle
        cx={headX}
        cy={headY}
        r={34}
        fill={rgba(PALETTE.purple, 0.22)}
        filter="blur(16px)"
      />
      {/* trailing streak — implied motion blur to the right of the head */}
      <rect
        x={headX}
        y={headY - 1.2}
        width={90}
        height={2.4}
        rx={1.2}
        fill={rgba(PALETTE.purpleLight, 0.30)}
        filter="blur(2px)"
      />
    </svg>
  );
};

/**
 * EcgGlowBed — a soft luminous bed under the ECG line so the trace
 * appears to emit light onto the "floor" of the scene.
 */
export const EcgGlowBed: React.FC = () => {
  const { width } = useVideoConfig();
  const yCenter = width * 0.34;
  return (
    <div
      style={{
        position: 'absolute',
        left: 0,
        right: 0,
        top: yCenter - width * 0.075,
        height: width * 0.16,
        background: `linear-gradient(90deg, transparent, ${rgba(PALETTE.purple, 0.12)} 30%, ${rgba(PALETTE.violet, 0.13)} 55%, transparent)`,
        filter: 'blur(46px)',
        mixBlendMode: 'screen',
      }}
    />
  );
};
