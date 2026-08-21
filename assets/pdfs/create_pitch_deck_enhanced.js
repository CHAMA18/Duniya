#!/usr/bin/env node
// ═══════════════════════════════════════════════════════════════
// AURA — Enhanced Pitch Deck with Illustrations
// ═══════════════════════════════════════════════════════════════
const pptxgen = require("pptxgenjs");
const pptx = new pptxgen();

// ── Brand ─────────────────────────────────────────────────────
const B = {
  primary: "4A0E8F", accent: "7C3AED", highlight: "A78BFA",
  dark: "0F0A1A", surface: "1A1330", surface2: "15102A",
  text: "F3F4F6", muted: "9CA3AF", white: "FFFFFF",
  green: "10B981", amber: "F59E0B", red: "EF4444",
  bg: "0B0614", border: "374151", borderLight: "2D2450",
};

pptx.author = "Continuum Risk Labs Pte. Ltd.";
pptx.title = "AURA Pitch Deck — Global Fintech Hackelerator 2026";
pptx.layout = "LAYOUT_WIDE";
const W = 13.33, H = 7.5;

// ── Helpers ───────────────────────────────────────────────────
function footer(s, n) {
  s.addText("AURA  ·  CONTINUUM RISK LABS", { x: .5, y: 7.05, w: 5, h: .25, fontSize: 8, color: B.muted, fontFace: "Arial" });
  s.addText(`${n} / 14`, { x: 11.5, y: 7.05, w: 1.5, h: .25, fontSize: 8, color: B.muted, fontFace: "Arial", align: "right" });
}
function section(s, txt) {
  s.addShape(pptx.shapes.RECTANGLE, { x: .5, y: .35, w: .06, h: .32, fill: { color: B.accent } });
  s.addText(txt, { x: .7, y: .35, w: 3, h: .32, fontSize: 9, color: B.highlight, fontFace: "Arial", bold: true, letterSpacing: 3 });
}
function card(s, x, y, w, h, opts = {}) {
  s.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
    x, y, w, h, rectRadius: opts.r || .12,
    fill: { color: opts.fill || B.surface },
    line: { color: opts.border || B.border, width: opts.bw || .75 },
  });
}
function circle(s, x, y, d, fill) {
  s.addShape(pptx.shapes.OVAL, { x, y, w: d, h: d, fill: { color: fill } });
}
function pill(s, x, y, txt, fill) {
  s.addShape(pptx.shapes.ROUNDED_RECTANGLE, { x, y, w: txt.length * .1 + .5, h: .28, rectRadius: .14, fill: { color: fill } });
  s.addText(txt, { x, y, w: txt.length * .1 + .5, h: .28, fontSize: 7, color: B.white, fontFace: "Arial", bold: true, align: "center", valign: "middle" });
}
function arrow(s, x1, y1, x2, y2, color) {
  s.addShape(pptx.shapes.LINE, { x: x1, y: y1, w: x2 - x1 || .001, h: y2 - y1 || .001, line: { color: color || B.accent, width: 1.5, endArrowType: "triangle" } });
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 1 — COVER
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide(); s.background = { fill: B.bg };
  s.addShape(pptx.shapes.RECTANGLE, { x: 0, y: 0, w: W, h: .04, fill: { color: B.accent } });

  // Decorative concentric circles (with transparency)
  s.addShape(pptx.shapes.OVAL, { x: 9.2, y: .3, w: 4, h: 4, fill: { color: B.primary, transparency: 90 } });
  s.addShape(pptx.shapes.OVAL, { x: 10, y: 1.1, w: 2.4, h: 2.4, fill: { color: B.accent, transparency: 85 } });
  s.addShape(pptx.shapes.OVAL, { x: 10.6, y: 1.7, w: 1.2, h: 1.2, fill: { color: B.highlight, transparency: 80 } });

  // Pulse wave illustration (decorative dots)
  for (let i = 0; i < 20; i++) {
    const px = 8 + i * .25;
    const py = 3.5 + Math.sin(i * .8) * .3;
    const sz = .08 + Math.abs(Math.sin(i * .6)) * .12;
    s.addShape(pptx.shapes.OVAL, { x: px, y: py, w: sz, h: sz, fill: { color: B.highlight, transparency: 50 + i * 2 } });
  }

  s.addText("AURA", { x: .8, y: .6, w: 4, h: .8, fontSize: 44, color: B.accent, fontFace: "Arial", bold: true, letterSpacing: 8 });
  s.addText("Adaptive Unified Risk Architecture", { x: .8, y: 1.35, w: 6, h: .4, fontSize: 16, color: B.highlight, fontFace: "Arial" });
  s.addText("One model of you.\nEvery risk you'll ever be.", { x: .8, y: 2.4, w: 7.5, h: 1.3, fontSize: 34, color: B.text, fontFace: "Arial", bold: true, lineSpacingMultiple: 1.2 });

  // KPI strip with icon circles
  const kpis = [
    { v: "20–30%", l: "CREDIT LOSS\nREDUCTION", c: B.green, icon: "📉" },
    { v: "40–50%", l: "FRAUD LOSS\nREDUCTION", c: B.accent, icon: "🛡" },
    { v: "~$50–80M", l: "ANNUAL P&L\nIMPACT", c: B.amber, icon: "💰" },
  ];
  kpis.forEach((k, i) => {
    const x = .8 + i * 3.2;
    card(s, x, 4.3, 2.8, 1.8, { fill: B.surface, border: B.borderLight });
    // Icon circle
    circle(s, x + .2, 4.5, .6, B.primary);
    s.addText(k.icon, { x: x + .2, y: 4.5, w: .6, h: .6, fontSize: 18, align: "center", valign: "middle" });
    s.addText(k.v, { x: x + .95, y: 4.45, w: 1.7, h: .45, fontSize: 20, color: k.c, fontFace: "Arial", bold: true });
    s.addText(k.l, { x: x + .95, y: 4.9, w: 1.7, h: .45, fontSize: 8, color: B.muted, fontFace: "Arial", letterSpacing: 1 });
    // Progress bar
    s.addShape(pptx.shapes.ROUNDED_RECTANGLE, { x: x + .2, y: 5.55, w: 2.4, h: .08, rectRadius: .04, fill: { color: B.border } });
    s.addShape(pptx.shapes.ROUNDED_RECTANGLE, { x: x + .2, y: 5.55, w: 2.4 * (i === 0 ? .25 : i === 1 ? .45 : .65), h: .08, rectRadius: .04, fill: { color: k.c } });
  });

  s.addText("SUBMISSION TO GXS BANK  ·  2026", { x: .8, y: 6.5, w: 5, h: .25, fontSize: 9, color: B.muted, fontFace: "Arial", letterSpacing: 2 });
  s.addText("Continuum Risk Labs Pte. Ltd.", { x: .8, y: 6.75, w: 5, h: .25, fontSize: 10, color: B.highlight, fontFace: "Arial" });
  footer(s, "01");
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 2 — THE PROBLEM (with visual)
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide(); s.background = { fill: B.bg };
  section(s, "01 · PROBLEM");
  s.addText("Silos that bleed.", { x: .8, y: .9, w: 8, h: .7, fontSize: 34, color: B.text, fontFace: "Arial", bold: true });
  s.addText("For 70 years, banking has treated credit risk and fraud risk as two distinct sciences.\nThe handoff points between them are precisely where losses compound today.", {
    x: .8, y: 1.65, w: 7, h: .8, fontSize: 12, color: B.muted, fontFace: "Arial", lineSpacingMultiple: 1.4
  });

  // ── Visual: Two teams diagram with gap ──
  // Credit team box
  card(s, .5, 2.7, 5.5, 3.0, { fill: B.surface, border: B.primary });
  pill(s, .8, 2.85, "CREDIT TEAM", B.primary);
  s.addText('"Can they repay?"', { x: .8, y: 3.2, w: 4.8, h: .35, fontSize: 15, color: B.text, fontFace: "Arial", italic: true });
  // Credit icons
  ["Static PD models · Quarterly refresh", "12-month horizon · Income / collateral", "Population-level statistics"].forEach((t, i) => {
    circle(s, .9, 3.7 + i * .42, .22, B.primary);
    s.addText(`${i + 1}`, { x: .9, y: 3.7 + i * .42, w: .22, h: .22, fontSize: 8, color: B.white, fontFace: "Arial", bold: true, align: "center", valign: "middle" });
    s.addText(t, { x: 1.25, y: 3.7 + i * .42, w: 4.4, h: .22, fontSize: 10, color: B.muted, fontFace: "Arial", valign: "middle" });
  });

  // Gap indicator
  s.addShape(pptx.shapes.RECTANGLE, { x: 6.25, y: 3.8, w: .7, h: .06, fill: { color: B.red } });
  s.addShape(pptx.shapes.RECTANGLE, { x: 6.25, y: 4.2, w: .7, h: .06, fill: { color: B.red } });
  s.addText("⚡\nGAP", { x: 6.2, y: 3.3, w: .8, h: .45, fontSize: 10, color: B.red, fontFace: "Arial", bold: true, align: "center" });

  // Fraud team box
  card(s, 7.2, 2.7, 5.5, 3.0, { fill: B.surface, border: B.red });
  pill(s, 7.5, 2.85, "FRAUD TEAM", B.red);
  s.addText('"Will they repay?"', { x: 7.5, y: 3.2, w: 4.8, h: .35, fontSize: 15, color: B.text, fontFace: "Arial", italic: true });
  ["Real-time ML · Millisecond refresh", "Next-tx horizon · Device / network", "Behavioral anomaly detection"].forEach((t, i) => {
    circle(s, 7.6, 3.7 + i * .42, .22, B.red);
    s.addText(`${i + 1}`, { x: 7.6, y: 3.7 + i * .42, w: .22, h: .22, fontSize: 8, color: B.white, fontFace: "Arial", bold: true, align: "center", valign: "middle" });
    s.addText(t, { x: 7.95, y: 3.7 + i * .42, w: 4.4, h: .22, fontSize: 10, color: B.muted, fontFace: "Arial", valign: "middle" });
  });

  // Bottom stat bar
  card(s, 2.5, 6.0, 8.3, .6, { fill: B.surface, border: B.red, bw: 1 });
  s.addText("⚡  ~$487B  global annual fraud + credit losses at the seams — and growing", {
    x: 2.5, y: 6.0, w: 8.3, h: .6, fontSize: 12, color: B.red, fontFace: "Arial", bold: true, align: "center", valign: "middle"
  });

  footer(s, "02");
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 3 — THE INSIGHT (with visual comparison)
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide(); s.background = { fill: B.bg };
  section(s, "02 · INSIGHT");
  s.addText("They were never separate.", { x: .8, y: .9, w: 10, h: .7, fontSize: 34, color: B.text, fontFace: "Arial", bold: true });
  s.addText(
    "Credit default and fraud are the same phenomenon — the divergence between the customer you\nunderwrote and the customer revealed by their behaviour — observed at different time horizons.", {
    x: .8, y: 1.7, w: 10, h: .8, fontSize: 12, color: B.muted, fontFace: "Arial", lineSpacingMultiple: 1.4
  });

  // ── Visual: Time telescope diagram ──
  // Horizontal timeline
  s.addShape(pptx.shapes.RECTANGLE, { x: 1, y: 2.8, w: 11, h: .04, fill: { color: B.border } });
  // Time markers
  const times = ["t=0\nApplication", "t=30d\nFirst Tx", "t=180d\nBehaviour Shift", "t=365d\nDefault"];
  times.forEach((t, i) => {
    const x = 1 + i * 3;
    circle(s, x + .4, 2.65, .35, B.accent);
    s.addText(`${i}`, { x: x + .4, y: 2.65, w: .35, h: .35, fontSize: 10, color: B.white, fontFace: "Arial", bold: true, align: "center", valign: "middle" });
    s.addText(t, { x: x, y: 3.1, w: 1.2, h: .5, fontSize: 8, color: B.muted, fontFace: "Arial", align: "center" });
  });
  // Fraud telescope bracket
  s.addShape(pptx.shapes.ROUNDED_RECTANGLE, { x: .8, y: 3.7, w: 2.5, h: .3, rectRadius: .15, fill: { color: B.red, transparency: 70 } });
  s.addText("FRAUD TELESCOPE", { x: .8, y: 3.7, w: 2.5, h: .3, fontSize: 7, color: B.red, fontFace: "Arial", bold: true, align: "center", valign: "middle", letterSpacing: 1 });
  // Credit telescope bracket
  s.addShape(pptx.shapes.ROUNDED_RECTANGLE, { x: 4.2, y: 3.7, w: 5, h: .3, rectRadius: .15, fill: { color: B.primary, transparency: 70 } });
  s.addText("CREDIT TELESCOPE", { x: 4.2, y: 3.7, w: 5, h: .3, fontSize: 7, color: B.highlight, fontFace: "Arial", bold: true, align: "center", valign: "middle", letterSpacing: 1 });
  // AURA bracket (full)
  s.addShape(pptx.shapes.ROUNDED_RECTANGLE, { x: .8, y: 4.15, w: 11.5, h: .3, rectRadius: .15, fill: { color: B.green, transparency: 70 } });
  s.addText("✦  AURA — BOTH TELESCOPES, ONE MODEL", { x: .8, y: 4.15, w: 11.5, h: .3, fontSize: 8, color: B.green, fontFace: "Arial", bold: true, align: "center", valign: "middle", letterSpacing: 1 });

  // Reframe table
  const hdr = [{ text: "TODAY'S LABEL", options: { bold: true, color: B.white, fill: { color: B.primary }, fontSize: 9, letterSpacing: 1 } },
    { text: "WHAT IT ACTUALLY IS", options: { bold: true, color: B.white, fill: { color: B.primary }, fontSize: 9, letterSpacing: 1 } }];
  const rows = [
    ["Credit default", "A fraud that took 18 months to reveal itself"],
    ["Bust-out fraud", "A credit default compressed into 30 days"],
    ["Application fraud", "A credit model that was lied to at t=0"],
    ["Transaction fraud", "A creditworthiness event in 30 seconds"],
    ["Strategic default", "A credit customer who became first-party fraud"],
  ].map((r, i) => r.map(c => ({ text: c, options: { fontSize: 11, color: B.text, fill: { color: i % 2 === 0 ? B.surface2 : B.surface } } })));
  s.addTable([hdr, ...rows], { x: .8, y: 4.7, w: 11.7, colW: [3, 8.7], rowH: [.4, .38, .38, .38, .38, .38], border: { type: "solid", pt: .5, color: B.border } });

  footer(s, "03");
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 4 — SOLUTION (with pillar illustrations)
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide(); s.background = { fill: B.bg };
  section(s, "03 · SOLUTION");
  s.addText("One model. Two telescopes.\nA living immune system.", { x: .8, y: .9, w: 10, h: .9, fontSize: 30, color: B.text, fontFace: "Arial", bold: true, lineSpacingMultiple: 1.2 });

  // ── Visual: Architecture diagram ──
  // Central embedding circle
  circle(s, 5.5, 2.5, 2.3, B.primary);
  s.addText("256-dim\nRisk\nEmbedding", { x: 5.5, y: 2.5, w: 2.3, h: 2.3, fontSize: 12, color: B.white, fontFace: "Arial", bold: true, align: "center", valign: "middle" });

  // Four satellite pillars
  const pillars = [
    { title: "DOPPEL-\nGÄNGER", desc: "Generative twin\nstreams residuals", x: 1.2, y: 2.6, c: B.accent, icon: "👤" },
    { title: "TWIN\nSTRANDS", desc: "Capacity × Intent\nreadouts", x: 9.5, y: 2.6, c: B.highlight, icon: "🧬" },
    { title: "TIME\nTELESCOPES", desc: "sec / days /\nmonths", x: 1.2, y: 4.8, c: B.amber, icon: "🔭" },
    { title: "ARENA", desc: "Adversarial\nagents attack 24/7", x: 9.5, y: 4.8, c: B.red, icon: "⚔️" },
  ];
  pillars.forEach(p => {
    card(s, p.x, p.y, 2.8, 1.6, { fill: B.surface, border: p.c });
    circle(s, p.x + .15, p.y + .15, .5, p.c);
    s.addText(p.icon, { x: p.x + .15, y: p.y + .15, w: .5, h: .5, fontSize: 16, align: "center", valign: "middle" });
    s.addText(p.title, { x: p.x + .75, y: p.y + .1, w: 1.9, h: .65, fontSize: 11, color: B.text, fontFace: "Arial", bold: true, lineSpacingMultiple: 1.1 });
    s.addText(p.desc, { x: p.x + .15, y: p.y + .85, w: 2.5, h: .6, fontSize: 9, color: B.muted, fontFace: "Arial", lineSpacingMultiple: 1.3 });
    // Connection line to center
    const cx = p.x < 5 ? p.x + 2.8 : p.x;
    const cy = p.y + .8;
    s.addShape(pptx.shapes.LINE, { x: cx, y: cy, w: 5.5 - cx + 1.15, h: 3.65 - cy, line: { color: p.c, width: 1, dashType: "dash" } });
  });

  // Bottom label
  card(s, 3.5, 6.5, 6.3, .45, { fill: "0F1A0F", border: B.green, bw: 1 });
  s.addText("Layers 1–5 = Spine  ·  Layers 6–8 = Immune System", {
    x: 3.5, y: 6.5, w: 6.3, h: .45, fontSize: 10, color: B.green, fontFace: "Arial", bold: true, align: "center", valign: "middle"
  });

  footer(s, "04");
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 5 — ARCHITECTURE (layer stack visualization)
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide(); s.background = { fill: B.bg };
  section(s, "04 · ARCHITECTURE");
  s.addText("Eight tightly-coupled layers.", { x: .8, y: .9, w: 8, h: .6, fontSize: 30, color: B.text, fontFace: "Arial", bold: true });

  const layers = [
    { n: "1", name: "Unified Risk Embedding", desc: "256-dim global latent space", tag: "SPINE", c: B.highlight },
    { n: "2", name: "Personal Doppelgänger", desc: "Per-customer generative twin · residual streamer", tag: "SPINE", c: B.highlight },
    { n: "3", name: "Twin Strands", desc: "Two decoupled readouts: Capacity × Intent", tag: "SPINE", c: B.highlight },
    { n: "4", name: "Time-Telescope Heads", desc: "spike (sec) / shift (days) / drift (months)", tag: "SPINE", c: B.highlight },
    { n: "5", name: "Counterfactual Replay", desc: "Doubly-robust causal estimation on decisions", tag: "SPINE", c: B.highlight },
    { n: "6", name: "The Arena", desc: "Adversarial agents attack live system in shadow", tag: "IMMUNE", c: B.accent },
    { n: "7", name: "Risk Field", desc: "Graph contagion across devices, merchants, geographies", tag: "IMMUNE", c: B.accent },
    { n: "8", name: "Action Layer", desc: "nudge → friction → reprice → interdict", tag: "IMMUNE", c: B.accent },
  ];

  // Left side: stacked layers visualization
  layers.forEach((l, i) => {
    const y = 1.65 + i * .6;
    const isImmune = l.tag === "IMMUNE";
    card(s, .5, y, 7.5, .52, { fill: isImmune ? "1C0F2E" : B.surface2, border: isImmune ? B.accent : B.primary, r: .06 });
    circle(s, .65, y + .06, .4, l.c);
    s.addText(l.n, { x: .65, y: y + .06, w: .4, h: .4, fontSize: 11, color: B.white, fontFace: "Arial", bold: true, align: "center", valign: "middle" });
    s.addText(l.name, { x: 1.2, y, w: 3.2, h: .52, fontSize: 11, color: B.text, fontFace: "Arial", bold: true, valign: "middle" });
    s.addText(l.desc, { x: 4.5, y, w: 3, h: .52, fontSize: 9, color: B.muted, fontFace: "Arial", valign: "middle" });
    pill(s, 7.15, y + .12, l.tag, isImmune ? B.accent : B.primary);
  });

  // Right side: Visual layer stack
  card(s, 8.5, 1.65, 4.3, 5.1, { fill: B.surface, border: B.accent });
  s.addText("SYSTEM\nVIEW", { x: 8.5, y: 1.7, w: 4.3, h: .4, fontSize: 9, color: B.highlight, fontFace: "Arial", bold: true, align: "center", letterSpacing: 2 });

  // Stacked blocks
  layers.forEach((l, i) => {
    const y = 2.2 + i * .55;
    const w = 3.8 - i * .15;
    s.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
      x: 8.75 + i * .075, y, w, h: .4, rectRadius: .06,
      fill: { color: l.c, transparency: 40 + i * 5 },
      line: { color: l.c, width: .5 }
    });
  });

  // Legend
  s.addText("Risk Continuum Spine", { x: 8.5, y: 6.4, w: 2, h: .25, fontSize: 8, color: B.highlight, fontFace: "Arial" });
  s.addText("Adaptive Immune System", { x: 10.8, y: 6.4, w: 2, h: .25, fontSize: 8, color: B.accent, fontFace: "Arial" });

  footer(s, "05");
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 6 — BREAKTHROUGH (visual comparison)
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide(); s.background = { fill: B.bg };
  section(s, "05 · BREAKTHROUGH");
  s.addText("Doppelgänger + Arena", { x: .8, y: .9, w: 10, h: .6, fontSize: 30, color: B.text, fontFace: "Arial", bold: true });

  // Left card
  card(s, .5, 1.7, 6, 5.0, { fill: B.surface, border: B.accent });
  pill(s, .8, 1.85, "LAYER 02", B.accent);
  s.addText("Personal Doppelgänger", { x: .8, y: 2.2, w: 5.4, h: .4, fontSize: 18, color: B.text, fontFace: "Arial", bold: true });
  s.addText(
    "A self-supervised generative twin per customer. Continuously predicts their next state and streams the residuals — where reality diverges from expectation.", {
    x: .8, y: 2.7, w: 5.4, h: .7, fontSize: 11, color: B.muted, fontFace: "Arial", lineSpacingMultiple: 1.3
  });
  s.addShape(pptx.shapes.RECTANGLE, { x: .8, y: 3.5, w: 5.4, h: .02, fill: { color: B.accent } });

  // Visual: Residual stream diagram
  card(s, .8, 3.7, 5.4, 2.0, { fill: B.surface2, border: B.border, r: .08 });
  s.addText("RESIDUAL STREAM", { x: 1, y: 3.8, w: 3, h: .25, fontSize: 8, color: B.highlight, fontFace: "Arial", bold: true, letterSpacing: 1 });
  // Prediction line
  for (let i = 0; i < 12; i++) {
    const x = 1.1 + i * .42;
    const y1 = 4.4 + Math.sin(i * .5) * .3;
    const sz = .1;
    circle(s, x, y1, sz, B.accent);
    if (i > 0) {
      const px = 1.1 + (i - 1) * .42;
      const py = 4.4 + Math.sin((i - 1) * .5) * .3;
      s.addShape(pptx.shapes.LINE, { x: px + sz / 2, y: py + sz / 2, w: x - px, h: y1 - py, line: { color: B.accent, width: 1 } });
    }
  }
  // Reality divergence (red dots after midpoint)
  for (let i = 6; i < 12; i++) {
    const x = 1.1 + i * .42;
    const y2 = 4.4 + Math.sin(i * .5) * .3 + .5; // Deviation
    circle(s, x, y2, .08, B.red);
  }
  s.addText("Expected", { x: 1, y: 5.1, w: 1.5, h: .2, fontSize: 7, color: B.accent, fontFace: "Arial" });
  s.addText("Reality", { x: 1, y: 5.3, w: 1.5, h: .2, fontSize: 7, color: B.red, fontFace: "Arial" });
  s.addText("← divergence = alert", { x: 2.5, y: 5.2, w: 3, h: .2, fontSize: 7, color: B.muted, fontFace: "Arial" });

  s.addText("TRAINING DATA:", { x: .8, y: 5.85, w: 5.4, h: .25, fontSize: 9, color: B.highlight, fontFace: "Arial", bold: true });
  s.addText("The 99% of behavioural signal both silos throw away.", { x: .8, y: 6.1, w: 5.4, h: .25, fontSize: 10, color: B.text, fontFace: "Arial", italic: true });

  // Right card
  card(s, 6.8, 1.7, 6, 5.0, { fill: B.surface, border: B.red });
  pill(s, 7.1, 1.85, "LAYER 06", B.red);
  s.addText("The Arena", { x: 7.1, y: 2.2, w: 5.4, h: .4, fontSize: 18, color: B.text, fontFace: "Arial", bold: true });
  s.addText(
    "Continuously running adversarial agents attack the live system in a shadow environment. Every exploit becomes instant training signal.", {
    x: 7.1, y: 2.7, w: 5.4, h: .6, fontSize: 11, color: B.muted, fontFace: "Arial", lineSpacingMultiple: 1.3
  });
  s.addShape(pptx.shapes.RECTANGLE, { x: 7.1, y: 3.4, w: 5.4, h: .02, fill: { color: B.red } });

  // Visual: Attack vectors
  card(s, 7.1, 3.6, 5.4, 2.1, { fill: B.surface2, border: B.border, r: .08 });
  s.addText("ADVERSARIAL ATTACKS", { x: 7.3, y: 3.7, w: 3, h: .25, fontSize: 8, color: B.red, fontFace: "Arial", bold: true, letterSpacing: 1 });

  const attacks = [
    { name: "Deepfake\nApplicants", x: 7.5, c: B.red },
    { name: "Synthetic\nRings", x: 8.8, c: B.amber },
    { name: "AI Bust-out\nPersonas", x: 10.1, c: B.red },
    { name: "Behavior\nMimicry", x: 11.4, c: B.amber },
  ];
  attacks.forEach((a, i) => {
    circle(s, a.x, 4.1, .5, a.c);
    s.addText(a.name, { x: a.x, y: 4.1, w: .5, h: .5, fontSize: 6, color: B.white, fontFace: "Arial", bold: true, align: "center", valign: "middle" });
    // Arrow down to system
    s.addShape(pptx.shapes.LINE, { x: a.x + .25, y: 4.65, w: 0, h: .3, line: { color: a.c, width: 1, endArrowType: "triangle" } });
  });
  // Target
  card(s, 8.2, 5.1, 3.8, .4, { fill: B.green, border: B.green, r: .2 });
  s.addText("🛡  LIVE SYSTEM (SHADOW)", { x: 8.2, y: 5.1, w: 3.8, h: .4, fontSize: 9, color: B.white, fontFace: "Arial", bold: true, align: "center", valign: "middle" });

  s.addText("WHY NOW:", { x: 7.1, y: 5.85, w: 5.4, h: .25, fontSize: 9, color: B.red, fontFace: "Arial", bold: true });
  s.addText("Fraudsters now use generative AI. You cannot fight generative with static.", { x: 7.1, y: 6.1, w: 5.4, h: .25, fontSize: 10, color: B.text, fontFace: "Arial", italic: true });

  footer(s, "06");
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 7 — WHY NOW (market forces)
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide(); s.background = { fill: B.bg };
  section(s, "06 · WHY NOW");
  s.addText("Three forces converge in 2026.", { x: .8, y: .9, w: 10, h: .6, fontSize: 30, color: B.text, fontFace: "Arial", bold: true });

  const forces = [
    { n: "01", title: "Causal ML tooling", desc: "EconML, DoWhy, doubly-robust estimators make counterfactual training operationalisable at production scale.", c: B.accent, icon: "🧠" },
    { n: "02", title: "Vector DBs + sequence models", desc: "256-dim real-time updates and millions of live generative twins are now computationally feasible.", c: B.highlight, icon: "⚡" },
    { n: "03", title: "Regulator openness", desc: "MAS, EBA, OCC signal acceptance of continuously-learning models, provided a frozen shadow is maintained for audit.", c: B.green, icon: "📋" },
  ];
  forces.forEach((f, i) => {
    const x = .5 + i * 4.2;
    card(s, x, 1.7, 3.9, 2.8, { fill: B.surface, border: f.c });
    circle(s, x + .2, 1.85, .65, f.c);
    s.addText(f.icon, { x: x + .2, y: 1.85, w: .65, h: .65, fontSize: 20, align: "center", valign: "middle" });
    s.addText(f.title, { x: x + .2, y: 2.6, w: 3.5, h: .35, fontSize: 14, color: B.text, fontFace: "Arial", bold: true });
    s.addText(f.desc, { x: x + .2, y: 3.0, w: 3.5, h: 1.2, fontSize: 10, color: B.muted, fontFace: "Arial", lineSpacingMultiple: 1.4 });
  });

  // Market metrics with bar chart visualization
  const metrics = [
    { v: "$12B", l: "TAM · SOFTWARE SPEND", sub: "Growing 14% YoY", pct: .6, c: B.highlight },
    { v: "$487B", l: "ANNUAL FRAUD LOSSES", sub: "Global FS", pct: .9, c: B.red },
    { v: "$84T", l: "WEALTH TRANSFER", sub: "By 2045", pct: 1, c: B.amber },
    { v: "10×", l: "FASTER DEPLOYMENT", sub: "vs siloed MRM", pct: .75, c: B.green },
  ];
  metrics.forEach((m, i) => {
    const x = .5 + i * 3.15;
    card(s, x, 4.8, 2.9, 1.9, { fill: B.surface, border: B.border });
    s.addText(m.v, { x, y: 4.9, w: 2.9, h: .5, fontSize: 22, color: m.c, fontFace: "Arial", bold: true, align: "center" });
    s.addText(m.l, { x, y: 5.35, w: 2.9, h: .35, fontSize: 8, color: B.text, fontFace: "Arial", bold: true, align: "center", letterSpacing: 1 });
    s.addText(m.sub, { x, y: 5.65, w: 2.9, h: .25, fontSize: 8, color: B.muted, fontFace: "Arial", align: "center" });
    // Bar
    s.addShape(pptx.shapes.ROUNDED_RECTANGLE, { x: x + .2, y: 6.1, w: 2.5, h: .15, rectRadius: .075, fill: { color: B.border } });
    s.addShape(pptx.shapes.ROUNDED_RECTANGLE, { x: x + .2, y: 6.1, w: 2.5 * m.pct, h: .15, rectRadius: .075, fill: { color: m.c } });
  });

  footer(s, "07");
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 8 — SEE IT WORK (scenario illustrations)
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide(); s.background = { fill: B.bg };
  section(s, "07 · SEE IT WORK");
  s.addText("Two scenarios, one engine.", { x: .8, y: .9, w: 10, h: .6, fontSize: 30, color: B.text, fontFace: "Arial", bold: true });

  // Scenario 1: Mei
  card(s, .5, 1.7, 6, 4.6, { fill: B.surface, border: B.amber });
  pill(s, .8, 1.85, "SCENARIO 01", B.amber);
  s.addText("Mei, 34 — Real Person, Real Documents", { x: .8, y: 2.2, w: 5.4, h: .35, fontSize: 14, color: B.text, fontFace: "Arial", bold: true });

  // Visual: Behavioural timeline
  card(s, .8, 2.65, 5.4, 1.5, { fill: B.surface2, border: B.border, r: .08 });
  s.addText("BEHAVIOURAL SHIFT TIMELINE", { x: 1, y: 2.72, w: 4, h: .2, fontSize: 7, color: B.highlight, fontFace: "Arial", bold: true, letterSpacing: 1 });
  // Timeline items
  const meiEvents = [
    { label: "Salary\nlater", x: 1.2, c: B.amber },
    { label: "3 new\ncredit accts", x: 2.2, c: B.red },
    { label: "E-wallet\ntop-ups", x: 3.2, c: B.amber },
    { label: "2AM\nsessions", x: 4.2, c: B.red },
    { label: "2nd\ndevice", x: 5.2, c: B.red },
  ];
  meiEvents.forEach((e, i) => {
    circle(s, e.x, 3.1, .3, e.c);
    s.addText(e.label, { x: e.x, y: 3.1, w: .3, h: .3, fontSize: 5, color: B.white, fontFace: "Arial", bold: true, align: "center", valign: "middle" });
    if (i > 0) s.addShape(pptx.shapes.LINE, { x: meiEvents[i - 1].x + .3, y: 3.25, w: e.x - meiEvents[i - 1].x - .3, h: 0, line: { color: B.border, width: 1 } });
  });
  s.addText("← Normal behaviour", { x: 1, y: 3.5, w: 2, h: .15, fontSize: 6, color: B.muted, fontFace: "Arial" });
  s.addText("Divergence detected →", { x: 3.5, y: 3.5, w: 2.5, h: .15, fontSize: 6, color: B.red, fontFace: "Arial" });

  // Old vs AURA comparison
  card(s, .8, 4.3, 5.4, .65, { fill: "1C1C1C", border: B.border, r: .06 });
  s.addText('OLD: Fraud model says "legitimate". Credit score unchanged.', { x: 1, y: 4.3, w: 5, h: .65, fontSize: 9, color: B.muted, fontFace: "Arial", italic: true, valign: "middle" });
  card(s, .8, 5.1, 5.4, .9, { fill: "0F1A0F", border: B.green, r: .06 });
  s.addText("AURA: Bust-out transition detected.\n→ Consolidation offer + limit adjustment.\n✓ Loss prevented, customer saved.", { x: 1, y: 5.1, w: 5, h: .9, fontSize: 9, color: B.green, fontFace: "Arial", valign: "middle" });

  // Scenario 2: Synthetic Ring
  card(s, 6.8, 1.7, 6, 4.6, { fill: B.surface, border: B.red });
  pill(s, 7.1, 1.85, "SCENARIO 02", B.red);
  s.addText("Synthetic Identity Ring — 200 Deepfakes", { x: 7.1, y: 2.2, w: 5.4, h: .35, fontSize: 14, color: B.text, fontFace: "Arial", bold: true });

  // Visual: Cluster detection
  card(s, 7.1, 2.65, 5.4, 1.5, { fill: B.surface2, border: B.border, r: .08 });
  s.addText("RISK FIELD — CLUSTER DETECTION", { x: 7.3, y: 2.72, w: 4, h: .2, fontSize: 7, color: B.red, fontFace: "Arial", bold: true, letterSpacing: 1 });
  // Show cluster of dots
  for (let i = 0; i < 15; i++) {
    const x = 8 + Math.random() * 3.5;
    const y = 3.0 + Math.random() * .7;
    circle(s, x, y, .12, B.red);
  }
  // One outlier
  circle(s, 11.5, 3.6, .15, B.green);
  s.addText("200 applicants\n→ 1 residual\nsignature", { x: 7.3, y: 3.5, w: 2, h: .4, fontSize: 7, color: B.muted, fontFace: "Arial", lineSpacingMultiple: 1.2 });
  s.addText("Cluster = ring", { x: 10, y: 3.5, w: 1.5, h: .2, fontSize: 7, color: B.red, fontFace: "Arial", bold: true });

  card(s, 7.1, 4.3, 5.4, .65, { fill: "1C0F0F", border: B.red, r: .06 });
  s.addText("RISK FIELD: Lights up as a cluster diverging from reality.", { x: 7.3, y: 4.3, w: 5, h: .65, fontSize: 9, color: B.red, fontFace: "Arial", valign: "middle" });
  card(s, 7.1, 5.1, 5.4, .9, { fill: "0F1A0F", border: B.green, r: .06 });
  s.addText("OUTCOME: Ring killed at application\n— not at first missed payment.\n✓ Zero losses from 200 fraudulent accounts.", { x: 7.3, y: 5.1, w: 5, h: .9, fontSize: 9, color: B.green, fontFace: "Arial", valign: "middle" });

  // GXS-specific callout
  card(s, .5, 6.45, 12.3, .55, { fill: "0F1A2E", border: B.accent, bw: 1 });
  s.addText("WHY GXS:  Thin-file customers · No credit history · Behaviour is the only signal · AURA is behaviour-first · GXS's data exhaust is the fuel", {
    x: .8, y: 6.45, w: 11.7, h: .55, fontSize: 10, color: B.highlight, fontFace: "Arial", bold: true, valign: "middle"
  });

  footer(s, "08");
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 9 — BUSINESS MODEL
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide(); s.background = { fill: B.bg };
  section(s, "08 · BUSINESS MODEL");
  s.addText("Aligned economics.", { x: .8, y: .9, w: 10, h: .6, fontSize: 30, color: B.text, fontFace: "Arial", bold: true });
  s.addText("We earn meaningfully only when GXS Bank's losses demonstrably fall.", {
    x: .8, y: 1.55, w: 10, h: .35, fontSize: 13, color: B.muted, fontFace: "Arial"
  });

  const tiers = [
    { name: "SHADOW PILOT", price: "Zero cost", sub: "90 days", rec: true, features: ["Single product line", "Divergence baseline", "No production decisions", "Proof before commitment"], c: B.green },
    { name: "BASE LICENSE", price: "Annual", sub: "Tiered by volume", features: ["Platform access", "Embedding + horizon heads", "Regulatory shadow", "Standard MRM support"], c: B.accent },
    { name: "PERFORMANCE", price: "% of verified", sub: "loss reduction", features: ["Indexed to baseline", "Audited quarterly", "Aligns P&L with yours", "Capped at 3× base fee"], c: B.amber },
  ];
  tiers.forEach((t, i) => {
    const x = .5 + i * 4.2;
    card(s, x, 2.2, 3.9, 4.3, { fill: t.rec ? "0A1F1A" : B.surface, border: t.c, bw: t.rec ? 1.5 : .75 });
    if (t.rec) pill(s, x + 1.2, 2.05, "RECOMMENDED", B.green);
    s.addText(t.name, { x: x + .3, y: 2.5, w: 3.3, h: .3, fontSize: 12, color: t.c, fontFace: "Arial", bold: true, letterSpacing: 2 });
    s.addText(t.price, { x: x + .3, y: 2.85, w: 3.3, h: .35, fontSize: 18, color: B.text, fontFace: "Arial", bold: true });
    s.addText(t.sub, { x: x + .3, y: 3.2, w: 3.3, h: .2, fontSize: 10, color: B.muted, fontFace: "Arial" });
    s.addShape(pptx.shapes.RECTANGLE, { x: x + .3, y: 3.55, w: 3.3, h: .01, fill: { color: B.border } });
    t.features.forEach((f, j) => {
      circle(s, x + .3, 3.7 + j * .4, .18, t.c);
      s.addText(`${j + 1}`, { x: x + .3, y: 3.7 + j * .4, w: .18, h: .18, fontSize: 7, color: B.white, fontFace: "Arial", bold: true, align: "center", valign: "middle" });
      s.addText(f, { x: x + .6, y: 3.65 + j * .4, w: 3, h: .3, fontSize: 10, color: B.muted, fontFace: "Arial", valign: "middle" });
    });
  });

  footer(s, "09");
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 10 — PROJECTED IMPACT
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide(); s.background = { fill: B.bg };
  section(s, "09 · IMPACT");
  s.addText("Projected impact.", { x: .8, y: .9, w: 10, h: .6, fontSize: 30, color: B.text, fontFace: "Arial", bold: true });
  s.addText("Three-year P&L impact  ·  Mid-sized bank  ·  US$50B portfolio  ·  Treated segments only", {
    x: .8, y: 1.55, w: 10, h: .3, fontSize: 10, color: B.muted, fontFace: "Arial"
  });

  // Table
  const hdr = ["", "Year 1", "Year 2", "Year 3"].map((t, i) => ({
    text: t, options: { bold: true, color: B.white, fill: { color: B.primary }, align: i === 0 ? "left" : "center", fontSize: 9, letterSpacing: 1 }
  }));
  const data = [
    ["Credit loss reduction", "10%", "17%", "25%", B.green],
    ["Fraud loss reduction", "22%", "35%", "45%", B.accent],
    ["False-positive reduction", "6%", "12%", "20%", B.highlight],
    ["P&L impact (US$M)", "$20M", "$45M", "$65M", B.amber],
  ];
  const rows = data.map(r => [
    { text: r[0], options: { bold: true, color: B.text, fontSize: 11 } },
    ...[r[1], r[2], r[3]].map((v, i) => ({
      text: v, options: { color: r[4], align: "center", fontSize: 12, bold: i === 2 }
    })),
  ]);
  s.addTable([hdr, ...rows], { x: .5, y: 2.1, w: 12.3, colW: [4, 2.77, 2.77, 2.77], rowH: [.45, .5, .5, .5, .5], border: { type: "solid", pt: .5, color: B.border } });

  // Visual: Bar chart
  card(s, .5, 4.4, 12.3, 2.5, { fill: B.surface, border: B.border, r: .1 });
  s.addText("P&L IMPACT GROWTH", { x: .8, y: 4.5, w: 4, h: .3, fontSize: 9, color: B.highlight, fontFace: "Arial", bold: true, letterSpacing: 1 });
  // Y axis
  s.addText("$80M", { x: .7, y: 4.8, w: .6, h: .2, fontSize: 8, color: B.muted, fontFace: "Arial", align: "right" });
  s.addText("$40M", { x: .7, y: 5.5, w: .6, h: .2, fontSize: 8, color: B.muted, fontFace: "Arial", align: "right" });
  s.addText("$0", { x: .7, y: 6.2, w: .6, h: .2, fontSize: 8, color: B.muted, fontFace: "Arial", align: "right" });
  // Grid lines
  [4.95, 5.65, 6.35].forEach(y => s.addShape(pptx.shapes.RECTANGLE, { x: 1.4, y, w: 11, h: .005, fill: { color: B.border } }));

  // Bars
  const barData = [
    { y1: .6, y2: .45, y3: .65, label: "Credit Loss ↓", c: B.green },
    { y1: .85, y2: 1.2, y3: 1.5, label: "Fraud Loss ↓", c: B.accent },
    { y1: .2, y2: .4, y3: .65, label: "FP Reduction", c: B.highlight },
  ];
  barData.forEach((b, i) => {
    const x = 2 + i * 3.8;
    s.addText(b.label, { x, y: 6.5, w: 3.5, h: .2, fontSize: 8, color: B.muted, fontFace: "Arial" });
    // Y1 bar
    s.addShape(pptx.shapes.ROUNDED_RECTANGLE, { x, y: 6.35 - b.y1, w: .8, h: b.y1, rectRadius: .04, fill: { color: b.c, transparency: 50 } });
    // Y2 bar
    s.addShape(pptx.shapes.ROUNDED_RECTANGLE, { x: x + 1, y: 6.35 - b.y2, w: .8, h: b.y2, rectRadius: .04, fill: { color: b.c, transparency: 30 } });
    // Y3 bar
    s.addShape(pptx.shapes.ROUNDED_RECTANGLE, { x: x + 2, y: 6.35 - b.y3, w: .8, h: b.y3, rectRadius: .04, fill: { color: b.c } });
  });
  // Year labels
  ["Y1", "Y2", "Y3"].forEach((y, i) => {
    s.addText(y, { x: 2 + i * 3.8, y: 4.9, w: 2.6, h: .15, fontSize: 7, color: B.muted, fontFace: "Arial", align: "center" });
  });

  footer(s, "10");
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 11 — ROADMAP (timeline visual)
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide(); s.background = { fill: B.bg };
  section(s, "10 · ROADMAP");
  s.addText("36 months. 4 phases. 1 gate per phase.", { x: .8, y: .9, w: 10, h: .6, fontSize: 28, color: B.text, fontFace: "Arial", bold: true });

  // Timeline
  s.addShape(pptx.shapes.RECTANGLE, { x: .5, y: 2.6, w: 12.3, h: .04, fill: { color: B.primary } });

  const phases = [
    { n: "01", title: "Shadow", time: "0–6 mo", desc: "Build embedding + doppelgängers. Run as shadow. Measure divergence.", gate: "Divergence baseline", c: B.highlight },
    { n: "02", title: "Time Telescopes", time: "6–12 mo", desc: "Deploy horizon heads. Live decisions on low-risk segments.", gate: "FP reduction ≥ 5%", c: B.accent },
    { n: "03", title: "Loop + Arena", time: "12–24 mo", desc: "Counterfactual replay + Arena live. Train on adversarial exploits.", gate: "Credit loss ↓ ≥ 10%", c: B.amber },
    { n: "04", title: "Genome + Action", time: "24–36 mo", desc: "Risk Field + Action Layer live. Graph-explainable migration.", gate: "Full deployment", c: B.green },
  ];

  phases.forEach((p, i) => {
    const x = .5 + i * 3.15;
    // Timeline dot
    circle(s, x + 1.2, 2.45, .35, p.c);
    s.addText(p.n, { x: x + 1.2, y: 2.45, w: .35, h: .35, fontSize: 10, color: B.white, fontFace: "Arial", bold: true, align: "center", valign: "middle" });
    // Card
    card(s, x, 3.0, 2.95, 3.5, { fill: B.surface, border: p.c });
    s.addText(p.time, { x: x + .15, y: 3.1, w: 2.65, h: .25, fontSize: 9, color: p.c, fontFace: "Arial", bold: true, letterSpacing: 1 });
    s.addText(p.title, { x: x + .15, y: 3.35, w: 2.65, h: .3, fontSize: 15, color: B.text, fontFace: "Arial", bold: true });
    s.addText(p.desc, { x: x + .15, y: 3.75, w: 2.65, h: 1.2, fontSize: 10, color: B.muted, fontFace: "Arial", lineSpacingMultiple: 1.3 });
    // Gate
    s.addShape(pptx.shapes.RECTANGLE, { x: x + .15, y: 5.1, w: 2.65, h: .01, fill: { color: p.c, transparency: 50 } });
    pill(s, x + .15, 5.25, "EXIT GATE", p.c);
    s.addText(p.gate, { x: x + .15, y: 5.55, w: 2.65, h: .3, fontSize: 10, color: p.c, fontFace: "Arial", bold: true });
  });

  footer(s, "11");
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 12 — TEAM (enhanced with visuals)
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide(); s.background = { fill: B.bg };
  section(s, "11 · TEAM");
  s.addText("The intersection that makes AURA possible.", { x: .8, y: .9, w: 10, h: .6, fontSize: 28, color: B.text, fontFace: "Arial", bold: true });

  const team = [
    { initials: "MC", name: "Dr. Maya Chen", role: "CEO", desc: "Ex-CRO, DBS Consumer Bank.\n18 yrs APAC retail credit.\nLed DBS model-risk\ntransformation (2019–23).", c: B.accent },
    { initials: "AP", name: "Arjun Patel", role: "CTO", desc: "Built fraud ML at Stripe\n& Paytm. Feature stores\nat 12M QPS.\nStanford CS PhD candidate.", c: B.highlight },
    { initials: "LP", name: "Dr. Lena Petrova", role: "CHIEF SCIENTIST", desc: "Co-author, doubly-robust\ncounterfactual paper\n(JMLR 2021).\nEx-Microsoft Research NYC.", c: B.green },
    { initials: "MT", name: "Marcus Tan", role: "HEAD OF REG", desc: "Ex-MAS regulator (TRM).\nAuthored MAS model-risk\nnotice. Ships AURA\naudit-ready.", c: B.amber },
  ];

  team.forEach((t, i) => {
    const x = .5 + i * 3.15;
    card(s, x, 1.7, 2.95, 4.8, { fill: B.surface, border: t.c });

    // Avatar with glow effect
    circle(s, x + .85, 1.9, 1.2, t.c);
    s.addText(t.initials, { x: x + .85, y: 1.9, w: 1.2, h: 1.2, fontSize: 28, color: B.white, fontFace: "Arial", bold: true, align: "center", valign: "middle" });
    // Experience ring (with transparency)
    s.addShape(pptx.shapes.OVAL, { x: x + .75, y: 1.8, w: 1.4, h: 1.4, fill: { color: t.c, transparency: 80 } });

    s.addText(t.name, { x: x + .15, y: 3.25, w: 2.65, h: .3, fontSize: 14, color: B.text, fontFace: "Arial", bold: true, align: "center" });
    s.addText(t.role, { x: x + .15, y: 3.55, w: 2.65, h: .25, fontSize: 9, color: t.c, fontFace: "Arial", bold: true, align: "center", letterSpacing: 1 });

    s.addShape(pptx.shapes.RECTANGLE, { x: x + .5, y: 3.95, w: 1.95, h: .01, fill: { color: t.c, transparency: 50 } });

    s.addText(t.desc, { x: x + .15, y: 4.1, w: 2.65, h: 1.8, fontSize: 10, color: B.muted, fontFace: "Arial", lineSpacingMultiple: 1.4, align: "center" });
  });

  // Team strength callout
  card(s, .5, 6.65, 12.3, .35, { fill: B.surface, border: B.accent, r: .06 });
  s.addText("✦  Combined: 50+ years in credit risk, fraud ML, causal inference, and MAS regulation", {
    x: .5, y: 6.65, w: 12.3, h: .35, fontSize: 10, color: B.highlight, fontFace: "Arial", bold: true, align: "center", valign: "middle"
  });

  s.addText("NOTE  Names shown are placeholders — replace with actual founders prior to submission.", {
    x: .5, y: 7.05, w: 12.3, h: .2, fontSize: 8, color: B.amber, fontFace: "Arial", italic: true
  });

  footer(s, "12");
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 13 — THE ASK
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide(); s.background = { fill: B.bg };
  section(s, "12 · THE ASK");
  s.addText("Ninety days. Zero risk.", { x: .8, y: .9, w: 10, h: .7, fontSize: 34, color: B.text, fontFace: "Arial", bold: true });

  const asks = [
    { n: "01", title: "90-day shadow deployment", desc: "Zero licence · single product line · establish divergence baseline", icon: "🔄" },
    { n: "02", title: "Executive sponsor", desc: "CRO or CDO level · convene credit, fraud, model-risk functions", icon: "👤" },
    { n: "03", title: "3 years of historical decision data", desc: "With outcome labels · counterfactual training begins on day one", icon: "📊" },
  ];

  asks.forEach((a, i) => {
    const y = 1.9 + i * 1.1;
    card(s, .5, y, 12.3, .9, { fill: B.surface, border: B.accent });
    circle(s, .8, y + .2, .5, B.accent);
    s.addText(a.icon, { x: .8, y: y + .2, w: .5, h: .5, fontSize: 16, align: "center", valign: "middle" });
    s.addText(a.title, { x: 1.5, y: y + .1, w: 5, h: .35, fontSize: 15, color: B.text, fontFace: "Arial", bold: true });
    s.addText(a.desc, { x: 1.5, y: y + .45, w: 10, h: .3, fontSize: 11, color: B.muted, fontFace: "Arial" });
    pill(s, 11, y + .3, a.n, B.accent);
  });

  // Commitment box
  card(s, .5, 5.3, 12.3, .9, { fill: "0F1A0F", border: B.green, bw: 1.5 });
  s.addText(
    "In return, we commit to a measurable reduction in combined credit and fraud losses\nwithin twelve months — or AURA reverts to GXS Bank at no cost.", {
    x: .8, y: 5.4, w: 11.7, h: .7, fontSize: 13, color: B.green, fontFace: "Arial", italic: true, align: "center", lineSpacingMultiple: 1.3
  });

  // Final branding
  s.addShape(pptx.shapes.OVAL, { x: 5.8, y: 6.3, w: 1.7, h: 1.7, fill: { color: B.primary, transparency: 85 } });
  s.addText("AURA", { x: 4.5, y: 6.4, w: 4.3, h: .6, fontSize: 30, color: B.accent, fontFace: "Arial", bold: true, align: "center", letterSpacing: 8 });
  s.addText("CONTINUUM RISK LABS  ·  2026", { x: 4, y: 7.0, w: 5.3, h: .25, fontSize: 9, color: B.muted, fontFace: "Arial", align: "center" });

  footer(s, "13");
}

// ═══════════════════════════════════════════════════════════════
// SAVE
// ═══════════════════════════════════════════════════════════════
pptx.writeFile({ fileName: "assets/pdfs/AURA_Pitch_Deck_Final.pptx" })
  .then(() => console.log("✅ Created: assets/pdfs/AURA_Pitch_Deck_Final.pptx"))
  .catch(err => console.error("❌ Error:", err));
