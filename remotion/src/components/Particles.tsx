import React, { useMemo } from 'react';
import { useCurrentFrame, useVideoConfig } from 'remotion';
import { PALETTE, rgba } from '../lib/palette';
import { mulberry32 } from '../lib/rng';
import { TAU } from '../lib/constants';

type Mote = {
  x: number;
  y: number;
  size: number;
  driftX: number;
  driftY: number;
  phase: number;
  cycles: number; // integer twinkle cycles -> seamless
  baseOpacity: number;
  color: string;
  glow: boolean;
};

type Bokeh = {
  x: number;
  y: number;
  size: number;
  driftX: number;
  driftY: number;
  phase: number;
  color: string;
  opacity: number;
};

type Star = {
  birth: number; // frame the streak starts
  x0: number;
  y0: number;
  len: number;
  speed: number; // px per frame
  angle: number;
};

/**
 * Particles — the "intelligence field".
 * Data motes drifting with parallax, bokeh depth discs, a faint
 * constellation mesh and occasional meteor streaks.
 */
export const Particles: React.FC = () => {
  const frame = useCurrentFrame();
  const { durationInFrames: D, width, height } = useVideoConfig();
  const ph = (frame / D) * TAU;

  const { motes, bokehs, stars } = useMemo(() => {
    const rand = mulberry32(20260823);
    const moteList: Mote[] = [];
    for (let i = 0; i < 110; i++) {
      const r = rand();
      const topBias = rand() * rand(); // denser toward the top
      const colorRoll = rand();
      const color =
        colorRoll < 0.78
          ? 'rgba(255,255,255,0.9)'
          : colorRoll < 0.92
            ? PALETTE.purpleLight
            : colorRoll < 0.98
              ? PALETTE.green
              : PALETTE.blue;
      moteList.push({
        x: rand() * width,
        y: r < 0.62 ? topBias * height * 0.72 : rand() * height,
        size: 1 + rand() * 1.8,
        driftX: (rand() - 0.5) * 46,
        driftY: (rand() - 0.5) * 34,
        phase: rand() * TAU,
        cycles: 2 + Math.floor(rand() * 4),
        baseOpacity: 0.24 + rand() * 0.55,
        color,
        glow: rand() < 0.12,
      });
    }

    const bokehList: Bokeh[] = [];
    for (let i = 0; i < 6; i++) {
      const color = i % 2 === 0 ? PALETTE.purple : PALETTE.blue;
      bokehList.push({
        x: rand() * width,
        y: rand() * height * 0.8,
        size: 90 + rand() * 110,
        driftX: (rand() - 0.5) * 120,
        driftY: (rand() - 0.5) * 80,
        phase: rand() * TAU,
        color,
        opacity: 0.035 + rand() * 0.03,
      });
    }

    const starList: Star[] = [];
    for (let i = 0; i < 3; i++) {
      starList.push({
        birth: 90 + i * 300, // 3 streaks per loop
        x0: 300 + rand() * 900,
        y0: 60 + rand() * 300,
        len: 130 + rand() * 90,
        speed: 9 + rand() * 4,
        angle: 24 + rand() * 14,
      });
    }
    return { motes: moteList, bokehs: bokehList, stars: starList };
  }, [width, height]);

  return (
    <>
      {/* Bokeh depth discs */}
      {bokehs.map((b, i) => (
        <div
          key={`b${i}`}
          style={{
            position: 'absolute',
            left: b.x + Math.sin(ph + b.phase) * b.driftX,
            top: b.y + Math.cos(ph + b.phase) * b.driftY,
            width: b.size,
            height: b.size,
            marginLeft: -b.size / 2,
            marginTop: -b.size / 2,
            borderRadius: '50%',
            background: `radial-gradient(circle, ${rgba(b.color, b.opacity)} 0%, transparent 70%)`,
            filter: 'blur(26px)',
            mixBlendMode: 'screen',
          }}
        />
      ))}

      {/* Data motes */}
      {motes.map((m, i) => {
        const x = m.x + Math.sin(ph + m.phase) * m.driftX;
        const y = m.y + Math.cos(ph + m.phase) * m.driftY;
        const twinkle = 0.35 + 0.65 * (0.5 + 0.5 * Math.sin(ph * m.cycles + m.phase));
        const opacity = m.baseOpacity * twinkle;
        return (
          <div
            key={`m${i}`}
            style={{
              position: 'absolute',
              left: x,
              top: y,
              width: m.size,
              height: m.size,
              marginLeft: -m.size / 2,
              marginTop: -m.size / 2,
              borderRadius: '50%',
              background: m.color,
              opacity,
              boxShadow: m.glow ? `0 0 ${m.size * 5}px ${m.color}` : undefined,
            }}
          />
        );
      })}

      {/* Meteor streaks — rare moments of life */}
      {stars.map((s, i) => {
        const age = frame - s.birth;
        if (age < 0 || age > 52) return null;
        const p = age / 52;
        const fade = Math.sin(p * Math.PI) * 0.22;
        const dist = age * s.speed;
        const rad = (s.angle * Math.PI) / 180;
        const cx = s.x0 + Math.cos(rad) * dist;
        const cy = s.y0 + Math.sin(rad) * dist;
        return (
          <div
            key={`s${i}`}
            style={{
              position: 'absolute',
              left: cx,
              top: cy,
              width: s.len,
              height: 2,
              borderRadius: 2,
              transform: `rotate(${s.angle}deg)`,
              transformOrigin: 'left center',
              background: `linear-gradient(90deg, ${rgba(PALETTE.purpleLight, 0)} 0%, ${rgba(PALETTE.purpleLight, fade)} 100%)`,
              boxShadow: `0 0 8px ${rgba(PALETTE.purpleLight, fade * 0.8)}`,
              opacity: 1,
            }}
          />
        );
      })}
    </>
  );
};

/**
 * Constellation — a faint mesh linking "data nodes" in the upper field.
 */
export const Constellation: React.FC = () => {
  const frame = useCurrentFrame();
  const { durationInFrames: D, width, height } = useVideoConfig();
  const ph = (frame / D) * TAU;

  const { nodes, links } = useMemo(() => {
    const rand = mulberry32(777);
    const pts = Array.from({ length: 18 }, () => ({
      x: 80 + rand() * (width - 160),
      y: 60 + rand() * (height * 0.58),
      driftX: (rand() - 0.5) * 30,
      driftY: (rand() - 0.5) * 22,
      phase: rand() * TAU,
    }));
    const linksList: { a: number; b: number }[] = [];
    for (let i = 0; i < pts.length; i++) {
      for (let j = i + 1; j < pts.length; j++) {
        const dx = pts[i].x - pts[j].x;
        const dy = pts[i].y - pts[j].y;
        if (Math.hypot(dx, dy) < 250) linksList.push({ a: i, b: j });
      }
    }
    return { nodes: pts, links: linksList };
  }, [width, height]);

  const pos = nodes.map((n) => ({
    x: n.x + Math.sin(ph + n.phase) * n.driftX,
    y: n.y + Math.cos(ph + n.phase) * n.driftY,
  }));

  return (
    <svg
      width={width}
      height={height}
      style={{ position: 'absolute', inset: 0 }}
    >
      {links.map((l, i) => (
        <line
          key={i}
          x1={pos[l.a].x}
          y1={pos[l.a].y}
          x2={pos[l.b].x}
          y2={pos[l.b].y}
          stroke={rgba(PALETTE.purpleLight, 0.055)}
          strokeWidth={1}
        />
      ))}
      {pos.map((p, i) => (
        <circle
          key={`n${i}`}
          cx={p.x}
          cy={p.y}
          r={1.8}
          fill={rgba(PALETTE.purpleLight, 0.16)}
        />
      ))}
    </svg>
  );
};
