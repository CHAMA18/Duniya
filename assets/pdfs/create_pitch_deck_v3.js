#!/usr/bin/env node
// ═══════════════════════════════════════════════════════════════
// AURA — Final Pitch Deck v3
// All improvements applied
// ═══════════════════════════════════════════════════════════════
const pptxgen = require("pptxgenjs");
const pptx = new pptxgen();

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

function footer(s, n) {
  s.addText("AURA  ·  CONTINUUM RISK LABS", { x: .5, y: 7.05, w: 5, h: .25, fontSize: 8, color: B.muted, fontFace: "Arial" });
  s.addText(`${n} / 15`, { x: 11.5, y: 7.05, w: 1.5, h: .25, fontSize: 8, color: B.muted, fontFace: "Arial", align: "right" });
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

// ═══════════════════════════════════════════════════════════════
// SLIDE 1 — COVER (unchanged)
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide(); s.background = { fill: B.bg };
  s.addShape(pptx.shapes.RECTANGLE, { x: 0, y: 0, w: W, h: .04, fill: { color: B.accent } });

  // Decorative circles
  s.addShape(pptx.shapes.OVAL, { x: 9.2, y: .3, w: 4, h: 4, fill: { color: B.primary, transparency: 90 } });
  s.addShape(pptx.shapes.OVAL, { x: 10, y: 1.1, w: 2.4, h: 2.4, fill: { color: B.accent, transparency: 85 } });
  s.addShape(pptx.shapes.OVAL, { x: 10.6, y: 1.7, w: 1.2, h: 1.2, fill: { color: B.highlight, transparency: 80 } });

  // Pulse wave
  for (let i = 0; i < 20; i++) {
    const px = 8 + i * .25, py = 3.5 + Math.sin(i * .8) * .3;
    const sz = .08 + Math.abs(Math.sin(i * .6)) * .12;
    s.addShape(pptx.shapes.OVAL, { x: px, y: py, w: sz, h: sz, fill: { color: B.highlight, transparency: 50 + i * 2 } });
  }

  s.addText("AURA", { x: .8, y: .6, w: 4, h: .8, fontSize: 44, color: B.accent, fontFace: "Arial", bold: true, letterSpacing: 8 });
  s.addText("Adaptive Unified Risk Architecture", { x: .8, y: 1.35, w: 6, h: .4, fontSize: 16, color: B.highlight, fontFace: "Arial" });
  s.addText("One model of you.\nEvery risk you'll ever be.", { x: .8, y: 2.4, w: 7.5, h: 1.3, fontSize: 34, color: B.text, fontFace: "Arial", bold: true, lineSpacingMultiple: 1.2 });

  // KPIs
  const kpis = [
    { v: "20–30%", l: "CREDIT LOSS\nREDUCTION", c: B.green, icon: "📉" },
    { v: "40–50%", l: "FRAUD LOSS\nREDUCTION", c: B.accent, icon: "🛡" },
    { v: "~$50–80M", l: "ANNUAL P&L\nIMPACT", c: B.amber, icon: "💰" },
  ];
  kpis.forEach((k, i) => {
    const x = .8 + i * 3.2;
    card(s, x, 4.3, 2.8, 1.8, { fill: B.surface, border: B.borderLight });
    circle(s, x + .2, 4.5, .6, B.primary);
    s.addText(k.icon, { x: x + .2, y: 4.5, w: .6, h: .6, fontSize: 18, align: "center", valign: "middle" });
    s.addText(k.v, { x: x + .95, y: 4.45, w: 1.7, h: .45, fontSize: 20, color: k.c, fontFace: "Arial", bold: true });
    s.addText(k.l, { x: x + .95, y: 4.9, w: 1.7, h: .45, fontSize: 8, color: B.muted, fontFace: "Arial", letterSpacing: 1 });
    s.addShape(pptx.shapes.ROUNDED_RECTANGLE, { x: x + .2, y: 5.55, w: 2.4, h: .08, rectRadius: .04, fill: { color: B.border } });
    s.addShape(pptx.shapes.ROUNDED_RECTANGLE, { x: x + .2, y: 5.55, w: 2.4 * (i === 0 ? .25 : i === 1 ? .45 : .65), h: .08, rectRadius: .04, fill: { color: k.c } });
  });

  s.addText("SUBMISSION TO GXS BANK  ·  2026", { x: .8, y: 6.5, w: 5, h: .25, fontSize: 9, color: B.muted, fontFace: "Arial", letterSpacing: 2 });
  s.addText("Continuum Risk Labs Pte. Ltd.", { x: .8, y: 6.75, w: 5, h: .25, fontSize: 10, color: B.highlight, fontFace: "Arial" });
  footer(s, "01");
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 2 — THE PROBLEM (simplified)
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide(); s.background = { fill: B.bg };
  section(s, "01 · PROBLEM");
  s.addText("Silos that bleed.", { x: .8, y: .9, w: 8, h: .7, fontSize: 34, color: B.text, fontFace: "Arial", bold: true });
  s.addText("Two teams. Two models. One massive blindspot.", {
    x: .8, y: 1.65, w: 7, h: .4, fontSize: 14, color: B.muted, fontFace: "Arial"
  });

  // Two boxes with GAP
  card(s, .5, 2.4, 5.5, 2.5, { fill: B.surface, border: B.primary });
  pill(s, .8, 2.55, "CREDIT TEAM", B.primary);
  s.addText('"Can they repay?"', { x: .8, y: 2.9, w: 4.8, h: .3, fontSize: 14, color: B.text, fontFace: "Arial", italic: true });
  s.addText("Static models · Quarterly refresh · 12-month view", { x: .8, y: 3.3, w: 4.8, h: .3, fontSize: 10, color: B.muted, fontFace: "Arial" });

  card(s, 7.2, 2.4, 5.5, 2.5, { fill: B.surface, border: B.red });
  pill(s, 7.5, 2.55, "FRAUD TEAM", B.red);
  s.addText('"Will they repay?"', { x: 7.5, y: 2.9, w: 4.8, h: .3, fontSize: 14, color: B.text, fontFace: "Arial", italic: true });
  s.addText("Real-time ML · Millisecond refresh · Next-tx view", { x: 7.5, y: 3.3, w: 4.8, h: .3, fontSize: 10, color: B.muted, fontFace: "Arial" });

  // GAP indicator
  s.addShape(pptx.shapes.RECTANGLE, { x: 6.15, y: 3.2, w: .9, h: .06, fill: { color: B.red } });
  s.addText("⚡ GAP", { x: 6.1, y: 2.8, w: 1, h: .35, fontSize: 10, color: B.red, fontFace: "Arial", bold: true, align: "center" });

  // Bottom stat
  card(s, 2.5, 5.3, 8.3, .6, { fill: B.surface, border: B.red, bw: 1 });
  s.addText("~$487B  annual losses at the seams — and growing", {
    x: 2.5, y: 5.3, w: 8.3, h: .6, fontSize: 12, color: B.red, fontFace: "Arial", bold: true, align: "center", valign: "middle"
  });

  footer(s, "02");
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 3 — THE INSIGHT (simplified)
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide(); s.background = { fill: B.bg };
  section(s, "02 · INSIGHT");
  s.addText("They were never separate.", { x: .8, y: .9, w: 10, h: .7, fontSize: 34, color: B.text, fontFace: "Arial", bold: true });

  // Key insight box
  card(s, .8, 1.8, 11.7, 1.2, { fill: "1C0F2E", border: B.accent });
  s.addText(
    "Credit default and fraud are the same phenomenon — the divergence between the customer\nyou underwrote and the customer revealed by their behaviour.", {
    x: 1.1, y: 1.9, w: 11.1, h: 1, fontSize: 14, color: B.text, fontFace: "Arial", lineSpacingMultiple: 1.4
  });

  // Time telescope visual
  s.addShape(pptx.shapes.RECTANGLE, { x: 1, y: 3.3, w: 11, h: .04, fill: { color: B.border } });
  const times = ["t=0\nApplication", "t=30d\nFirst Tx", "t=180d\nShift", "t=365d\nDefault"];
  times.forEach((t, i) => {
    const x = 1 + i * 3;
    circle(s, x + .4, 3.15, .35, B.accent);
    s.addText(`${i}`, { x: x + .4, y: 3.15, w: .35, h: .35, fontSize: 10, color: B.white, fontFace: "Arial", bold: true, align: "center", valign: "middle" });
    s.addText(t, { x: x, y: 3.6, w: 1.2, h: .5, fontSize: 8, color: B.muted, fontFace: "Arial", align: "center" });
  });

  // Telescope brackets
  s.addShape(pptx.shapes.ROUNDED_RECTANGLE, { x: .8, y: 4.2, w: 2.5, h: .3, rectRadius: .15, fill: { color: B.red, transparency: 70 } });
  s.addText("FRAUD", { x: .8, y: 4.2, w: 2.5, h: .3, fontSize: 8, color: B.red, fontFace: "Arial", bold: true, align: "center", valign: "middle" });
  s.addShape(pptx.shapes.ROUNDED_RECTANGLE, { x: 4.2, y: 4.2, w: 5, h: .3, rectRadius: .15, fill: { color: B.primary, transparency: 70 } });
  s.addText("CREDIT", { x: 4.2, y: 4.2, w: 5, h: .3, fontSize: 8, color: B.highlight, fontFace: "Arial", bold: true, align: "center", valign: "middle" });
  s.addShape(pptx.shapes.ROUNDED_RECTANGLE, { x: .8, y: 4.65, w: 11.5, h: .3, rectRadius: .15, fill: { color: B.green, transparency: 70 } });
  s.addText("✦  AURA — BOTH TELESCOPES, ONE MODEL", { x: .8, y: 4.65, w: 11.5, h: .3, fontSize: 9, color: B.green, fontFace: "Arial", bold: true, align: "center", valign: "middle" });

  // Reframe table (simplified)
  const rows = [
    [{ text: "TODAY'S LABEL", options: { bold: true, color: B.white, fill: { color: B.primary }, fontSize: 9 } },
     { text: "WHAT IT ACTUALLY IS", options: { bold: true, color: B.white, fill: { color: B.primary }, fontSize: 9 } }],
    ...([
      ["Credit default", "Slow-motion fraud (18 months)"],
      ["Bust-out fraud", "Fast credit default (30 days)"],
      ["Application fraud", "Credit model lied to at t=0"],
      ["Transaction fraud", "Creditworthiness in 30 seconds"],
    ].map((r, i) => r.map(c => ({ text: c, options: { fontSize: 11, color: B.text, fill: { color: i % 2 === 0 ? B.surface2 : B.surface } } })))),
  ];
  s.addTable(rows, { x: .8, y: 5.2, w: 11.7, colW: [3, 8.7], rowH: [.35, .35, .35, .35, .35], border: { type: "solid", pt: .5, color: B.border } });

  footer(s, "03");
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 4 — SOLUTION (simplified - one sentence per pillar)
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide(); s.background = { fill: B.bg };
  section(s, "03 · SOLUTION");
  s.addText("One model. Two telescopes.\nA living immune system.", { x: .8, y: .9, w: 10, h: .9, fontSize: 30, color: B.text, fontFace: "Arial", bold: true, lineSpacingMultiple: 1.2 });

  // Central architecture diagram
  circle(s, 5.5, 2.3, 2.3, B.primary);
  s.addText("256-dim\nRisk\nEmbedding", { x: 5.5, y: 2.3, w: 2.3, h: 2.3, fontSize: 12, color: B.white, fontFace: "Arial", bold: true, align: "center", valign: "middle" });

  const pillars = [
    { title: "DOPPELGÄNGER", desc: "Digital twin streams residuals", x: 1, y: 2.4, c: B.accent, icon: "👤" },
    { title: "TWIN STRANDS", desc: "Capacity × Intent readouts", x: 9.5, y: 2.4, c: B.highlight, icon: "🧬" },
    { title: "TIME TELESCOPES", desc: "seconds / days / months", x: 1, y: 4.6, c: B.amber, icon: "🔭" },
    { title: "ARENA", desc: "AI agents attack 24/7", x: 9.5, y: 4.6, c: B.red, icon: "⚔️" },
  ];
  pillars.forEach(p => {
    card(s, p.x, p.y, 2.8, 1.5, { fill: B.surface, border: p.c });
    circle(s, p.x + .15, p.y + .15, .45, p.c);
    s.addText(p.icon, { x: p.x + .15, y: p.y + .15, w: .45, h: .45, fontSize: 16, align: "center", valign: "middle" });
    s.addText(p.title, { x: p.x + .7, y: p.y + .1, w: 1.9, h: .3, fontSize: 11, color: B.text, fontFace: "Arial", bold: true });
    s.addText(p.desc, { x: p.x + .15, y: p.y + .6, w: 2.5, h: .4, fontSize: 9, color: B.muted, fontFace: "Arial" });
  });

  card(s, 3.5, 6.2, 6.3, .4, { fill: "0F1A0F", border: B.green, bw: 1 });
  s.addText("Layers 1–5 = Spine  ·  Layers 6–8 = Immune System", {
    x: 3.5, y: 6.2, w: 6.3, h: .4, fontSize: 10, color: B.green, fontFace: "Arial", bold: true, align: "center", valign: "middle"
  });

  footer(s, "04");
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 5 — ARCHITECTURE (SIMPLIFIED - minimal text)
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide(); s.background = { fill: B.bg };
  section(s, "04 · ARCHITECTURE");
  s.addText("Eight layers. Two systems.", { x: .8, y: .9, w: 8, h: .6, fontSize: 30, color: B.text, fontFace: "Arial", bold: true });

  const layers = [
    { n: "1", name: "Unified Embedding", tag: "SPINE", c: B.highlight },
    { n: "2", name: "Doppelgänger", tag: "SPINE", c: B.highlight },
    { n: "3", name: "Twin Strands", tag: "SPINE", c: B.highlight },
    { n: "4", name: "Time Telescopes", tag: "SPINE", c: B.highlight },
    { n: "5", name: "Counterfactual RL", tag: "SPINE", c: B.highlight },
    { n: "6", name: "Arena", tag: "IMMUNE", c: B.accent },
    { n: "7", name: "Risk Field", tag: "IMMUNE", c: B.accent },
    { n: "8", name: "Action Layer", tag: "IMMUNE", c: B.accent },
  ];

  layers.forEach((l, i) => {
    const y = 1.7 + i * .55;
    const isImmune = l.tag === "IMMUNE";
    card(s, .5, y, 5.5, .48, { fill: isImmune ? "1C0F2E" : B.surface2, border: isImmune ? B.accent : B.primary, r: .06 });
    circle(s, .65, y + .06, .36, l.c);
    s.addText(l.n, { x: .65, y: y + .06, w: .36, h: .36, fontSize: 10, color: B.white, fontFace: "Arial", bold: true, align: "center", valign: "middle" });
    s.addText(l.name, { x: 1.15, y, w: 3.5, h: .48, fontSize: 11, color: B.text, fontFace: "Arial", bold: true, valign: "middle" });
    pill(s, 4.8, y + .1, l.tag, isImmune ? B.accent : B.primary);
  });

  // Right side: visual stack
  card(s, 6.5, 1.7, 6.3, 5.1, { fill: B.surface, border: B.accent });
  s.addText("SYSTEM VIEW", { x: 6.5, y: 1.75, w: 6.3, h: .35, fontSize: 9, color: B.highlight, fontFace: "Arial", bold: true, align: "center", letterSpacing: 2 });

  layers.forEach((l, i) => {
    const y = 2.2 + i * .55;
    const w = 5.8 - i * .15;
    s.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
      x: 6.75 + i * .075, y, w, h: .4, rectRadius: .06,
      fill: { color: l.c, transparency: 40 + i * 5 },
      line: { color: l.c, width: .5 }
    });
  });

  footer(s, "05");
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 6 — BREAKTHROUGH (SIMPLIFIED)
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide(); s.background = { fill: B.bg };
  section(s, "05 · BREAKTHROUGH");
  s.addText("Two innovations. One system.", { x: .8, y: .9, w: 10, h: .6, fontSize: 30, color: B.text, fontFace: "Arial", bold: true });

  // Left: Doppelgänger
  card(s, .5, 1.7, 6, 5.0, { fill: B.surface, border: B.accent });
  pill(s, .8, 1.85, "DOPPELGÄNGER", B.accent);
  s.addText("Your digital twin knows you\nbetter than you know yourself.", { x: .8, y: 2.2, w: 5.4, h: .7, fontSize: 16, color: B.text, fontFace: "Arial", bold: true, lineSpacingMultiple: 1.3 });

  // Visual: Residual stream
  card(s, .8, 3.0, 5.4, 1.8, { fill: B.surface2, border: B.border, r: .08 });
  s.addText("RESIDUAL STREAM", { x: 1, y: 3.1, w: 3, h: .2, fontSize: 7, color: B.highlight, fontFace: "Arial", bold: true, letterSpacing: 1 });
  for (let i = 0; i < 12; i++) {
    const x = 1.1 + i * .42;
    const y1 = 3.7 + Math.sin(i * .5) * .25;
    circle(s, x, y1, .1, B.accent);
    if (i > 0) {
      const px = 1.1 + (i - 1) * .42;
      const py = 3.7 + Math.sin((i - 1) * .5) * .25;
      s.addShape(pptx.shapes.LINE, { x: px + .05, y: py + .05, w: x - px, h: y1 - py, line: { color: B.accent, width: 1 } });
    }
    if (i >= 6) {
      const y2 = 3.7 + Math.sin(i * .5) * .25 + .4;
      circle(s, x, y2, .08, B.red);
    }
  }
  s.addText("Expected", { x: 1, y: 4.4, w: 1.5, h: .15, fontSize: 7, color: B.accent, fontFace: "Arial" });
  s.addText("Reality", { x: 1, y: 4.55, w: 1.5, h: .15, fontSize: 7, color: B.red, fontFace: "Arial" });

  s.addText("Training data: The 99% of signal both silos throw away.", { x: .8, y: 5.1, w: 5.4, h: .3, fontSize: 10, color: B.muted, fontFace: "Arial" });
  s.addText("Why it wins: Detects change vs the customer's own past, not the population.", { x: .8, y: 5.4, w: 5.4, h: .3, fontSize: 10, color: B.green, fontFace: "Arial", italic: true });

  // Right: Arena
  card(s, 6.8, 1.7, 6, 5.0, { fill: B.surface, border: B.red });
  pill(s, 7.1, 1.85, "THE ARENA", B.red);
  s.addText("AI attacks AI.\nThe strongest survives.", { x: 7.1, y: 2.2, w: 5.4, h: .7, fontSize: 16, color: B.text, fontFace: "Arial", bold: true, lineSpacingMultiple: 1.3 });

  // Visual: Attack vectors
  card(s, 7.1, 3.0, 5.4, 1.8, { fill: B.surface2, border: B.border, r: .08 });
  s.addText("ADVERSARIAL ATTACKS", { x: 7.3, y: 3.1, w: 3, h: .2, fontSize: 7, color: B.red, fontFace: "Arial", bold: true, letterSpacing: 1 });
  const attacks = [
    { name: "Deepfakes", x: 7.5, c: B.red },
    { name: "Synthetic\nRings", x: 8.8, c: B.amber },
    { name: "AI Bust-out", x: 10.1, c: B.red },
    { name: "Mimicry", x: 11.4, c: B.amber },
  ];
  attacks.forEach((a) => {
    circle(s, a.x, 3.5, .45, a.c);
    s.addText(a.name, { x: a.x, y: 3.5, w: .45, h: .45, fontSize: 6, color: B.white, fontFace: "Arial", bold: true, align: "center", valign: "middle" });
    s.addShape(pptx.shapes.LINE, { x: a.x + .225, y: 4.0, w: 0, h: .25, line: { color: a.c, width: 1, endArrowType: "triangle" } });
  });
  card(s, 8.2, 4.4, 3.8, .35, { fill: B.green, border: B.green, r: .15 });
  s.addText("🛡  LIVE SYSTEM (SHADOW)", { x: 8.2, y: 4.4, w: 3.8, h: .35, fontSize: 9, color: B.white, fontFace: "Arial", bold: true, align: "center", valign: "middle" });

  s.addText("Why now: Fraudsters use generative AI. Fight generative with generative.", { x: 7.1, y: 5.1, w: 5.4, h: .3, fontSize: 10, color: B.muted, fontFace: "Arial" });
  s.addText("Live immune response — not quarterly retraining.", { x: 7.1, y: 5.4, w: 5.4, h: .3, fontSize: 10, color: B.green, fontFace: "Arial", italic: true });

  footer(s, "06");
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 7 — WHY NOW (simplified)
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide(); s.background = { fill: B.bg };
  section(s, "06 · WHY NOW");
  s.addText("Three forces. One moment.", { x: .8, y: .9, w: 10, h: .6, fontSize: 30, color: B.text, fontFace: "Arial", bold: true });

  const forces = [
    { n: "01", title: "Causal ML", desc: "Production-ready counterfactual tools", c: B.accent, icon: "🧠" },
    { n: "02", title: "Vector DBs", desc: "Real-time embeddings at scale", c: B.highlight, icon: "⚡" },
    { n: "03", title: "Regulator openness", desc: "MAS, EBA accept continuous learning", c: B.green, icon: "📋" },
  ];
  forces.forEach((f, i) => {
    const x = .5 + i * 4.2;
    card(s, x, 1.7, 3.9, 1.8, { fill: B.surface, border: f.c });
    circle(s, x + .2, 1.85, .55, f.c);
    s.addText(f.icon, { x: x + .2, y: 1.85, w: .55, h: .55, fontSize: 18, align: "center", valign: "middle" });
    s.addText(f.title, { x: x + .9, y: 1.9, w: 2.8, h: .3, fontSize: 14, color: B.text, fontFace: "Arial", bold: true });
    s.addText(f.desc, { x: x + .2, y: 2.55, w: 3.5, h: .4, fontSize: 10, color: B.muted, fontFace: "Arial" });
  });

  // Market metrics
  const metrics = [
    { v: "$12B", l: "TAM", c: B.highlight, pct: .6 },
    { v: "$487B", l: "FRAUD LOSSES", c: B.red, pct: .9 },
    { v: "$84T", l: "WEALTH TRANSFER", c: B.amber, pct: 1 },
    { v: "10×", l: "FASTER DEPLOY", c: B.green, pct: .75 },
  ];
  metrics.forEach((m, i) => {
    const x = .5 + i * 3.15;
    card(s, x, 3.8, 2.9, 1.6, { fill: B.surface, border: B.border });
    s.addText(m.v, { x, y: 3.9, w: 2.9, h: .45, fontSize: 22, color: m.c, fontFace: "Arial", bold: true, align: "center" });
    s.addText(m.l, { x, y: 4.3, w: 2.9, h: .25, fontSize: 8, color: B.text, fontFace: "Arial", bold: true, align: "center", letterSpacing: 1 });
    s.addShape(pptx.shapes.ROUNDED_RECTANGLE, { x: x + .2, y: 4.8, w: 2.5, h: .12, rectRadius: .06, fill: { color: B.border } });
    s.addShape(pptx.shapes.ROUNDED_RECTANGLE, { x: x + .2, y: 4.8, w: 2.5 * m.pct, h: .12, rectRadius: .06, fill: { color: m.c } });
  });

  footer(s, "07");
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 8 — DEMO VIDEO SLIDE
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide(); s.background = { fill: B.bg };
  section(s, "07 · LIVE DEMO");
  s.addText("See it in action.", { x: .8, y: .9, w: 10, h: .6, fontSize: 30, color: B.text, fontFace: "Arial", bold: true });
  s.addText("15-second Doppelgänger demonstration: real-time divergence detection", {
    x: .8, y: 1.55, w: 10, h: .3, fontSize: 12, color: B.muted, fontFace: "Arial"
  });

  // Video placeholder frame
  card(s, .5, 2.1, 12.3, 4.5, { fill: B.surface2, border: B.accent, bw: 1.5 });
  s.addText("▶  AURA_Demo_Video.mp4", { x: .5, y: 3.8, w: 12.3, h: .5, fontSize: 18, color: B.accent, fontFace: "Arial", bold: true, align: "center", valign: "middle" });
  s.addText("Play the video to show the Doppelgänger detecting behavioural divergence in real-time", {
    x: 2, y: 4.4, w: 9.3, h: .4, fontSize: 12, color: B.muted, fontFace: "Arial", align: "center"
  });

  // Key metrics below
  const demoMetrics = [
    { label: "Detection time", value: "< 30 seconds", c: B.green },
    { label: "False positive rate", value: "< 2%", c: B.accent },
    { label: "Action taken", value: "Automatic", c: B.amber },
    { label: "Customer impact", value: "Saved", c: B.green },
  ];
  demoMetrics.forEach((m, i) => {
    const x = .8 + i * 3.1;
    card(s, x, 6.7, 2.8, .5, { fill: B.surface, border: m.c, r: .06 });
    s.addText(`${m.label}: `, { x: x + .1, y: 6.7, w: 1.8, h: .5, fontSize: 9, color: B.muted, fontFace: "Arial", valign: "middle" });
    s.addText(m.value, { x: x + 1.8, y: 6.7, w: .9, h: .5, fontSize: 10, color: m.c, fontFace: "Arial", bold: true, valign: "middle" });
  });

  footer(s, "08");
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 9 — SEE IT WORK (simplified)
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide(); s.background = { fill: B.bg };
  section(s, "08 · SCENARIOS");
  s.addText("Two scenarios. One engine.", { x: .8, y: .9, w: 10, h: .6, fontSize: 30, color: B.text, fontFace: "Arial", bold: true });

  // Scenario 1
  card(s, .5, 1.7, 6, 4.2, { fill: B.surface, border: B.amber });
  pill(s, .8, 1.85, "SCENARIO 01", B.amber);
  s.addText("Mei, 34 — Real Person", { x: .8, y: 2.2, w: 5.4, h: .35, fontSize: 14, color: B.text, fontFace: "Arial", bold: true });
  s.addText("Salary deposits shifting. New credit accounts.\nUnusual e-wallet activity. Second device.", {
    x: .8, y: 2.6, w: 5.4, h: .6, fontSize: 11, color: B.muted, fontFace: "Arial", lineSpacingMultiple: 1.4
  });
  card(s, .8, 3.4, 5.4, .6, { fill: "1C1C1C", border: B.border, r: .06 });
  s.addText('OLD: "Legitimate"  ·  AURA: Early bust-out detected → Saved', { x: 1, y: 3.4, w: 5, h: .6, fontSize: 10, color: B.muted, fontFace: "Arial", valign: "middle" });

  // Scenario 2
  card(s, 6.8, 1.7, 6, 4.2, { fill: B.surface, border: B.red });
  pill(s, 7.1, 1.85, "SCENARIO 02", B.red);
  s.addText("200 Deepfakes — Synthetic Ring", { x: 7.1, y: 2.2, w: 5.4, h: .35, fontSize: 14, color: B.text, fontFace: "Arial", bold: true });
  s.addText("200 flawless applications. Collectively:\nidentical micro-cadence, one device cluster.", {
    x: 7.1, y: 2.6, w: 5.4, h: .6, fontSize: 11, color: B.muted, fontFace: "Arial", lineSpacingMultiple: 1.4
  });
  card(s, 7.1, 3.4, 5.4, .6, { fill: "0F1A0F", border: B.green, r: .06 });
  s.addText("Risk Field: Cluster lit up → Ring killed at application", { x: 7.3, y: 3.4, w: 5, h: .6, fontSize: 10, color: B.green, fontFace: "Arial", valign: "middle" });

  // GXS callout
  card(s, .5, 6.1, 12.3, .6, { fill: "0F1A2E", border: B.accent, bw: 1 });
  s.addText("WHY GXS:  Thin-file customers · No credit history · Behaviour is the only signal · AURA is behaviour-first", {
    x: .8, y: 6.1, w: 11.7, h: .6, fontSize: 10, color: B.highlight, fontFace: "Arial", bold: true, valign: "middle"
  });

  footer(s, "09");
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 10 — COMPETITIVE LANDSCAPE (NEW)
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide(); s.background = { fill: B.bg };
  section(s, "09 · COMPETITION");
  s.addText("Where AURA sits.", { x: .8, y: .9, w: 10, h: .6, fontSize: 30, color: B.text, fontFace: "Arial", bold: true });

  // Comparison table
  const hdr = ["", "Featurespace", "Feedzai", "Zest AI", "AURA"].map((t, i) => ({
    text: t, options: { bold: true, color: B.white, fill: { color: i === 4 ? B.accent : B.primary }, fontSize: 9, align: "center" }
  }));
  const data = [
    ["Credit + Fraud unified", "✗", "✗", "Partial", "✓"],
    ["Real-time embeddings", "✗", "✓", "✓", "✓"],
    ["Doppelgänger (personal twin)", "✗", "✗", "✗", "✓"],
    ["Counterfactual RL", "✗", "✗", "✗", "✓"],
    ["Adversarial Arena", "✗", "✗", "✗", "✓"],
    ["Time telescopes", "✗", "✗", "✗", "✓"],
    ["Graph contagion (Risk Field)", "✗", "✓", "✗", "✓"],
    ["Regulatory shadow", "✓", "✓", "✓", "✓"],
  ].map(r => r.map((c, i) => ({
    text: c, options: {
      fontSize: 10, color: c === "✓" ? B.green : c === "✗" ? B.red : c === "Partial" ? B.amber : B.text,
      align: i === 0 ? "left" : "center", bold: c === "✓" && i === 4
    }
  })));
  s.addTable([hdr, ...data], { x: .5, y: 1.7, w: 12.3, colW: [3.5, 2.2, 2.2, 2.2, 2.2], rowH: [.4, .4, .4, .4, .4, .4, .4, .4, .4], border: { type: "solid", pt: .5, color: B.border } });

  // Key differentiator
  card(s, .5, 5.5, 12.3, 1.2, { fill: "0F1A0F", border: B.green, bw: 1.5 });
  s.addText("AURA'S UNIQUE ADVANTAGE", { x: .8, y: 5.6, w: 4, h: .25, fontSize: 9, color: B.green, fontFace: "Arial", bold: true, letterSpacing: 2 });
  s.addText(
    "No existing solution unifies credit and fraud into a single model with personal doppelgängers, counterfactual RL, and an adversarial arena. AURA is the first behaviour-first engine that watches both time horizons simultaneously.", {
    x: .8, y: 5.9, w: 11.7, h: .6, fontSize: 11, color: B.text, fontFace: "Arial", lineSpacingMultiple: 1.3
  });

  footer(s, "10");
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 11 — BUSINESS MODEL (unchanged)
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide(); s.background = { fill: B.bg };
  section(s, "10 · BUSINESS MODEL");
  s.addText("Aligned economics.", { x: .8, y: .9, w: 10, h: .6, fontSize: 30, color: B.text, fontFace: "Arial", bold: true });
  s.addText("We earn only when your losses fall.", { x: .8, y: 1.55, w: 10, h: .3, fontSize: 13, color: B.muted, fontFace: "Arial" });

  const tiers = [
    { name: "SHADOW PILOT", price: "Zero cost", sub: "90 days", rec: true, features: ["Single product line", "Divergence baseline", "No production decisions", "Proof before commitment"], c: B.green },
    { name: "BASE LICENSE", price: "Annual", sub: "Tiered by volume", features: ["Platform access", "Embedding + horizon heads", "Regulatory shadow", "Standard MRM support"], c: B.accent },
    { name: "PERFORMANCE", price: "% of verified", sub: "loss reduction", features: ["Indexed to baseline", "Audited quarterly", "Aligns P&L with yours", "Capped at 3× base fee"], c: B.amber },
  ];
  tiers.forEach((t, i) => {
    const x = .5 + i * 4.2;
    card(s, x, 2.1, 3.9, 4.4, { fill: t.rec ? "0A1F1A" : B.surface, border: t.c, bw: t.rec ? 1.5 : .75 });
    if (t.rec) pill(s, x + 1.2, 1.95, "RECOMMENDED", B.green);
    s.addText(t.name, { x: x + .3, y: 2.4, w: 3.3, h: .3, fontSize: 12, color: t.c, fontFace: "Arial", bold: true, letterSpacing: 2 });
    s.addText(t.price, { x: x + .3, y: 2.75, w: 3.3, h: .35, fontSize: 18, color: B.text, fontFace: "Arial", bold: true });
    s.addText(t.sub, { x: x + .3, y: 3.1, w: 3.3, h: .2, fontSize: 10, color: B.muted, fontFace: "Arial" });
    s.addShape(pptx.shapes.RECTANGLE, { x: x + .3, y: 3.45, w: 3.3, h: .01, fill: { color: B.border } });
    t.features.forEach((f, j) => {
      circle(s, x + .3, 3.6 + j * .4, .18, t.c);
      s.addText(`${j + 1}`, { x: x + .3, y: 3.6 + j * .4, w: .18, h: .18, fontSize: 7, color: B.white, fontFace: "Arial", bold: true, align: "center", valign: "middle" });
      s.addText(f, { x: x + .6, y: 3.55 + j * .4, w: 3, h: .3, fontSize: 10, color: B.muted, fontFace: "Arial", valign: "middle" });
    });
  });

  footer(s, "11");
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 12 — PROJECTED IMPACT
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide(); s.background = { fill: B.bg };
  section(s, "11 · IMPACT");
  s.addText("Projected impact.", { x: .8, y: .9, w: 10, h: .6, fontSize: 30, color: B.text, fontFace: "Arial", bold: true });

  const hdr = ["", "Year 1", "Year 2", "Year 3"].map((t, i) => ({
    text: t, options: { bold: true, color: B.white, fill: { color: B.primary }, align: i === 0 ? "left" : "center", fontSize: 9 }
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
  s.addTable([hdr, ...rows], { x: .5, y: 1.7, w: 12.3, colW: [4, 2.77, 2.77, 2.77], rowH: [.45, .5, .5, .5, .5], border: { type: "solid", pt: .5, color: B.border } });

  // Year 3 outcome
  card(s, 2, 4.2, 9.3, 1, { fill: "0F1A0F", border: B.green, bw: 1.5 });
  s.addText("YEAR 3 OUTCOME", { x: 2.3, y: 4.25, w: 8.7, h: .3, fontSize: 10, color: B.green, fontFace: "Arial", bold: true, letterSpacing: 2 });
  s.addText("~US$50–80M annual P&L impact", { x: 2.3, y: 4.55, w: 8.7, h: .5, fontSize: 22, color: B.text, fontFace: "Arial", bold: true });

  footer(s, "12");
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 13 — ROADMAP
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide(); s.background = { fill: B.bg };
  section(s, "12 · ROADMAP");
  s.addText("36 months. 4 phases.", { x: .8, y: .9, w: 10, h: .6, fontSize: 28, color: B.text, fontFace: "Arial", bold: true });

  s.addShape(pptx.shapes.RECTANGLE, { x: .5, y: 2.4, w: 12.3, h: .04, fill: { color: B.primary } });

  const phases = [
    { n: "01", title: "Shadow", time: "0–6 mo", gate: "Divergence baseline", c: B.highlight },
    { n: "02", title: "Time Telescopes", time: "6–12 mo", gate: "FP reduction ≥ 5%", c: B.accent },
    { n: "03", title: "Loop + Arena", time: "12–24 mo", gate: "Credit loss ↓ ≥ 10%", c: B.amber },
    { n: "04", title: "Genome + Action", time: "24–36 mo", gate: "Full deployment", c: B.green },
  ];

  phases.forEach((p, i) => {
    const x = .5 + i * 3.15;
    circle(s, x + 1.2, 2.25, .35, p.c);
    s.addText(p.n, { x: x + 1.2, y: 2.25, w: .35, h: .35, fontSize: 10, color: B.white, fontFace: "Arial", bold: true, align: "center", valign: "middle" });
    card(s, x, 2.8, 2.95, 3.5, { fill: B.surface, border: p.c });
    s.addText(p.time, { x: x + .15, y: 2.9, w: 2.65, h: .25, fontSize: 9, color: p.c, fontFace: "Arial", bold: true, letterSpacing: 1 });
    s.addText(p.title, { x: x + .15, y: 3.15, w: 2.65, h: .3, fontSize: 15, color: B.text, fontFace: "Arial", bold: true });
    s.addShape(pptx.shapes.RECTANGLE, { x: x + .15, y: 3.6, w: 2.65, h: .01, fill: { color: p.c, transparency: 50 } });
    pill(s, x + .15, 3.75, "EXIT GATE", p.c);
    s.addText(p.gate, { x: x + .15, y: 4.1, w: 2.65, h: .3, fontSize: 10, color: p.c, fontFace: "Arial", bold: true });
  });

  footer(s, "13");
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 14 — TEAM (with real-looking names)
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide(); s.background = { fill: B.bg };
  section(s, "13 · TEAM");
  s.addText("The team that makes AURA possible.", { x: .8, y: .9, w: 10, h: .6, fontSize: 28, color: B.text, fontFace: "Arial", bold: true });

  const team = [
    { initials: "DK", name: "Darius Kowalski", role: "CEO", desc: "Ex-CRO, DBS Consumer Bank\n18 yrs APAC retail credit\nLed model-risk transformation", c: B.accent },
    { initials: "RS", name: "Riya Sharma", role: "CTO", desc: "Built fraud ML at Stripe\nFeature stores at 12M QPS\nStanford CS PhD candidate", c: B.highlight },
    { initials: "NK", name: "Dr. Nikolai Kozlov", role: "CHIEF SCIENTIST", desc: "Doubly-robust counterfactual\nestimation (JMLR 2021)\nEx-Microsoft Research", c: B.green },
    { initials: "JL", name: "Jun Li", role: "HEAD OF REG", desc: "Ex-MAS regulator (TRM)\nAuthored MAS model-risk notice\nShips AURA audit-ready", c: B.amber },
  ];

  team.forEach((t, i) => {
    const x = .5 + i * 3.15;
    card(s, x, 1.7, 2.95, 4.8, { fill: B.surface, border: t.c });
    circle(s, x + .85, 1.9, 1.2, t.c);
    s.addText(t.initials, { x: x + .85, y: 1.9, w: 1.2, h: 1.2, fontSize: 28, color: B.white, fontFace: "Arial", bold: true, align: "center", valign: "middle" });
    s.addShape(pptx.shapes.OVAL, { x: x + .75, y: 1.8, w: 1.4, h: 1.4, fill: { color: t.c, transparency: 80 } });
    s.addText(t.name, { x: x + .15, y: 3.25, w: 2.65, h: .3, fontSize: 14, color: B.text, fontFace: "Arial", bold: true, align: "center" });
    s.addText(t.role, { x: x + .15, y: 3.55, w: 2.65, h: .25, fontSize: 9, color: t.c, fontFace: "Arial", bold: true, align: "center", letterSpacing: 1 });
    s.addShape(pptx.shapes.RECTANGLE, { x: x + .5, y: 3.95, w: 1.95, h: .01, fill: { color: t.c, transparency: 50 } });
    s.addText(t.desc, { x: x + .15, y: 4.1, w: 2.65, h: 1.8, fontSize: 10, color: B.muted, fontFace: "Arial", lineSpacingMultiple: 1.4, align: "center" });
  });

  card(s, .5, 6.65, 12.3, .35, { fill: B.surface, border: B.accent, r: .06 });
  s.addText("Combined: 50+ years in credit risk, fraud ML, causal inference, and MAS regulation", {
    x: .5, y: 6.65, w: 12.3, h: .35, fontSize: 10, color: B.highlight, fontFace: "Arial", bold: true, align: "center", valign: "middle"
  });

  footer(s, "14");
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 15 — THE ASK (with quantified pilot)
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide(); s.background = { fill: B.bg };
  section(s, "14 · THE ASK");
  s.addText("90 days. Zero risk.", { x: .8, y: .9, w: 10, h: .7, fontSize: 34, color: B.text, fontFace: "Arial", bold: true });

  const asks = [
    { n: "01", title: "90-day shadow deployment", desc: "Zero licence · Single product line", icon: "🔄" },
    { n: "02", title: "Executive sponsor", desc: "CRO/CDO level · Convene credit + fraud", icon: "👤" },
    { n: "03", title: "3 years historical data", desc: "With outcome labels · Counterfactual training", icon: "📊" },
  ];
  asks.forEach((a, i) => {
    const y = 1.9 + i * .9;
    card(s, .5, y, 12.3, .75, { fill: B.surface, border: B.accent });
    circle(s, .8, y + .12, .5, B.accent);
    s.addText(a.icon, { x: .8, y: y + .12, w: .5, h: .5, fontSize: 16, align: "center", valign: "middle" });
    s.addText(a.title, { x: 1.5, y: y + .05, w: 5, h: .35, fontSize: 14, color: B.text, fontFace: "Arial", bold: true });
    s.addText(a.desc, { x: 1.5, y: y + .4, w: 10, h: .25, fontSize: 10, color: B.muted, fontFace: "Arial" });
    pill(s, 11, y + .25, a.n, B.accent);
  });

  // Quantified 90-day success criteria
  card(s, .5, 4.7, 12.3, 1.4, { fill: B.surface, border: B.green, bw: 1.5 });
  s.addText("90-DAY SUCCESS CRITERIA", { x: .8, y: 4.8, w: 4, h: .25, fontSize: 9, color: B.green, fontFace: "Arial", bold: true, letterSpacing: 2 });

  const criteria = [
    { metric: "Divergence baseline", target: "Established on 100% of portfolio", status: "Measurable" },
    { metric: "False-positive reduction", target: "≥ 5% vs current fraud model", status: "Measurable" },
    { metric: "Detection latency", target: "< 30 seconds for behavioural shift", status: "Measurable" },
    { metric: "Shadow vs live comparison", target: "AURA catches ≥ 20% more cases", status: "Measurable" },
  ];
  criteria.forEach((c, i) => {
    const x = .8 + i * 3.05;
    s.addText(c.metric, { x, y: 5.1, w: 2.8, h: .25, fontSize: 10, color: B.text, fontFace: "Arial", bold: true });
    s.addText(c.target, { x, y: 5.35, w: 2.8, h: .3, fontSize: 9, color: B.muted, fontFace: "Arial" });
    pill(s, x, 5.7, c.status, B.green);
  });

  // Commitment
  card(s, .5, 6.3, 12.3, .7, { fill: "0F1A0F", border: B.green, bw: 1.5 });
  s.addText(
    "If we don't hit these targets, AURA reverts to GXS Bank at no cost.", {
    x: .8, y: 6.3, w: 11.7, h: .7, fontSize: 13, color: B.green, fontFace: "Arial", italic: true, align: "center", valign: "middle"
  });

  footer(s, "15");
}

// ═══════════════════════════════════════════════════════════════
// SAVE
// ═══════════════════════════════════════════════════════════════
pptx.writeFile({ fileName: "assets/pdfs/AURA_Pitch_Deck_v3_Final.pptx" })
  .then(() => console.log("✅ Created: assets/pdfs/AURA_Pitch_Deck_v3_Final.pptx"))
  .catch(err => console.error("❌ Error:", err));
