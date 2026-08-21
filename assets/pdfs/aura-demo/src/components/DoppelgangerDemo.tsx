import React from "react";
import {
  AbsoluteFill,
  useCurrentFrame,
  useVideoConfig,
  interpolate,
  spring,
  Sequence,
} from "remotion";

// ── Brand Colors ──
const C = {
  bg: "#0B0614",
  surface: "#1A1330",
  primary: "#7C3AED",
  accent: "#A78BFA",
  highlight: "#C4B5FD",
  text: "#F3F4F6",
  muted: "#9CA3AF",
  green: "#10B981",
  red: "#EF4444",
  amber: "#F59E0B",
};

// ── Data Point Component ──
const DataPoint: React.FC<{
  x: number;
  y: number;
  color: string;
  size: number;
  opacity: number;
  label?: string;
}> = ({ x, y, color, size, opacity, label }) => (
  <div
    style={{
      position: "absolute",
      left: x,
      top: y,
      width: size,
      height: size,
      borderRadius: "50%",
      backgroundColor: color,
      opacity,
      boxShadow: `0 0 ${size}px ${color}`,
    }}
  >
    {label && (
      <div
        style={{
          position: "absolute",
          bottom: -20,
          left: "50%",
          transform: "translateX(-50%)",
          fontSize: 10,
          color: C.muted,
          whiteSpace: "nowrap",
        }}
      >
        {label}
      </div>
    )}
  </div>
);

// ── Pulse Wave ──
const PulseWave: React.FC<{ frame: number; centerX: number; centerY: number }> = ({
  frame,
  centerX,
  centerY,
}) => {
  const rings = [0, 1, 2, 3, 4];
  return (
    <>
      {rings.map((i) => {
        const delay = i * 8;
        const progress = Math.max(0, (frame - delay) % 60) / 60;
        const scale = 1 + progress * 3;
        const opacity = 1 - progress;
        return (
          <div
            key={i}
            style={{
              position: "absolute",
              left: centerX - 20,
              top: centerY - 20,
              width: 40,
              height: 40,
              borderRadius: "50%",
              border: `2px solid ${C.primary}`,
              transform: `scale(${scale})`,
              opacity: opacity * 0.5,
            }}
          />
        );
      })}
    </>
  );
};

// ── Main Demo Composition ──
export const DoppelgangerDemo: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // ── Phase timing ──
  const phase1End = 90; // 3s - Normal behaviour
  const phase2End = 210; // 7s - Divergence begins
  const phase3End = 330; // 11s - Alert triggers
  const phase4End = 450; // 15s - Resolution

  // ── Customer avatar ──
  const avatarX = 960;
  const avatarY = 200;

  // ── Behaviour line points (20 data points) ──
  const dataPoints = Array.from({ length: 20 }, (_, i) => {
    const baseX = 200 + i * 75;
    const normalY = 500 + Math.sin(i * 0.5) * 30;

    // Divergence starts at point 10
    let actualY = normalY;
    let isDiverged = false;

    if (i >= 10) {
      const divergence = (i - 10) * 15;
      actualY = normalY - divergence;
      isDiverged = true;
    }

    // Animation progress for this point
    const pointAppearFrame = i * 12;
    const pointProgress = Math.max(0, Math.min(1, (frame - pointAppearFrame) / 20));

    // Divergence highlight
    const showDivergence = i >= 10 && frame > phase1End;
    const divergenceOpacity = showDivergence
      ? interpolate(frame, [phase1End, phase1End + 30], [0, 1], { extrapolateRight: "clamp" })
      : 0;

    return {
      x: baseX,
      normalY,
      actualY,
      isDiverged,
      opacity: pointProgress,
      divergenceOpacity,
    };
  });

  // ── Title animations ──
  const titleOpacity = interpolate(frame, [0, 30], [0, 1], { extrapolateRight: "clamp" });
  const titleY = interpolate(frame, [0, 30], [30, 0], { extrapolateRight: "clamp" });

  // ── Phase labels ──
  const showPhase1 = frame < phase1End;
  const showPhase2 = frame >= phase1End && frame < phase2End;
  const showPhase3 = frame >= phase2End && frame < phase3End;
  const showPhase4 = frame >= phase3End;

  const phaseLabel = showPhase1
    ? "NORMAL BEHAVIOUR"
    : showPhase2
    ? "DIVERGENCE DETECTED"
    : showPhase3
    ? "ALERT TRIGGERED"
    : "LOSS PREVENTED";

  const phaseColor = showPhase1
    ? C.green
    : showPhase2
    ? C.amber
    : showPhase3
    ? C.red
    : C.green;

  // ── Doppelgänger glow ──
  const doppelGlow = showPhase2 || showPhase3
    ? interpolate(frame, [phase1End, phase1End + 20], [0, 1], { extrapolateRight: "clamp" })
    : 0;

  // ── Alert pulse ──
  const alertPulse = showPhase3
    ? 0.5 + Math.sin(frame * 0.3) * 0.5
    : 0;

  // ── Resolution checkmark ──
  const checkScale = showPhase4
    ? spring({ frame: frame - phase3End, fps, config: { damping: 10 } })
    : 0;

  return (
    <AbsoluteFill
      style={{
        backgroundColor: C.bg,
        fontFamily: "-apple-system, 'Segoe UI', Arial, sans-serif",
      }}
    >
      {/* ── Background grid ── */}
      <div
        style={{
          position: "absolute",
          inset: 0,
          backgroundImage: `
            linear-gradient(${C.primary}10 1px, transparent 1px),
            linear-gradient(90deg, ${C.primary}10 1px, transparent 1px)
          `,
          backgroundSize: "50px 50px",
          opacity: 0.3,
        }}
      />

      {/* ── Title ── */}
      <div
        style={{
          position: "absolute",
          top: 40,
          left: 60,
          opacity: titleOpacity,
          transform: `translateY(${titleY}px)`,
        }}
      >
        <div
          style={{
            fontSize: 14,
            color: C.primary,
            letterSpacing: 4,
            fontWeight: 700,
            marginBottom: 8,
          }}
        >
          AURA · LIVE DEMO
        </div>
        <div style={{ fontSize: 36, color: C.text, fontWeight: 800 }}>
          Personal Doppelgänger
        </div>
        <div style={{ fontSize: 16, color: C.muted, marginTop: 4 }}>
          Real-time behavioural divergence detection
        </div>
      </div>

      {/* ── Phase indicator ── */}
      <div
        style={{
          position: "absolute",
          top: 50,
          right: 60,
          display: "flex",
          alignItems: "center",
          gap: 12,
        }}
      >
        <div
          style={{
            width: 12,
            height: 12,
            borderRadius: "50%",
            backgroundColor: phaseColor,
            boxShadow: `0 0 20px ${phaseColor}`,
            opacity: showPhase3 ? alertPulse : 1,
          }}
        />
        <div
          style={{
            fontSize: 14,
            color: phaseColor,
            letterSpacing: 2,
            fontWeight: 700,
          }}
        >
          {phaseLabel}
        </div>
      </div>

      {/* ── Customer avatar ── */}
      <div
        style={{
          position: "absolute",
          left: avatarX - 40,
          top: avatarY - 40,
        }}
      >
        <div
          style={{
            width: 80,
            height: 80,
            borderRadius: "50%",
            background: `linear-gradient(135deg, ${C.primary}, ${C.accent})`,
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontSize: 32,
            color: C.text,
            fontWeight: 700,
            boxShadow: doppelGlow > 0
              ? `0 0 ${30 * doppelGlow}px ${C.primary}`
              : "none",
          }}
        >
          M
        </div>
        <div
          style={{
            textAlign: "center",
            marginTop: 8,
            fontSize: 14,
            color: C.text,
            fontWeight: 600,
          }}
        >
          Mei, 34
        </div>
        <div
          style={{
            textAlign: "center",
            fontSize: 11,
            color: C.muted,
          }}
        >
          Customer
        </div>
      </div>

      {/* ── Doppelgänger avatar ── */}
      <Sequence from={30}>
        <div
          style={{
            position: "absolute",
            left: avatarX + 120,
            top: avatarY - 40,
            opacity: interpolate(frame - 30, [0, 20], [0, 1], { extrapolateLeft: "clamp", extrapolateRight: "clamp" }),
          }}
        >
          <div
            style={{
              width: 80,
              height: 80,
              borderRadius: "50%",
              background: `linear-gradient(135deg, ${C.accent}80, ${C.primary}80)`,
              border: `2px solid ${C.accent}`,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              fontSize: 28,
              color: C.text,
            }}
          >
            👤
          </div>
          <div
            style={{
              textAlign: "center",
              marginTop: 8,
              fontSize: 14,
              color: C.accent,
              fontWeight: 600,
            }}
          >
            Doppelgänger
          </div>
          <div
            style={{
              textAlign: "center",
              fontSize: 11,
              color: C.muted,
            }}
          >
            Predicted state
          </div>
        </div>
      </Sequence>

      {/* ── Connection line ── */}
      <Sequence from={40}>
        <svg
          style={{ position: "absolute", top: 0, left: 0 }}
          width={1920}
          height={1080}
        >
          <line
            x1={avatarX + 40}
            y1={avatarY + 80}
            x2={avatarX + 160}
            y2={avatarY + 80}
            stroke={C.accent}
            strokeWidth={2}
            strokeDasharray="5,5"
            opacity={interpolate(frame - 40, [0, 20], [0, 0.5], { extrapolateLeft: "clamp", extrapolateRight: "clamp" })}
          />
        </svg>
      </Sequence>

      {/* ── Behaviour graph ── */}
      <div
        style={{
          position: "absolute",
          left: 150,
          top: 380,
          width: 1620,
          height: 350,
        }}
      >
        {/* Graph background */}
        <div
          style={{
            position: "absolute",
            inset: 0,
            backgroundColor: C.surface + "80",
            borderRadius: 16,
            border: `1px solid ${C.primary}40`,
          }}
        />

        {/* Y-axis labels */}
        {["High", "Medium", "Low"].map((label, i) => (
          <div
            key={label}
            style={{
              position: "absolute",
              left: 10,
              top: 30 + i * 120,
              fontSize: 11,
              color: C.muted,
            }}
          >
            {label}
          </div>
        ))}

        {/* Grid lines */}
        {[0, 1, 2].map((i) => (
          <div
            key={i}
            style={{
              position: "absolute",
              left: 60,
              top: 40 + i * 120,
              right: 20,
              height: 1,
              backgroundColor: C.primary + "20",
            }}
          />
        ))}

        {/* ── Normal behaviour line (prediction) ── */}
        <svg
          style={{ position: "absolute", top: 0, left: 0 }}
          width={1620}
          height={350}
        >
          <defs>
            <linearGradient id="normalGrad" x1="0%" y1="0%" x2="100%" y2="0%">
              <stop offset="0%" stopColor={C.accent} stopOpacity={0.8} />
              <stop offset="100%" stopColor={C.accent} stopOpacity={0.3} />
            </linearGradient>
          </defs>
          {/* Prediction line */}
          {dataPoints.length > 1 && (
            <path
              d={`M ${dataPoints.map((p) => `${p.x},${p.normalY - 350}`).join(" L ")}`}
              fill="none"
              stroke={C.accent}
              strokeWidth={2}
              strokeDasharray="8,4"
              opacity={0.5}
            />
          )}
        </svg>

        {/* ── Actual behaviour line ── */}
        <svg
          style={{ position: "absolute", top: 0, left: 0 }}
          width={1620}
          height={350}
        >
          <defs>
            <linearGradient id="actualGrad" x1="0%" y1="0%" x2="100%" y2="0%">
              <stop offset="0%" stopColor={C.green} />
              <stop offset="50%" stopColor={C.green} />
              <stop offset="70%" stopColor={C.amber} />
              <stop offset="100%" stopColor={C.red} />
            </linearGradient>
          </defs>
          {dataPoints.length > 1 && (
            <path
              d={`M ${dataPoints
                .filter((p) => p.opacity > 0)
                .map((p) => `${p.x},${p.actualY - 350}`)
                .join(" L ")}`}
              fill="none"
              stroke="url(#actualGrad)"
              strokeWidth={3}
              strokeLinecap="round"
            />
          )}
        </svg>

        {/* ── Data points ── */}
        {dataPoints.map((p, i) => {
          if (p.opacity <= 0) return null;
          const pointColor = p.isDiverged ? C.red : C.green;
          return (
            <React.Fragment key={i}>
              {/* Actual point */}
              <DataPoint
                x={p.x - 6}
                y={p.actualY - 356}
                color={pointColor}
                size={12}
                opacity={p.opacity}
              />
              {/* Divergence line */}
              {p.isDiverged && p.divergenceOpacity > 0 && (
                <svg
                  style={{ position: "absolute", top: 0, left: 0 }}
                  width={1620}
                  height={350}
                >
                  <line
                    x1={p.x}
                    y1={p.normalY - 350}
                    x2={p.x}
                    y2={p.actualY - 350}
                    stroke={C.red}
                    strokeWidth={1}
                    strokeDasharray="4,4"
                    opacity={p.divergenceOpacity * 0.6}
                  />
                </svg>
              )}
              {/* Divergence label */}
              {p.isDiverged && i === 15 && p.divergenceOpacity > 0 && (
                <div
                  style={{
                    position: "absolute",
                    left: p.x + 15,
                    top: (p.normalY + p.actualY) / 2 - 350 - 10,
                    fontSize: 12,
                    color: C.red,
                    fontWeight: 700,
                    opacity: p.divergenceOpacity,
                    whiteSpace: "nowrap",
                  }}
                >
                  ← Divergence
                </div>
              )}
            </React.Fragment>
          );
        })}

        {/* ── Graph label ── */}
        <div
          style={{
            position: "absolute",
            bottom: 15,
            left: 70,
            fontSize: 12,
            color: C.muted,
            display: "flex",
            gap: 20,
          }}
        >
          <span>
            <span style={{ color: C.accent }}>━━</span> Predicted (Doppelgänger)
          </span>
          <span>
            <span style={{ color: C.green }}>━━</span> Actual Behaviour
          </span>
          <span>
            <span style={{ color: C.red }}>╌╌</span> Divergence
          </span>
        </div>
      </div>

      {/* ── Alert banner (Phase 3) ── */}
      {showPhase3 && (
        <div
          style={{
            position: "absolute",
            bottom: 80,
            left: "50%",
            transform: "translateX(-50%)",
            backgroundColor: C.red + "20",
            border: `2px solid ${C.red}`,
            borderRadius: 12,
            padding: "16px 40px",
            display: "flex",
            alignItems: "center",
            gap: 16,
            opacity: alertPulse,
          }}
        >
          <div
            style={{
              width: 16,
              height: 16,
              borderRadius: "50%",
              backgroundColor: C.red,
              animation: "pulse 1s infinite",
            }}
          />
          <div>
            <div style={{ fontSize: 16, color: C.red, fontWeight: 700 }}>
              EARLY BUST-OUT DETECTED
            </div>
            <div style={{ fontSize: 12, color: C.muted }}>
              Salary deposits shifting · New credit accounts · Unusual e-wallet activity
            </div>
          </div>
        </div>
      )}

      {/* ── Resolution (Phase 4) ── */}
      {showPhase4 && (
        <div
          style={{
            position: "absolute",
            bottom: 80,
            left: "50%",
            transform: `translateX(-50%) scale(${checkScale})`,
            backgroundColor: C.green + "20",
            border: `2px solid ${C.green}`,
            borderRadius: 12,
            padding: "16px 40px",
            display: "flex",
            alignItems: "center",
            gap: 16,
          }}
        >
          <div
            style={{
              width: 32,
              height: 32,
              borderRadius: "50%",
              backgroundColor: C.green,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              fontSize: 18,
              color: C.text,
            }}
          >
            ✓
          </div>
          <div>
            <div style={{ fontSize: 16, color: C.green, fontWeight: 700 }}>
              LOSS PREVENTED
            </div>
            <div style={{ fontSize: 12, color: C.muted }}>
              Consolidation offer sent · Limit adjusted · Customer saved
            </div>
          </div>
        </div>
      )}

      {/* ── Bottom metrics ── */}
      <div
        style={{
          position: "absolute",
          bottom: 20,
          left: 60,
          right: 60,
          display: "flex",
          justifyContent: "space-between",
          alignItems: "center",
        }}
      >
        <div style={{ fontSize: 11, color: C.muted }}>
          AURA · Continuum Risk Labs · 2026
        </div>
        <div style={{ display: "flex", gap: 30 }}>
          {[
            { label: "Detection time", value: "< 30 sec", color: C.green },
            { label: "False positive", value: "< 2%", color: C.accent },
            { label: "Action taken", value: "Automatic", color: C.amber },
          ].map((m) => (
            <div key={m.label} style={{ textAlign: "right" }}>
              <div style={{ fontSize: 14, color: m.color, fontWeight: 700 }}>
                {m.value}
              </div>
              <div style={{ fontSize: 9, color: C.muted, letterSpacing: 1 }}>
                {m.label.toUpperCase()}
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* ── Pulse waves on avatar ── */}
      {showPhase2 && (
        <PulseWave frame={frame - phase1End} centerX={avatarX} centerY={avatarY} />
      )}
    </AbsoluteFill>
  );
};
