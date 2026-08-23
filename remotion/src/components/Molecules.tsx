import React, { useMemo } from 'react';
import { useCurrentFrame, useVideoConfig } from 'remotion';
import { PALETTE, rgba } from '../lib/palette';
import { mulberry32 } from '../lib/rng';
import { TAU } from '../lib/constants';

type MoleculeSpec = {
  x: number;
  y: number;
  scale: number;
  rot0: number; // base rotation (radians)
  spin: number; // total rotation across the loop (radians, multiple of TAU for seamlessness)
  driftX: number;
  driftY: number;
  phase: number;
  opacity: number;
  bonds: [number, number][]; // atom index pairs
  atoms: { ang: number; r: number; s: number }[];
};

/** Hexagonal "benzene" ring with 1-2 outer atoms — reads instantly as pharma. */
const hexMolecule = (rand: () => number, withOuter: boolean) => {
  const atoms = Array.from({ length: 6 }, (_, i) => ({
    ang: (i / 6) * TAU,
    r: 1,
    s: 0.14 + rand() * 0.07,
  }));
  const bonds: [number, number][] = [
    [0, 1],
    [1, 2],
    [2, 3],
    [3, 4],
    [4, 5],
    [5, 0],
  ];
  if (withOuter) {
    const k = Math.floor(rand() * 6);
    atoms.push({ ang: atoms[k].ang + 0.5, r: 1.75, s: 0.12 });
    bonds.push([k, 6]);
  }
  return { atoms, bonds };
};

/**
 * Molecules — ghostly pharmaceutical structures drifting in the deep
 * field. They rotate by integer multiples of TAU per loop and drift
 * along closed Lissajous paths — perfectly seamless.
 */
export const Molecules: React.FC = () => {
  const frame = useCurrentFrame();
  const { durationInFrames: D, width, height } = useVideoConfig();
  const ph = (frame / D) * TAU;

  const molecules = useMemo(() => {
    const rand = mulberry32(6789);
    const list: MoleculeSpec[] = [];
    const spots = [
      { x: 0.11, y: 0.26 },
      { x: 0.89, y: 0.2 },
      { x: 0.78, y: 0.7 },
      { x: 0.2, y: 0.66 },
      { x: 0.5, y: 0.12 },
    ];
    spots.forEach((sp, i) => {
      const { atoms, bonds } = hexMolecule(rand, rand() < 0.7);
      list.push({
        x: sp.x * width,
        y: sp.y * height,
        scale: (70 + rand() * 60) * (width / 1920),
        rot0: rand() * TAU,
        spin: TAU * (rand() < 0.5 ? 1 : -1),
        driftX: 26 + rand() * 30,
        driftY: 18 + rand() * 22,
        phase: rand() * TAU,
        opacity: 0.13 + rand() * 0.10,
        bonds,
        atoms,
      });
    });
    return list;
  }, [width, height]);

  return (
    <>
      {molecules.map((m, i) => {
        const rot = m.rot0 + (frame / D) * m.spin;
        const cx = m.x + Math.sin(ph + m.phase) * m.driftX;
        const cy = m.y + Math.cos(ph + m.phase) * m.driftY;
        const pts = m.atoms.map((a) => ({
          px: Math.cos(a.ang + rot) * a.r * m.scale,
          py: Math.sin(a.ang + rot) * a.r * m.scale,
          s: a.s * m.scale,
        }));
        const fade = 0.8 + 0.2 * Math.sin(ph + m.phase);
        return (
          <svg
            key={i}
            width={m.scale * 4}
            height={m.scale * 4}
            style={{
              position: 'absolute',
              left: cx - m.scale * 2,
              top: cy - m.scale * 2,
              mixBlendMode: 'screen',
              overflow: 'visible',
            }}
          >
            {m.bonds.map(([a, b], j) => (
              <line
                key={j}
                x1={m.scale * 2 + pts[a].px}
                y1={m.scale * 2 + pts[a].py}
                x2={m.scale * 2 + pts[b].px}
                y2={m.scale * 2 + pts[b].py}
                stroke={rgba(PALETTE.purpleLight, m.opacity * fade)}
                strokeWidth={1.4}
                strokeLinecap="round"
              />
            ))}
            {pts.map((p, j) => (
              <g key={`a${j}`}>
                <circle
                  cx={m.scale * 2 + p.px}
                  cy={m.scale * 2 + p.py}
                  r={p.s}
                  fill={rgba(
                    j % 3 === 0 ? PALETTE.purpleLight : '#FFFFFF',
                    m.opacity * fade * 1.2,
                  )}
                />
                {/* glass/energy inner highlight — 1px hot core */}
                <circle
                  cx={m.scale * 2 + p.px - p.s * 0.28}
                  cy={m.scale * 2 + p.py - p.s * 0.28}
                  r={Math.max(p.s * 0.34, 0.8)}
                  fill={rgba('#FFFFFF', m.opacity * fade * 1.5)}
                />
              </g>
            ))}
          </svg>
        );
      })}
    </>
  );
};
