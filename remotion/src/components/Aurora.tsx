import React from 'react';
import { useCurrentFrame, useVideoConfig } from 'remotion';
import { PALETTE, rgba } from '../lib/palette';
import { TAU } from '../lib/constants';

type Blob = {
  w: number;
  h: number;
  left: number;
  top: number;
  gradient: string;
  blur: number;
  dx: number;
  dy: number;
  phase: number;
  baseOpacity: number;
  scaleAmp: number;
};

/**
 * Aurora — volumetric light ribbons drifting through deep space.
 * Every motion is an integer number of cycles across the loop -> seamless.
 */
export const Aurora: React.FC = () => {
  const frame = useCurrentFrame();
  const { durationInFrames: D } = useVideoConfig();
  const ph = (frame / D) * TAU;

  const blobs: Blob[] = [
    {
      // Primary Pulse-purple plume, upper left
      w: 1500,
      h: 1000,
      left: -380,
      top: -340,
      gradient: `radial-gradient(ellipse, ${rgba(PALETTE.purple, 0.42)} 0%, ${rgba(PALETTE.violet, 0.19)} 42%, transparent 70%)`,
      blur: 110,
      dx: 90,
      dy: 55,
      phase: 0,
      baseOpacity: 0.95,
      scaleAmp: 0.05,
    },
    {
      // Blue counter-plume, right side
      w: 1300,
      h: 950,
      left: 1080,
      top: -200,
      gradient: `radial-gradient(ellipse, ${rgba(PALETTE.blue, 0.27)} 0%, ${rgba(PALETTE.violet, 0.10)} 50%, transparent 70%)`,
      blur: 120,
      dx: -75,
      dy: 60,
      phase: Math.PI * 0.55,
      baseOpacity: 0.9,
      scaleAmp: 0.04,
    },
    {
      // Magenta-violet ember, lower center — feeds the ECG zone
      w: 1250,
      h: 800,
      left: 420,
      top: 620,
      gradient: `radial-gradient(ellipse, ${rgba(PALETTE.purpleLight, 0.20)} 0%, ${rgba(PALETTE.purple, 0.10)} 45%, transparent 72%)`,
      blur: 130,
      dx: 60,
      dy: -45,
      phase: Math.PI * 1.1,
      baseOpacity: 0.85,
      scaleAmp: 0.06,
    },
  ];

  return (
    <>
      {blobs.map((b, i) => (
        <div
          key={i}
          style={{
            position: 'absolute',
            width: b.w,
            height: b.h,
            left: b.left + Math.sin(ph + b.phase) * b.dx,
            top: b.top + Math.cos(ph + b.phase) * b.dy,
            background: b.gradient,
            filter: `blur(${b.blur}px)`,
            borderRadius: '50%',
            mixBlendMode: 'screen',
            opacity: b.baseOpacity * (0.82 + 0.18 * Math.sin(ph + b.phase)),
            transform: `scale(${1 + b.scaleAmp * Math.sin(ph + b.phase)})`,
            willChange: 'transform, opacity',
          }}
        />
      ))}
    </>
  );
};

/**
 * ConicSweep — a slow radar-like scan rotating once per loop.
 * Reads subconsciously as "intelligence monitoring".
 */
export const ConicSweep: React.FC = () => {
  const frame = useCurrentFrame();
  const { durationInFrames: D } = useVideoConfig();
  const deg = (frame / D) * 360;

  return (
    <div
      style={{
        position: 'absolute',
        left: '58%',
        top: '40%',
        width: 2600,
        height: 2600,
        marginLeft: -1300,
        marginTop: -1300,
        borderRadius: '50%',
        mixBlendMode: 'screen',
        filter: 'blur(30px)',
        background: `conic-gradient(from ${deg}deg, transparent 0deg, ${rgba(PALETTE.purpleLight, 0.07)} 22deg, transparent 68deg, transparent 185deg, ${rgba(PALETTE.blue, 0.05)} 208deg, transparent 252deg)`,
      }}
    />
  );
};

/**
 * CenterBreath — a barely-there purple heartbeat glow at the focal point.
 */
export const CenterBreath: React.FC = () => {
  const frame = useCurrentFrame();
  const { durationInFrames: D } = useVideoConfig();
  const ph = (frame / D) * TAU;
  return (
    <div
      style={{
        position: 'absolute',
        left: '50%',
        top: '44%',
        width: 1100,
        height: 760,
        marginLeft: -550,
        marginTop: -380,
        borderRadius: '50%',
        background: `radial-gradient(ellipse, ${rgba(PALETTE.purple, 0.07)} 0%, transparent 62%)`,
        mixBlendMode: 'screen',
        transform: `scale(${1 + 0.07 * Math.sin(ph)})`,
        opacity: 0.8 + 0.2 * Math.sin(ph),
      }}
    />
  );
};
