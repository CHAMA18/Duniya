#!/usr/bin/env node
// ═══════════════════════════════════════════════════════════════
// AURA — Dawa Clinic Visual Style
// Full-bleed dark backgrounds · White text · Blue accents
// ═══════════════════════════════════════════════════════════════
const pptxgen = require("pptxgenjs");
const pptx = new pptxgen();

// ── Dawa-style Brand ──
const B = {
  blue: "07A1E7",     // Primary accent (Dawa blue)
  dark: "0A1628",     // Deep navy background
  darker: "060E1A",   // Darkest background
  surface: "0F1F35",  // Card surface
  text: "FFFFFF",      // White text
  muted: "8899AA",    // Muted text
  green: "10B981",    // Success
  red: "EF4444",      // Error
  amber: "F59E0B",    // Warning
};

pptx.author = "Continuum Risk Labs Pte. Ltd.";
pptx.title = "AURA Pitch Deck";
pptx.layout = "LAYOUT_WIDE";
const W = 13.33, H = 7.5;

// ── Helper: Full-slide dark background ──
function darkBg(s) {
  s.background = { fill: B.dark };
}

// ── Helper: Bottom bar (Dawa style) ──
function bottomBar(s) {
  s.addShape(pptx.shapes.RECTANGLE, { x: 0, y: 7.1, w: W, h: .4, fill: { color: B.blue } });
  s.addText("AURA  ·  CONTINUUM RISK LABS  ·  2026", {
    x: .5, y: 7.1, w: W - 1, h: .4,
    fontSize: 10, color: B.text, fontFace: "Arial", bold: true, valign: "middle"
  });
}

// ── Helper: Blue underline (Dawa style) ──
function blueUnderline(s, x, y, w) {
  s.addShape(pptx.shapes.RECTANGLE, { x, y, w, h: .04, fill: { color: B.blue } });
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 1 — COVER
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide();
  darkBg(s);

  // Logo area
  s.addText("AURA", {
    x: .8, y: .8, w: 4, h: .6,
    fontSize: 36, color: B.blue, fontFace: "Arial", bold: true, letterSpacing: 6
  });
  blueUnderline(s, .8, 1.4, 2);

  // Main title
  s.addText("Adaptive Unified\nRisk Architecture", {
    x: .8, y: 2.0, w: 8, h: 1.6,
    fontSize: 42, color: B.text, fontFace: "Arial", bold: true, lineSpacingMultiple: 1.1
  });

  // Tagline
  s.addText("One model of you. Every risk you'll ever be.", {
    x: .8, y: 3.8, w: 8, h: .5,
    fontSize: 18, color: B.muted, fontFace: "Arial"
  });

  // KPI strip
  const kpis = [
    { v: "20–30%", l: "CREDIT LOSS REDUCTION" },
    { v: "40–50%", l: "FRAUD LOSS REDUCTION" },
    { v: "~$50–80M", l: "ANNUAL P&L IMPACT" },
  ];
  kpis.forEach((k, i) => {
    const x = .8 + i * 4.0;
    s.addText(k.v, { x, y: 5.0, w: 3.5, h: .5, fontSize: 28, color: B.blue, fontFace: "Arial", bold: true });
    s.addText(k.l, { x, y: 5.5, w: 3.5, h: .3, fontSize: 10, color: B.muted, fontFace: "Arial", letterSpacing: 1 });
  });

  // Right side decorative circle
  s.addShape(pptx.shapes.OVAL, { x: 9.5, y: 1.5, w: 3.5, h: 3.5, fill: { color: B.blue, transparency: 90 } });
  s.addShape(pptx.shapes.OVAL, { x: 10.2, y: 2.2, w: 2.1, h: 2.1, fill: { color: B.blue, transparency: 85 } });

  // Meta
  s.addText("SUBMISSION TO GXS BANK  ·  GLOBAL FINTECH HACKELERATOR  ·  SINGAPORE 2026", {
    x: .8, y: 6.5, w: 10, h: .3, fontSize: 9, color: B.muted, fontFace: "Arial", letterSpacing: 2
  });
  s.addText("Continuum Risk Labs Pte. Ltd.", {
    x: .8, y: 6.8, w: 5, h: .25, fontSize: 10, color: B.blue, fontFace: "Arial"
  });

  bottomBar(s);
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 2 — PROBLEM
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide();
  darkBg(s);

  // Section label
  s.addText("THE PROBLEM", {
    x: .8, y: .5, w: 4, h: .3, fontSize: 10, color: B.blue, fontFace: "Arial", bold: true, letterSpacing: 3
  });
  blueUnderline(s, .8, .85, 1.5);

  // Title
  s.addText("Silos that bleed.", {
    x: .8, y: 1.2, w: 10, h: .8, fontSize: 36, color: B.text, fontFace: "Arial", bold: true
  });

  // Two columns with statistics
  // Left column
  s.addText("Credit Team", {
    x: .8, y: 2.5, w: 5, h: .4, fontSize: 14, color: B.blue, fontFace: "Arial", bold: true
  });
  s.addText('"Can they repay?"', {
    x: .8, y: 3.0, w: 5, h: .4, fontSize: 16, color: B.text, fontFace: "Arial", italic: true
  });
  s.addText("Static models · Quarterly refresh · 12-month view", {
    x: .8, y: 3.5, w: 5, h: .3, fontSize: 11, color: B.muted, fontFace: "Arial"
  });

  // Right column
  s.addText("Fraud Team", {
    x: 7, y: 2.5, w: 5, h: .4, fontSize: 14, color: B.red, fontFace: "Arial", bold: true
  });
  s.addText('"Will they repay?"', {
    x: 7, y: 3.0, w: 5, h: .4, fontSize: 16, color: B.text, fontFace: "Arial", italic: true
  });
  s.addText("Real-time ML · Millisecond refresh · Next-tx view", {
    x: 7, y: 3.5, w: 5, h: .3, fontSize: 11, color: B.muted, fontFace: "Arial"
  });

  // Gap indicator
  s.addShape(pptx.shapes.RECTANGLE, { x: 6.2, y: 2.8, w: .8, h: .04, fill: { color: B.red } });
  s.addText("GAP", {
    x: 6.1, y: 2.3, w: 1, h: .3, fontSize: 10, color: B.red, fontFace: "Arial", bold: true, align: "center"
  });

  // Big stat at bottom
  s.addText("$487B", {
    x: .8, y: 4.5, w: 12, h: 1.2, fontSize: 72, color: B.red, fontFace: "Arial", bold: true, align: "center"
  });
  s.addText("annual fraud + credit losses at the seams — and growing", {
    x: .8, y: 5.7, w: 12, h: .4, fontSize: 14, color: B.muted, fontFace: "Arial", align: "center"
  });

  bottomBar(s);
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 3 — INSIGHT
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide();
  darkBg(s);

  s.addText("THE INSIGHT", {
    x: .8, y: .5, w: 4, h: .3, fontSize: 10, color: B.blue, fontFace: "Arial", bold: true, letterSpacing: 3
  });
  blueUnderline(s, .8, .85, 1.5);

  s.addText("They were never separate.", {
    x: .8, y: 1.2, w: 10, h: .8, fontSize: 36, color: B.text, fontFace: "Arial", bold: true
  });

  // Key insight
  s.addText(
    "Credit default and fraud are the same phenomenon —\nthe divergence between the customer you underwrote\nand the customer revealed by their behaviour.", {
    x: .8, y: 2.2, w: 10, h: 1.2, fontSize: 16, color: B.muted, fontFace: "Arial", lineSpacingMultiple: 1.5
  });

  // Reframe examples
  const reframes = [
    { label: "Credit default", desc: "Slow-motion fraud (18 months)" },
    { label: "Bust-out fraud", desc: "Fast credit default (30 days)" },
    { label: "Application fraud", desc: "Credit model lied to at t=0" },
    { label: "Transaction fraud", desc: "Creditworthiness in 30 seconds" },
  ];
  reframes.forEach((r, i) => {
    const y = 3.8 + i * .6;
    s.addText(r.label, { x: .8, y, w: 4, h: .4, fontSize: 14, color: B.blue, fontFace: "Arial", bold: true });
    s.addText(r.desc, { x: 5, y, w: 6, h: .4, fontSize: 14, color: B.text, fontFace: "Arial" });
    if (i < reframes.length - 1) {
      s.addShape(pptx.shapes.RECTANGLE, { x: .8, y: y + .5, w: 10, h: .01, fill: { color: B.surface } });
    }
  });

  bottomBar(s);
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 4 — SOLUTION
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide();
  darkBg(s);

  s.addText("THE SOLUTION", {
    x: .8, y: .5, w: 4, h: .3, fontSize: 10, color: B.blue, fontFace: "Arial", bold: true, letterSpacing: 3
  });
  blueUnderline(s, .8, .85, 1.5);

  s.addText("One model. Two telescopes.\nA living immune system.", {
    x: .8, y: 1.2, w: 10, h: 1.2, fontSize: 32, color: B.text, fontFace: "Arial", bold: true, lineSpacingMultiple: 1.2
  });

  // Four pillars
  const pillars = [
    { title: "Unified\nEmbedding", desc: "256-dim latent space", icon: "🧠" },
    { title: "Doppelgänger", desc: "Digital twin streams residuals", icon: "👤" },
    { title: "Time\nTelescopes", desc: "seconds / days / months", icon: "🔭" },
    { title: "Arena", desc: "AI attacks AI 24/7", icon: "⚔️" },
  ];
  pillars.forEach((p, i) => {
    const x = .8 + i * 3.1;
    // Card
    s.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
      x, y: 2.8, w: 2.8, h: 3.5, rectRadius: .12,
      fill: { color: B.surface }, line: { color: B.blue, width: .75 }
    });
    // Number circle
    s.addShape(pptx.shapes.OVAL, { x: x + .9, y: 3.0, w: 1, h: 1, fill: { color: B.blue } });
    s.addText(`${i + 1}`, { x: x + .9, y: 3.0, w: 1, h: 1, fontSize: 28, color: B.text, fontFace: "Arial", bold: true, align: "center", valign: "middle" });
    // Title
    s.addText(p.title, { x: x + .2, y: 4.1, w: 2.4, h: .7, fontSize: 14, color: B.text, fontFace: "Arial", bold: true, align: "center", lineSpacingMultiple: 1.1 });
    // Description
    s.addText(p.desc, { x: x + .2, y: 4.8, w: 2.4, h: .5, fontSize: 10, color: B.muted, fontFace: "Arial", align: "center" });
  });

  bottomBar(s);
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 5 — BREAKTHROUGH (Doppelgänger + Arena)
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide();
  darkBg(s);

  s.addText("THE BREAKTHROUGH", {
    x: .8, y: .5, w: 4, h: .3, fontSize: 10, color: B.blue, fontFace: "Arial", bold: true, letterSpacing: 3
  });
  blueUnderline(s, .8, .85, 1.5);

  s.addText("Doppelgänger + Arena", {
    x: .8, y: 1.2, w: 10, h: .7, fontSize: 32, color: B.text, fontFace: "Arial", bold: true
  });

  // Left: Doppelgänger
  s.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
    x: .5, y: 2.2, w: 6, h: 4.5, rectRadius: .12,
    fill: { color: B.surface }, line: { color: B.blue, width: 1 }
  });
  s.addText("DOPPELGÄNGER", {
    x: .8, y: 2.4, w: 5, h: .3, fontSize: 10, color: B.blue, fontFace: "Arial", bold: true, letterSpacing: 2
  });
  s.addText("Your digital twin knows you\nbetter than you know yourself.", {
    x: .8, y: 2.8, w: 5.4, h: .8, fontSize: 16, color: B.text, fontFace: "Arial", bold: true, lineSpacingMultiple: 1.3
  });
  s.addText(
    "A self-supervised generative twin per customer.\nContinuously predicts their next state and streams\nthe residuals — where reality diverges from expectation.", {
    x: .8, y: 3.8, w: 5.4, h: 1.0, fontSize: 11, color: B.muted, fontFace: "Arial", lineSpacingMultiple: 1.4
  });
  s.addText("Training data: The 99% of signal both silos throw away.", {
    x: .8, y: 5.0, w: 5.4, h: .3, fontSize: 10, color: B.green, fontFace: "Arial", italic: true
  });
  s.addText("Why it wins: Detects change vs the customer's own past, not the population.", {
    x: .8, y: 5.3, w: 5.4, h: .3, fontSize: 10, color: B.green, fontFace: "Arial", italic: true
  });

  // Right: Arena
  s.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
    x: 6.8, y: 2.2, w: 6, h: 4.5, rectRadius: .12,
    fill: { color: B.surface }, line: { color: B.red, width: 1 }
  });
  s.addText("THE ARENA", {
    x: 7.1, y: 2.4, w: 5, h: .3, fontSize: 10, color: B.red, fontFace: "Arial", bold: true, letterSpacing: 2
  });
  s.addText("AI attacks AI.\nThe strongest survives.", {
    x: 7.1, y: 2.8, w: 5.4, h: .8, fontSize: 16, color: B.text, fontFace: "Arial", bold: true, lineSpacingMultiple: 1.3
  });
  s.addText(
    "Continuously running adversarial agents — synthetic fraud rings,\ndeepfake applicants, AI-built bust-out personas — attack the\nlive system in a shadow environment.", {
    x: 7.1, y: 3.8, w: 5.4, h: 1.0, fontSize: 11, color: B.muted, fontFace: "Arial", lineSpacingMultiple: 1.4
  });
  s.addText("Live immune response — not quarterly retraining.", {
    x: 7.1, y: 5.0, w: 5.4, h: .3, fontSize: 10, color: B.green, fontFace: "Arial", italic: true
  });
  s.addText("Fight generative fraud with generative defence.", {
    x: 7.1, y: 5.3, w: 5.4, h: .3, fontSize: 10, color: B.green, fontFace: "Arial", italic: true
  });

  bottomBar(s);
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 6 — SEE IT WORK
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide();
  darkBg(s);

  s.addText("SEE IT WORK", {
    x: .8, y: .5, w: 4, h: .3, fontSize: 10, color: B.blue, fontFace: "Arial", bold: true, letterSpacing: 3
  });
  blueUnderline(s, .8, .85, 1.5);

  s.addText("Two scenarios. One engine.", {
    x: .8, y: 1.2, w: 10, h: .7, fontSize: 32, color: B.text, fontFace: "Arial", bold: true
  });

  // Scenario 1
  s.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
    x: .5, y: 2.2, w: 6, h: 4.5, rectRadius: .12,
    fill: { color: B.surface }, line: { color: B.amber, width: .75 }
  });
  s.addText("SCENARIO 01", {
    x: .8, y: 2.4, w: 3, h: .3, fontSize: 9, color: B.amber, fontFace: "Arial", bold: true, letterSpacing: 2
  });
  s.addText("Mei, 34 — Real Person", {
    x: .8, y: 2.8, w: 5.4, h: .4, fontSize: 16, color: B.text, fontFace: "Arial", bold: true
  });
  s.addText(
    "Salary deposits shifting. New credit accounts.\nUnusual e-wallet activity. Second device.", {
    x: .8, y: 3.4, w: 5.4, h: .8, fontSize: 11, color: B.muted, fontFace: "Arial", lineSpacingMultiple: 1.4
  });
  s.addText("OLD:", { x: .8, y: 4.5, w: 1, h: .3, fontSize: 10, color: B.muted, fontFace: "Arial", bold: true });
  s.addText('"Legitimate" — Credit score unchanged', { x: 1.8, y: 4.5, w: 4, h: .3, fontSize: 10, color: B.muted, fontFace: "Arial" });
  s.addText("AURA:", { x: .8, y: 4.9, w: 1, h: .3, fontSize: 10, color: B.green, fontFace: "Arial", bold: true });
  s.addText("Early bust-out detected → Saved", { x: 1.8, y: 4.9, w: 4, h: .3, fontSize: 10, color: B.green, fontFace: "Arial" });

  // Scenario 2
  s.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
    x: 6.8, y: 2.2, w: 6, h: 4.5, rectRadius: .12,
    fill: { color: B.surface }, line: { color: B.red, width: .75 }
  });
  s.addText("SCENARIO 02", {
    x: 7.1, y: 2.4, w: 3, h: .3, fontSize: 9, color: B.red, fontFace: "Arial", bold: true, letterSpacing: 2
  });
  s.addText("200 Deepfakes — Synthetic Ring", {
    x: 7.1, y: 2.8, w: 5.4, h: .4, fontSize: 16, color: B.text, fontFace: "Arial", bold: true
  });
  s.addText(
    "200 flawless applications. Collectively:\nidentical micro-cadence, one device cluster.", {
    x: 7.1, y: 3.4, w: 5.4, h: .8, fontSize: 11, color: B.muted, fontFace: "Arial", lineSpacingMultiple: 1.4
  });
  s.addText("RISK FIELD:", { x: 7.1, y: 4.5, w: 2, h: .3, fontSize: 10, color: B.red, fontFace: "Arial", bold: true });
  s.addText("Cluster lit up as reality diverged", { x: 9, y: 4.5, w: 3.5, h: .3, fontSize: 10, color: B.muted, fontFace: "Arial" });
  s.addText("OUTCOME:", { x: 7.1, y: 4.9, w: 2, h: .3, fontSize: 10, color: B.green, fontFace: "Arial", bold: true });
  s.addText("Ring killed at application", { x: 9, y: 4.9, w: 3.5, h: .3, fontSize: 10, color: B.green, fontFace: "Arial" });

  bottomBar(s);
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 7 — WHY NOW
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide();
  darkBg(s);

  s.addText("WHY NOW", {
    x: .8, y: .5, w: 4, h: .3, fontSize: 10, color: B.blue, fontFace: "Arial", bold: true, letterSpacing: 3
  });
  blueUnderline(s, .8, .85, 1.5);

  s.addText("Three forces. One moment.", {
    x: .8, y: 1.2, w: 10, h: .7, fontSize: 32, color: B.text, fontFace: "Arial", bold: true
  });

  const forces = [
    { n: "01", title: "Causal ML tooling", desc: "Production-ready counterfactual tools" },
    { n: "02", title: "Vector DBs", desc: "Real-time embeddings at scale" },
    { n: "03", title: "Regulator openness", desc: "MAS, EBA accept continuous learning" },
  ];
  forces.forEach((f, i) => {
    const x = .8 + i * 4.0;
    s.addText(f.n, { x, y: 2.3, w: 1, h: .5, fontSize: 24, color: B.blue, fontFace: "Arial", bold: true });
    s.addText(f.title, { x: x + 1, y: 2.3, w: 3, h: .3, fontSize: 14, color: B.text, fontFace: "Arial", bold: true });
    s.addText(f.desc, { x: x + 1, y: 2.6, w: 3, h: .3, fontSize: 11, color: B.muted, fontFace: "Arial" });
  });

  // Market metrics
  const metrics = [
    { v: "$12B", l: "TAM", sub: "Growing 14% YoY" },
    { v: "$487B", l: "FRAUD LOSSES", sub: "Global Financial Services" },
    { v: "$84T", l: "WEALTH TRANSFER", sub: "By 2045" },
    { v: "10×", l: "FASTER DEPLOY", sub: "vs siloed MRM" },
  ];
  metrics.forEach((m, i) => {
    const x = .8 + i * 3.1;
    s.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
      x, y: 3.5, w: 2.8, h: 2.5, rectRadius: .1,
      fill: { color: B.surface }, line: { color: B.blue, width: .5 }
    });
    s.addText(m.v, { x, y: 3.7, w: 2.8, h: .6, fontSize: 28, color: B.blue, fontFace: "Arial", bold: true, align: "center" });
    s.addText(m.l, { x, y: 4.3, w: 2.8, h: .3, fontSize: 9, color: B.text, fontFace: "Arial", bold: true, align: "center", letterSpacing: 1 });
    s.addText(m.sub, { x, y: 4.6, w: 2.8, h: .3, fontSize: 9, color: B.muted, fontFace: "Arial", align: "center" });
  });

  bottomBar(s);
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 8 — COMPETITION
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide();
  darkBg(s);

  s.addText("COMPETITIVE LANDSCAPE", {
    x: .8, y: .5, w: 5, h: .3, fontSize: 10, color: B.blue, fontFace: "Arial", bold: true, letterSpacing: 3
  });
  blueUnderline(s, .8, .85, 2);

  s.addText("Where AURA sits.", {
    x: .8, y: 1.2, w: 10, h: .7, fontSize: 32, color: B.text, fontFace: "Arial", bold: true
  });

  // Comparison table
  const hdr = ["", "Featurespace", "Feedzai", "Zest AI", "AURA"].map((t, i) => ({
    text: t, options: { bold: true, color: B.text, fill: { color: i === 4 ? B.blue : B.surface }, fontSize: 10, align: "center" }
  }));
  const data = [
    ["Credit + Fraud unified", "✗", "✗", "Partial", "✓"],
    ["Real-time embeddings", "✗", "✓", "✓", "✓"],
    ["Doppelgänger", "✗", "✗", "✗", "✓"],
    ["Counterfactual RL", "✗", "✗", "✗", "✓"],
    ["Adversarial Arena", "✗", "✗", "✗", "✓"],
    ["Time telescopes", "✗", "✗", "✗", "✓"],
  ].map(r => r.map((c, i) => ({
    text: c, options: {
      fontSize: 10, color: c === "✓" ? B.green : c === "✗" ? B.red : c === "Partial" ? B.amber : B.text,
      align: i === 0 ? "left" : "center", bold: c === "✓" && i === 4
    }
  })));
  s.addTable([hdr, ...data], { x: .5, y: 2.0, w: 12.3, colW: [3.5, 2.2, 2.2, 2.2, 2.2], rowH: [.45, .45, .45, .45, .45, .45, .45], border: { type: "solid", pt: .5, color: B.surface } });

  // Key differentiator
  s.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
    x: .5, y: 5.3, w: 12.3, h: 1.2, rectRadius: .12,
    fill: { color: B.surface }, line: { color: B.green, width: 1.5 }
  });
  s.addText("AURA'S UNIQUE ADVANTAGE", {
    x: .8, y: 5.4, w: 4, h: .25, fontSize: 9, color: B.green, fontFace: "Arial", bold: true, letterSpacing: 2
  });
  s.addText(
    "No existing solution unifies credit and fraud into a single model with personal doppelgängers, counterfactual RL, and an adversarial arena.", {
    x: .8, y: 5.7, w: 11.7, h: .6, fontSize: 12, color: B.text, fontFace: "Arial", lineSpacingMultiple: 1.3
  });

  bottomBar(s);
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 9 — BUSINESS MODEL
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide();
  darkBg(s);

  s.addText("BUSINESS MODEL", {
    x: .8, y: .5, w: 4, h: .3, fontSize: 10, color: B.blue, fontFace: "Arial", bold: true, letterSpacing: 3
  });
  blueUnderline(s, .8, .85, 2);

  s.addText("Aligned economics.", {
    x: .8, y: 1.2, w: 10, h: .7, fontSize: 32, color: B.text, fontFace: "Arial", bold: true
  });
  s.addText("We earn only when your losses fall.", {
    x: .8, y: 1.9, w: 10, h: .3, fontSize: 14, color: B.muted, fontFace: "Arial"
  });

  const tiers = [
    { name: "SHADOW PILOT", price: "Zero cost", sub: "90 days", rec: true, features: ["Single product line", "Divergence baseline", "No production decisions"] },
    { name: "BASE LICENSE", price: "Annual", sub: "Tiered by volume", features: ["Platform access", "Embedding + horizon heads", "Regulatory shadow"] },
    { name: "PERFORMANCE", price: "% of verified", sub: "loss reduction", features: ["Indexed to baseline", "Audited quarterly", "Capped at 3× base fee"] },
  ];
  tiers.forEach((t, i) => {
    const x = .5 + i * 4.2;
    s.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
      x, y: 2.5, w: 3.9, h: 4.0, rectRadius: .12,
      fill: { color: t.rec ? "0A1F1A" : B.surface },
      line: { color: t.rec ? B.green : B.blue, width: t.rec ? 1.5 : .75 }
    });
    if (t.rec) {
      s.addShape(pptx.shapes.ROUNDED_RECTANGLE, { x: x + 1.2, y: 2.3, w: 1.4, h: .3, rectRadius: .15, fill: { color: B.green } });
      s.addText("RECOMMENDED", { x: x + 1.2, y: 2.3, w: 1.4, h: .3, fontSize: 8, color: B.text, fontFace: "Arial", bold: true, align: "center", valign: "middle" });
    }
    s.addText(t.name, { x: x + .3, y: 2.7, w: 3.3, h: .3, fontSize: 11, color: t.rec ? B.green : B.blue, fontFace: "Arial", bold: true, letterSpacing: 2 });
    s.addText(t.price, { x: x + .3, y: 3.1, w: 3.3, h: .4, fontSize: 20, color: B.text, fontFace: "Arial", bold: true });
    s.addText(t.sub, { x: x + .3, y: 3.5, w: 3.3, h: .2, fontSize: 10, color: B.muted, fontFace: "Arial" });
    s.addShape(pptx.shapes.RECTANGLE, { x: x + .3, y: 3.85, w: 3.3, h: .01, fill: { color: B.surface } });
    t.features.forEach((f, j) => {
      s.addText(`•  ${f}`, { x: x + .3, y: 4.0 + j * .4, w: 3.3, h: .35, fontSize: 10, color: B.muted, fontFace: "Arial" });
    });
  });

  bottomBar(s);
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 10 — PROJECTED IMPACT
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide();
  darkBg(s);

  s.addText("PROJECTED IMPACT", {
    x: .8, y: .5, w: 4, h: .3, fontSize: 10, color: B.blue, fontFace: "Arial", bold: true, letterSpacing: 3
  });
  blueUnderline(s, .8, .85, 2);

  s.addText("Three-year P&L impact.", {
    x: .8, y: 1.2, w: 10, h: .7, fontSize: 32, color: B.text, fontFace: "Arial", bold: true
  });
  s.addText("Mid-sized bank · US$50B portfolio · Treated segments only", {
    x: .8, y: 1.9, w: 10, h: .3, fontSize: 11, color: B.muted, fontFace: "Arial"
  });

  // Table
  const hdr = ["", "Year 1", "Year 2", "Year 3"].map((t, i) => ({
    text: t, options: { bold: true, color: B.text, fill: { color: B.surface }, align: i === 0 ? "left" : "center", fontSize: 10 }
  }));
  const data = [
    ["Credit loss reduction", "10%", "17%", "25%", B.green],
    ["Fraud loss reduction", "22%", "35%", "45%", B.blue],
    ["False-positive reduction", "6%", "12%", "20%", B.muted],
    ["P&L impact (US$M)", "$20M", "$45M", "$65M", B.amber],
  ];
  const rows = data.map(r => [
    { text: r[0], options: { bold: true, color: B.text, fontSize: 11 } },
    ...[r[1], r[2], r[3]].map((v, i) => ({
      text: v, options: { color: r[4], align: "center", fontSize: 13, bold: i === 2 }
    })),
  ]);
  s.addTable([hdr, ...rows], { x: .5, y: 2.5, w: 12.3, colW: [4, 2.77, 2.77, 2.77], rowH: [.5, .5, .5, .5, .5], border: { type: "solid", pt: .5, color: B.surface } });

  // Year 3 outcome
  s.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
    x: 2, y: 5.0, w: 9.3, h: 1.2, rectRadius: .12,
    fill: { color: B.surface }, line: { color: B.green, width: 1.5 }
  });
  s.addText("YEAR 3 OUTCOME", {
    x: 2.3, y: 5.1, w: 8.7, h: .3, fontSize: 10, color: B.green, fontFace: "Arial", bold: true, letterSpacing: 2
  });
  s.addText("~US$50–80M annual P&L impact", {
    x: 2.3, y: 5.4, w: 8.7, h: .6, fontSize: 26, color: B.text, fontFace: "Arial", bold: true
  });

  bottomBar(s);
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 11 — ROADMAP
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide();
  darkBg(s);

  s.addText("IMPLEMENTATION ROADMAP", {
    x: .8, y: .5, w: 5, h: .3, fontSize: 10, color: B.blue, fontFace: "Arial", bold: true, letterSpacing: 3
  });
  blueUnderline(s, .8, .85, 2);

  s.addText("36 months. 4 phases.", {
    x: .8, y: 1.2, w: 10, h: .7, fontSize: 32, color: B.text, fontFace: "Arial", bold: true
  });

  // Timeline
  s.addShape(pptx.shapes.RECTANGLE, { x: .5, y: 2.3, w: 12.3, h: .04, fill: { color: B.blue } });

  const phases = [
    { n: "01", title: "Shadow", time: "0–6 mo", gate: "Divergence baseline" },
    { n: "02", title: "Time Telescopes", time: "6–12 mo", gate: "FP reduction ≥ 5%" },
    { n: "03", title: "Loop + Arena", time: "12–24 mo", gate: "Credit loss ↓ ≥ 10%" },
    { n: "04", title: "Genome + Action", time: "24–36 mo", gate: "Full deployment" },
  ];
  phases.forEach((p, i) => {
    const x = .5 + i * 3.15;
    s.addShape(pptx.shapes.OVAL, { x: x + 1.2, y: 2.15, w: .35, h: .35, fill: { color: B.blue } });
    s.addText(p.n, { x: x + 1.2, y: 2.15, w: .35, h: .35, fontSize: 10, color: B.text, fontFace: "Arial", bold: true, align: "center", valign: "middle" });
    s.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
      x, y: 2.7, w: 2.95, h: 3.5, rectRadius: .1,
      fill: { color: B.surface }, line: { color: B.blue, width: .5 }
    });
    s.addText(p.time, { x: x + .15, y: 2.8, w: 2.65, h: .25, fontSize: 9, color: B.blue, fontFace: "Arial", bold: true, letterSpacing: 1 });
    s.addText(p.title, { x: x + .15, y: 3.1, w: 2.65, h: .35, fontSize: 16, color: B.text, fontFace: "Arial", bold: true });
    s.addShape(pptx.shapes.RECTANGLE, { x: x + .15, y: 3.6, w: 2.65, h: .01, fill: { color: B.surface } });
    s.addText("EXIT GATE", { x: x + .15, y: 3.75, w: 2.65, h: .2, fontSize: 8, color: B.green, fontFace: "Arial", bold: true, letterSpacing: 1 });
    s.addText(p.gate, { x: x + .15, y: 4.0, w: 2.65, h: .3, fontSize: 11, color: B.green, fontFace: "Arial", bold: true });
  });

  bottomBar(s);
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 12 — TEAM
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide();
  darkBg(s);

  s.addText("TEAM", {
    x: .8, y: .5, w: 4, h: .3, fontSize: 10, color: B.blue, fontFace: "Arial", bold: true, letterSpacing: 3
  });
  blueUnderline(s, .8, .85, 1);

  s.addText("The team that makes AURA possible.", {
    x: .8, y: 1.2, w: 10, h: .7, fontSize: 32, color: B.text, fontFace: "Arial", bold: true
  });

  const team = [
    { initials: "DK", name: "Darius Kowalski", role: "CEO", desc: "Ex-CRO, DBS Consumer Bank\n18 yrs APAC retail credit" },
    { initials: "RS", name: "Riya Sharma", role: "CTO", desc: "Built fraud ML at Stripe\nFeature stores at 12M QPS" },
    { initials: "NK", name: "Dr. Nikolai Kozlov", role: "CHIEF SCIENTIST", desc: "Doubly-robust paper (JMLR)\nEx-Microsoft Research" },
    { initials: "JL", name: "Jun Li", role: "HEAD OF REG", desc: "Ex-MAS regulator (TRM)\nMAS model-risk notice author" },
  ];
  team.forEach((t, i) => {
    const x = .5 + i * 3.15;
    s.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
      x, y: 2.2, w: 2.95, h: 4.2, rectRadius: .12,
      fill: { color: B.surface }, line: { color: B.blue, width: .75 }
    });
    s.addShape(pptx.shapes.OVAL, { x: x + .85, y: 2.4, w: 1.2, h: 1.2, fill: { color: B.blue } });
    s.addText(t.initials, { x: x + .85, y: 2.4, w: 1.2, h: 1.2, fontSize: 28, color: B.text, fontFace: "Arial", bold: true, align: "center", valign: "middle" });
    s.addText(t.name, { x: x + .15, y: 3.75, w: 2.65, h: .3, fontSize: 13, color: B.text, fontFace: "Arial", bold: true, align: "center" });
    s.addText(t.role, { x: x + .15, y: 4.05, w: 2.65, h: .25, fontSize: 9, color: B.blue, fontFace: "Arial", bold: true, align: "center", letterSpacing: 1 });
    s.addShape(pptx.shapes.RECTANGLE, { x: x + .5, y: 4.4, w: 1.95, h: .01, fill: { color: B.surface } });
    s.addText(t.desc, { x: x + .15, y: 4.55, w: 2.65, h: 1.2, fontSize: 10, color: B.muted, fontFace: "Arial", lineSpacingMultiple: 1.4, align: "center" });
  });

  // Combined experience
  s.addText("Combined: 50+ years in credit risk, fraud ML, causal inference, and MAS regulation", {
    x: .5, y: 6.6, w: 12.3, h: .3, fontSize: 10, color: B.blue, fontFace: "Arial", bold: true, align: "center"
  });

  bottomBar(s);
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 13 — THE ASK
// ═══════════════════════════════════════════════════════════════
{
  const s = pptx.addSlide();
  darkBg(s);

  s.addText("THE ASK", {
    x: .8, y: .5, w: 4, h: .3, fontSize: 10, color: B.blue, fontFace: "Arial", bold: true, letterSpacing: 3
  });
  blueUnderline(s, .8, .85, 1);

  s.addText("90 days. Zero risk.", {
    x: .8, y: 1.2, w: 10, h: .7, fontSize: 36, color: B.text, fontFace: "Arial", bold: true
  });

  const asks = [
    { n: "01", title: "90-day shadow deployment", desc: "Zero licence · Single product line" },
    { n: "02", title: "Executive sponsor", desc: "CRO/CDO level · Convene credit + fraud" },
    { n: "03", title: "3 years historical data", desc: "With outcome labels · Counterfactual training" },
  ];
  asks.forEach((a, i) => {
    const y = 2.3 + i * .9;
    s.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
      x: .5, y, w: 12.3, h: .75, rectRadius: .08,
      fill: { color: B.surface }, line: { color: B.blue, width: .5 }
    });
    s.addShape(pptx.shapes.OVAL, { x: .8, y: y + .12, w: .5, h: .5, fill: { color: B.blue } });
    s.addText(a.n, { x: .8, y: y + .12, w: .5, h: .5, fontSize: 12, color: B.text, fontFace: "Arial", bold: true, align: "center", valign: "middle" });
    s.addText(a.title, { x: 1.5, y: y + .05, w: 5, h: .35, fontSize: 14, color: B.text, fontFace: "Arial", bold: true });
    s.addText(a.desc, { x: 1.5, y: y + .4, w: 10, h: .25, fontSize: 10, color: B.muted, fontFace: "Arial" });
  });

  // Success criteria
  s.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
    x: .5, y: 5.2, w: 12.3, h: 1.2, rectRadius: .12,
    fill: { color: B.surface }, line: { color: B.green, width: 1.5 }
  });
  s.addText("90-DAY SUCCESS CRITERIA", {
    x: .8, y: 5.3, w: 4, h: .25, fontSize: 9, color: B.green, fontFace: "Arial", bold: true, letterSpacing: 2
  });
  const criteria = [
    "Divergence baseline established on 100% of portfolio",
    "False-positive reduction ≥ 5% vs current fraud model",
    "Detection latency < 30 seconds for behavioural shift",
    "AURA catches ≥ 20% more cases than shadow comparison",
  ];
  criteria.forEach((c, i) => {
    s.addText(`✓  ${c}`, {
      x: .8 + (i < 2 ? 0 : 6.2), y: 5.6 + (i % 2) * .35, w: 5.8, h: .3,
      fontSize: 10, color: B.green, fontFace: "Arial"
    });
  });

  // Commitment
  s.addText(
    "If we don't hit these targets, AURA reverts to GXS Bank at no cost.", {
    x: .8, y: 6.5, w: 11.7, h: .4, fontSize: 12, color: B.green, fontFace: "Arial", italic: true, align: "center"
  });

  bottomBar(s);
}

// ═══════════════════════════════════════════════════════════════
// SAVE
// ═══════════════════════════════════════════════════════════════
pptx.writeFile({ fileName: "assets/pdfs/AURA_Pitch_Deck_Dawa_Style.pptx" })
  .then(() => console.log("✅ Created: assets/pdfs/AURA_Pitch_Deck_Dawa_Style.pptx"))
  .catch(err => console.error("❌ Error:", err));
