import React from 'react';
import { AbsoluteFill } from 'remotion';
import { AtmosphereBase, ScrimsAndVignette, Grain } from './components/Atmosphere';
import { Aurora, ConicSweep, CenterBreath } from './components/Aurora';
import { Particles, Constellation } from './components/Particles';
import { Molecules } from './components/Molecules';
import { EcgField, EcgGlowBed } from './components/EcgField';
import { PulseRings } from './components/PulseRings';

/**
 * PulseField — the Pulse ambient signature film.
 *
 * A cinematic deep-space composition for use as a background layer:
 *   1. Atmosphere   — deep-ink gradients breathing with warmth
 *   2. Aurora       — volumetric purple/blue light plumes
 *   3. Sweep        — a slow intelligence radar
 *   4. Constellation— faint data-node mesh
 *   5. Molecules    — ghostly pharma structures
 *   6. Particles    — data motes, bokeh, meteor streaks
 *   7. ECG          — the luminous heartbeat (signature layer)
 *   8. PulseRings   — sonar blooms from the heart
 *   9. Scrim+Grain  — cinematic finish for text legibility
 *
 * Every motion is an integer number of cycles across the 30s loop,
 * so the film tiles seamlessly forever.
 */
export const PulseField: React.FC = () => {
  return (
    <AbsoluteFill style={{ backgroundColor: '#07070B', overflow: 'hidden' }}>
      <AtmosphereBase />
      <Aurora />
      <ConicSweep />
      <CenterBreath />
      <Constellation />
      <Molecules />
      <Particles />
      <EcgGlowBed />
      <EcgField />
      <PulseRings />
      <ScrimsAndVignette />
      <Grain />
    </AbsoluteFill>
  );
};
