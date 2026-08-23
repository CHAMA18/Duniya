import React from 'react';
import { useCurrentFrame, useVideoConfig } from 'remotion';
import { PALETTE, rgba } from '../lib/palette';
import { TAU } from '../lib/constants';

/**
 * Atmosphere — the cinematic base.
 * Deep-ink gradients, breathing radial warmth, scrims, vignette and grain.
 */
export const AtmosphereBase: React.FC = () => {
  const frame = useCurrentFrame();
  const { durationInFrames: D } = useVideoConfig();
  const ph = (frame / D) * TAU;

  const breath1 = 0.75 + 0.25 * Math.sin(ph);
  const breath2 = 0.75 + 0.25 * Math.sin(ph + Math.PI);

  return (
    <>
      {/* Deep-ink base gradient */}
      <div
        style={{
          position: 'absolute',
          inset: 0,
          background: `linear-gradient(160deg, ${PALETTE.ink2} 0%, ${PALETTE.ink} 52%, ${PALETTE.ink3} 100%)`,
        }}
      />
      {/* Breathing radial warmth — lower left (purple) */}
      <div
        style={{
          position: 'absolute',
          left: -600,
          top: 200,
          width: 1800,
          height: 1400,
          background: `radial-gradient(ellipse, ${rgba(PALETTE.purple, 0.13)} 0%, transparent 65%)`,
          opacity: breath1,
          mixBlendMode: 'screen',
        }}
      />
      {/* Breathing radial — upper right (blue) */}
      <div
        style={{
          position: 'absolute',
          right: -500,
          top: -400,
          width: 1600,
          height: 1300,
          background: `radial-gradient(ellipse, ${rgba(PALETTE.blue, 0.09)} 0%, transparent 65%)`,
          opacity: breath2,
          mixBlendMode: 'screen',
        }}
      />
      {/* Signal floor — soft purple bed beneath the ECG zone */}
      <div
        style={{
          position: 'absolute',
          left: 0,
          right: 0,
          bottom: 0,
          height: '42%',
          background: `linear-gradient(180deg, transparent 0%, ${rgba(PALETTE.violet, 0.07)} 70%, ${rgba(PALETTE.purple, 0.05)} 100%)`,
          mixBlendMode: 'screen',
        }}
      />
    </>
  );
};

export const ScrimsAndVignette: React.FC = () => {
  return (
    <>
      {/* Top scrim — blends under the navbar */}
      <div
        style={{
          position: 'absolute',
          inset: 0,
          background: `linear-gradient(180deg, ${rgba('#07070B', 0.62)} 0%, transparent 16%)`,
        }}
      />
      {/* Bottom fade — melts into the page background below the hero */}
      <div
        style={{
          position: 'absolute',
          inset: 0,
          background: `linear-gradient(0deg, ${rgba('#07070B', 0.92)} 0%, ${rgba('#07070B', 0.35)} 14%, transparent 30%)`,
        }}
      />
      {/* Cinematic vignette — slightly relaxed so the frame breathes */}
      <div
        style={{
          position: 'absolute',
          inset: 0,
          background: `radial-gradient(ellipse 84% 74% at 50% 46%, transparent 55%, ${rgba('#050508', 0.42)} 100%)`,
        }}
      />
    </>
  );
};

export const Grain: React.FC = () => {
  const frame = useCurrentFrame();
  const { durationInFrames: D } = useVideoConfig();
  const t = frame / D;
  // Drift exactly 2 x 1 tiles over the loop -> seamless.
  const px = -512 * t;
  const py = -256 * t;
  return (
    <div
      style={{
        position: 'absolute',
        inset: 0,
        opacity: 0.05,
        mixBlendMode: 'overlay',
        backgroundImage: 'url(static://noise.png)',
        backgroundRepeat: 'repeat',
        backgroundPosition: `${px}px ${py}px`,
      }}
    />
  );
};
