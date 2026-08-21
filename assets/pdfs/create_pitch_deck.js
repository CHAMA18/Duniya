#!/usr/bin/env node
// ═══════════════════════════════════════════════════════════════
// AURA — World-Class Pitch Deck Generator
// Global Fintech Hackelerator · Singapore · 2026
// Continuum Risk Labs Pte. Ltd.
// ═══════════════════════════════════════════════════════════════

const pptxgen = require("pptxgenjs");

const pptx = new pptxgen();

// ── Brand Constants ──────────────────────────────────────────
const BRAND = {
  primary: "4A0E8F",      // Deep violet
  accent: "7C3AED",       // Vibrant purple
  highlight: "A78BFA",    // Light violet
  dark: "0F0A1A",         // Near-black
  surface: "1A1330",      // Dark surface
  text: "F3F4F6",         // Off-white
  textMuted: "9CA3AF",    // Gray
  success: "10B981",      // Green
  warning: "F59E0B",      // Amber
  error: "EF4444",        // Red
  white: "FFFFFF",
  bg: "0B0614",           // Darkest background
};

pptx.author = "Continuum Risk Labs Pte. Ltd.";
pptx.company = "Continuum Risk Labs";
pptx.subject = "AURA — Adaptive Unified Risk Architecture";
pptx.title = "AURA Pitch Deck — Global Fintech Hackelerator 2026";
pptx.layout = "LAYOUT_WIDE"; // 13.33 x 7.5

// ── Helper: Add consistent footer ────────────────────────────
function addFooter(slide, pageNum, total) {
  slide.addText(`AURA  ·  CONTINUUM RISK LABS`, {
    x: 0.5, y: 7.0, w: 5, h: 0.3,
    fontSize: 8, color: BRAND.textMuted, fontFace: "Arial",
  });
  slide.addText(`${pageNum} / ${total}`, {
    x: 11.5, y: 7.0, w: 1.5, h: 0.3,
    fontSize: 8, color: BRAND.textMuted, fontFace: "Arial", align: "right",
  });
}

// ── Helper: Section divider ──────────────────────────────────
function addSectionTag(slide, label) {
  slide.addShape(pptx.shapes.RECTANGLE, {
    x: 0.5, y: 0.35, w: 0.06, h: 0.35, fill: { color: BRAND.accent },
  });
  slide.addText(label, {
    x: 0.7, y: 0.35, w: 3, h: 0.35,
    fontSize: 10, color: BRAND.highlight, fontFace: "Arial",
    bold: true, letterSpacing: 3,
  });
}

// ── Helper: Metric card ──────────────────────────────────────
function addMetricCard(slide, { x, y, w, h, value, label, sub, color }) {
  slide.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
    x, y, w, h, rectRadius: 0.1,
    fill: { color: BRAND.surface },
    line: { color: BRAND.primary, width: 0.5 },
  });
  slide.addText(value, {
    x, y: y + 0.15, w, h: h * 0.45,
    fontSize: 28, color: color || BRAND.highlight, fontFace: "Arial",
    bold: true, align: "center",
  });
  slide.addText(label, {
    x, y: y + h * 0.5, w, h: h * 0.25,
    fontSize: 10, color: BRAND.text, fontFace: "Arial",
    bold: true, align: "center",
  });
  if (sub) {
    slide.addText(sub, {
      x, y: y + h * 0.72, w, h: h * 0.2,
      fontSize: 8, color: BRAND.textMuted, fontFace: "Arial", align: "center",
    });
  }
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 1 — COVER
// ═══════════════════════════════════════════════════════════════
{
  const slide = pptx.addSlide();
  slide.background = { fill: BRAND.bg };

  // Gradient accent line
  slide.addShape(pptx.shapes.RECTANGLE, {
    x: 0, y: 0, w: 13.33, h: 0.04, fill: { color: BRAND.accent },
  });

  // AURA logotype
  slide.addText("AURA", {
    x: 0.8, y: 0.6, w: 4, h: 0.8,
    fontSize: 44, color: BRAND.accent, fontFace: "Arial",
    bold: true, letterSpacing: 8,
  });

  // Subtitle
  slide.addText("Adaptive Unified Risk Architecture", {
    x: 0.8, y: 1.35, w: 6, h: 0.4,
    fontSize: 16, color: BRAND.highlight, fontFace: "Arial",
  });

  // Hero statement
  slide.addText("One model of you.\nEvery risk you'll ever be.", {
    x: 0.8, y: 2.4, w: 8, h: 1.4,
    fontSize: 36, color: BRAND.text, fontFace: "Arial",
    bold: true, lineSpacingMultiple: 1.2,
  });

  // KPI strip
  const kpis = [
    { value: "20–30%", label: "CREDIT LOSS\nREDUCTION", color: BRAND.success },
    { value: "40–50%", label: "FRAUD LOSS\nREDUCTION", color: BRAND.accent },
    { value: "~$50–80M", label: "ANNUAL P&L\nIMPACT", color: BRAND.warning },
  ];
  kpis.forEach((kpi, i) => {
    const x = 0.8 + i * 3.2;
    slide.addShape(pptx.shapes.RECTANGLE, {
      x, y: 4.3, w: 2.8, h: 0.03, fill: { color: BRAND.accent },
    });
    slide.addText(kpi.value, {
      x, y: 4.5, w: 2.8, h: 0.5,
      fontSize: 24, color: kpi.color, fontFace: "Arial", bold: true,
    });
    slide.addText(kpi.label, {
      x, y: 5.0, w: 2.8, h: 0.5,
      fontSize: 9, color: BRAND.textMuted, fontFace: "Arial",
      letterSpacing: 1,
    });
  });

  // Right side: Big circle accent
  slide.addShape(pptx.shapes.OVAL, {
    x: 9.5, y: 0.5, w: 3.5, h: 3.5,
    fill: { color: BRAND.primary, transparency: 85 },
    line: { color: BRAND.accent, width: 1 },
  });
  slide.addShape(pptx.shapes.OVAL, {
    x: 10.2, y: 1.2, w: 2.1, h: 2.1,
    fill: { color: BRAND.accent, transparency: 80 },
    line: { color: BRAND.highlight, width: 0.5 },
  });

  // Meta info
  slide.addText("SUBMISSION TO GXS BANK  ·  2026", {
    x: 0.8, y: 6.0, w: 5, h: 0.3,
    fontSize: 9, color: BRAND.textMuted, fontFace: "Arial", letterSpacing: 2,
  });
  slide.addText("Continuum Risk Labs Pte. Ltd.", {
    x: 0.8, y: 6.3, w: 5, h: 0.3,
    fontSize: 10, color: BRAND.highlight, fontFace: "Arial",
  });
  slide.addText("Global Fintech Hackelerator · Singapore · August 2026", {
    x: 0.8, y: 6.6, w: 5, h: 0.3,
    fontSize: 9, color: BRAND.textMuted, fontFace: "Arial",
  });

  addFooter(slide, "01", 13);
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 2 — THE PROBLEM
// ═══════════════════════════════════════════════════════════════
{
  const slide = pptx.addSlide();
  slide.background = { fill: BRAND.bg };
  addSectionTag(slide, "01 · PROBLEM");

  slide.addText("Silos that bleed.", {
    x: 0.8, y: 1.0, w: 8, h: 0.7,
    fontSize: 36, color: BRAND.text, fontFace: "Arial", bold: true,
  });

  slide.addText(
    "For 70 years, banking has treated credit risk and fraud risk as two distinct\n" +
    "sciences — different teams, different models, different data.\nThe handoff points between them are precisely where losses compound today.",
    {
      x: 0.8, y: 1.8, w: 7.5, h: 1.0,
      fontSize: 13, color: BRAND.textMuted, fontFace: "Arial",
      lineSpacingMultiple: 1.4,
    }
  );

  // Credit box
  slide.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
    x: 0.8, y: 3.2, w: 5.2, h: 2.8, rectRadius: 0.15,
    fill: { color: BRAND.surface },
    line: { color: BRAND.primary, width: 0.75 },
  });
  slide.addText("CREDIT TEAM", {
    x: 1.0, y: 3.35, w: 4.8, h: 0.4,
    fontSize: 12, color: BRAND.highlight, fontFace: "Arial", bold: true,
    letterSpacing: 2,
  });
  slide.addText('"Can they repay?"', {
    x: 1.0, y: 3.75, w: 4.8, h: 0.35,
    fontSize: 16, color: BRAND.text, fontFace: "Arial", italic: true,
  });
  const creditItems = [
    "Static PD models  ·  Quarterly refresh",
    "12-month horizon  ·  Income / collateral",
    "Population-level statistics",
  ];
  creditItems.forEach((item, i) => {
    slide.addText(`•  ${item}`, {
      x: 1.2, y: 4.2 + i * 0.35, w: 4.6, h: 0.35,
      fontSize: 11, color: BRAND.textMuted, fontFace: "Arial",
    });
  });

  // Fraud box
  slide.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
    x: 6.5, y: 3.2, w: 5.2, h: 2.8, rectRadius: 0.15,
    fill: { color: BRAND.surface },
    line: { color: BRAND.error, width: 0.75 },
  });
  slide.addText("FRAUD TEAM", {
    x: 6.7, y: 3.35, w: 4.8, h: 0.4,
    fontSize: 12, color: BRAND.error, fontFace: "Arial", bold: true,
    letterSpacing: 2,
  });
  slide.addText('"Will they repay?"', {
    x: 6.7, y: 3.75, w: 4.8, h: 0.35,
    fontSize: 16, color: BRAND.text, fontFace: "Arial", italic: true,
  });
  const fraudItems = [
    "Real-time ML  ·  Millisecond refresh",
    "Next-tx horizon  ·  Device / network",
    "Behavioral anomaly detection",
  ];
  fraudItems.forEach((item, i) => {
    slide.addText(`•  ${item}`, {
      x: 6.9, y: 4.2 + i * 0.35, w: 4.6, h: 0.35,
      fontSize: 11, color: BRAND.textMuted, fontFace: "Arial",
    });
  });

  // Blindspot arrow
  slide.addText("BLINDSPOT ↓", {
    x: 5.3, y: 3.0, w: 2.5, h: 0.4,
    fontSize: 11, color: BRAND.error, fontFace: "Arial", bold: true,
    align: "center",
  });

  // Bottom stat
  slide.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
    x: 2.0, y: 6.3, w: 9.3, h: 0.5, rectRadius: 0.08,
    fill: { color: BRAND.surface },
    line: { color: BRAND.error, width: 0.5 },
  });
  slide.addText("~$487B  global annual fraud + credit losses at the seams — and growing", {
    x: 2.0, y: 6.3, w: 9.3, h: 0.5,
    fontSize: 12, color: BRAND.error, fontFace: "Arial", bold: true,
    align: "center",
  });

  addFooter(slide, "02", 13);
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 3 — THE INSIGHT
// ═══════════════════════════════════════════════════════════════
{
  const slide = pptx.addSlide();
  slide.background = { fill: BRAND.bg };
  addSectionTag(slide, "02 · INSIGHT");

  slide.addText("They were never separate.", {
    x: 0.8, y: 1.0, w: 10, h: 0.7,
    fontSize: 36, color: BRAND.text, fontFace: "Arial", bold: true,
  });

  slide.addText(
    "Credit default and fraud are the same phenomenon — the divergence between the\n" +
    "customer you underwrote and the customer revealed by their behaviour —\n" +
    "observed at different time horizons through different sensors.",
    {
      x: 0.8, y: 1.8, w: 10, h: 1.2,
      fontSize: 14, color: BRAND.textMuted, fontFace: "Arial",
      lineSpacingMultiple: 1.4,
    }
  );

  // Reframe table
  const rows = [
    ["TODAY'S LABEL", "WHAT IT ACTUALLY IS", ""],
    ["Credit default", "A fraud that took 18 months to reveal itself", ""],
    ["Bust-out fraud", "A credit default compressed into 30 days", ""],
    ["Application fraud", "A credit model that was lied to at t=0", ""],
    ["Transaction fraud", "A creditworthiness event in 30 seconds", ""],
    ["Strategic default", "A credit customer who became first-party fraud", ""],
  ];

  const tableRows = rows.map((row, i) =>
    row.map((cell, j) => ({
      text: cell,
      options: {
        fontSize: i === 0 ? 10 : 12,
        bold: i === 0,
        color: i === 0 ? BRAND.highlight : BRAND.text,
        fontFace: "Arial",
        fill: { color: i === 0 ? BRAND.primary : (i % 2 === 0 ? "15102A" : BRAND.surface) },
        align: j === 0 ? "left" : "left",
      },
    }))
  );

  slide.addTable(tableRows, {
    x: 0.8, y: 3.3, w: 11.7,
    colW: [3.0, 7.0, 1.7],
    rowH: [0.45, 0.5, 0.5, 0.5, 0.5, 0.5],
    border: { type: "solid", pt: 0.5, color: BRAND.primary },
  });

  // Bottom emphasis
  slide.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
    x: 1.5, y: 6.2, w: 10.3, h: 0.6, rectRadius: 0.08,
    fill: { color: BRAND.primary, transparency: 70 },
    line: { color: BRAND.accent, width: 0.5 },
  });
  slide.addText(
    "The insight: If you observe the SAME person through TWO time telescopes,\nyou catch the divergence before either team sees it alone.",
    {
      x: 1.5, y: 6.2, w: 10.3, h: 0.6,
      fontSize: 11, color: BRAND.highlight, fontFace: "Arial",
      italic: true, align: "center",
    }
  );

  addFooter(slide, "03", 13);
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 4 — THE SOLUTION
// ═══════════════════════════════════════════════════════════════
{
  const slide = pptx.addSlide();
  slide.background = { fill: BRAND.bg };
  addSectionTag(slide, "03 · SOLUTION");

  slide.addText("One model. Two telescopes.\nA living immune system.", {
    x: 0.8, y: 1.0, w: 10, h: 1.0,
    fontSize: 32, color: BRAND.text, fontFace: "Arial", bold: true,
    lineSpacingMultiple: 1.2,
  });

  slide.addText(
    "AURA is the first risk system where the fraud model and the credit model\n" +
    "are the same model — observed through different time telescopes — with an\n" +
    "adversarial Arena that attacks itself 24/7.",
    {
      x: 0.8, y: 2.1, w: 10, h: 0.9,
      fontSize: 13, color: BRAND.textMuted, fontFace: "Arial",
      lineSpacingMultiple: 1.4,
    }
  );

  // Four pillars
  const pillars = [
    { title: "UNIFIED\nEMBEDDING", desc: "One 256-dim latent\nspace per customer.\nAll signals, one vector.", icon: "◆" },
    { title: "PERSONAL\nDOPPELGÄNGER", desc: "Generative twin that\nstreams residuals —\nreality vs expectation.", icon: "◇" },
    { title: "COUNTERFACTUAL\nRL", desc: "What would have\nhappened? Doubly-\nrobust causal replay.", icon: "○" },
    { title: "ADVERSARIAL\nARENA", desc: "Live AI agents attack\nthe system 24/7.\nFraud fights fraud.", icon: "△" },
  ];

  pillars.forEach((p, i) => {
    const x = 0.8 + i * 3.1;
    // Card
    slide.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
      x, y: 3.3, w: 2.8, h: 3.2, rectRadius: 0.12,
      fill: { color: BRAND.surface },
      line: { color: BRAND.primary, width: 0.75 },
    });
    // Number circle
    slide.addShape(pptx.shapes.OVAL, {
      x: x + 0.9, y: 3.5, w: 0.9, h: 0.9,
      fill: { color: BRAND.primary },
    });
    slide.addText(`${i + 1}`, {
      x: x + 0.9, y: 3.5, w: 0.9, h: 0.9,
      fontSize: 24, color: BRAND.white, fontFace: "Arial",
      bold: true, align: "center", valign: "middle",
    });
    // Title
    slide.addText(p.title, {
      x: x + 0.2, y: 4.55, w: 2.4, h: 0.7,
      fontSize: 13, color: BRAND.highlight, fontFace: "Arial",
      bold: true, align: "center", lineSpacingMultiple: 1.1,
    });
    // Description
    slide.addText(p.desc, {
      x: x + 0.2, y: 5.3, w: 2.4, h: 1.0,
      fontSize: 10, color: BRAND.textMuted, fontFace: "Arial",
      align: "center", lineSpacingMultiple: 1.3,
    });
  });

  addFooter(slide, "04", 13);
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 5 — ARCHITECTURE
// ═══════════════════════════════════════════════════════════════
{
  const slide = pptx.addSlide();
  slide.background = { fill: BRAND.bg };
  addSectionTag(slide, "04 · ARCHITECTURE");

  slide.addText("Eight tightly-coupled layers.", {
    x: 0.8, y: 1.0, w: 8, h: 0.6,
    fontSize: 32, color: BRAND.text, fontFace: "Arial", bold: true,
  });

  const layers = [
    { num: "1", name: "Unified Risk Embedding", desc: "256-dim global latent space", tag: "SPINE" },
    { num: "2", name: "Personal Doppelgänger", desc: "Per-customer generative twin · residual streamer", tag: "SPINE" },
    { num: "3", name: "Twin Strands", desc: "Two decoupled readouts: Capacity × Intent", tag: "SPINE" },
    { num: "4", name: "Time-Telescope Heads", desc: "spike (sec) / shift (days) / drift (months)", tag: "SPINE" },
    { num: "5", name: "Counterfactual Replay Loop", desc: "Doubly-robust causal estimation on decisions", tag: "SPINE" },
    { num: "6", name: "The Arena", desc: "Adversarial agents attack live system in shadow", tag: "IMMUNE" },
    { num: "7", name: "Risk Field", desc: "Graph contagion across devices, merchants, geographies", tag: "IMMUNE" },
    { num: "8", name: "Action Layer", desc: "nudge → friction → reprice → interdict", tag: "IMMUNE" },
  ];

  layers.forEach((l, i) => {
    const y = 1.85 + i * 0.62;
    const isImmune = l.tag === "IMMUNE";

    // Row background
    slide.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
      x: 0.8, y, w: 11.7, h: 0.52, rectRadius: 0.06,
      fill: { color: isImmune ? "1C0F2E" : "15102A" },
      line: { color: isImmune ? BRAND.accent : BRAND.primary, width: 0.5 },
    });

    // Number
    slide.addShape(pptx.shapes.OVAL, {
      x: 1.0, y: y + 0.06, w: 0.4, h: 0.4,
      fill: { color: isImmune ? BRAND.accent : BRAND.primary },
    });
    slide.addText(l.num, {
      x: 1.0, y: y + 0.06, w: 0.4, h: 0.4,
      fontSize: 11, color: BRAND.white, fontFace: "Arial",
      bold: true, align: "center", valign: "middle",
    });

    // Name
    slide.addText(l.name, {
      x: 1.6, y, w: 3.5, h: 0.52,
      fontSize: 12, color: BRAND.text, fontFace: "Arial", bold: true,
      valign: "middle",
    });

    // Description
    slide.addText(l.desc, {
      x: 5.3, y, w: 5.5, h: 0.52,
      fontSize: 10, color: BRAND.textMuted, fontFace: "Arial",
      valign: "middle",
    });

    // Tag
    slide.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
      x: 11.2, y: y + 0.12, w: 1.1, h: 0.28, rectRadius: 0.14,
      fill: { color: isImmune ? BRAND.accent : BRAND.primary, transparency: 50 },
    });
    slide.addText(l.tag, {
      x: 11.2, y: y + 0.12, w: 1.1, h: 0.28,
      fontSize: 7, color: BRAND.highlight, fontFace: "Arial",
      bold: true, align: "center", valign: "middle", letterSpacing: 1,
    });
  });

  // Legend
  slide.addText("Layers 1–5 = Risk Continuum Spine", {
    x: 0.8, y: 6.85, w: 5, h: 0.3,
    fontSize: 9, color: BRAND.highlight, fontFace: "Arial",
  });
  slide.addText("Layers 6–8 = Adaptive Immune System", {
    x: 6.0, y: 6.85, w: 5, h: 0.3,
    fontSize: 9, color: BRAND.accent, fontFace: "Arial",
  });

  addFooter(slide, "05", 13);
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 6 — THE BREAKTHROUGH
// ═══════════════════════════════════════════════════════════════
{
  const slide = pptx.addSlide();
  slide.background = { fill: BRAND.bg };
  addSectionTag(slide, "05 · BREAKTHROUGH");

  slide.addText("Doppelgänger + Arena", {
    x: 0.8, y: 1.0, w: 10, h: 0.6,
    fontSize: 32, color: BRAND.text, fontFace: "Arial", bold: true,
  });

  // Left card: Doppelgänger
  slide.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
    x: 0.8, y: 1.9, w: 5.8, h: 4.8, rectRadius: 0.15,
    fill: { color: BRAND.surface },
    line: { color: BRAND.accent, width: 1 },
  });
  slide.addText("LAYER 02", {
    x: 1.1, y: 2.1, w: 2, h: 0.3,
    fontSize: 9, color: BRAND.highlight, fontFace: "Arial", bold: true, letterSpacing: 2,
  });
  slide.addText("Personal Doppelgänger", {
    x: 1.1, y: 2.4, w: 5.2, h: 0.45,
    fontSize: 20, color: BRAND.text, fontFace: "Arial", bold: true,
  });
  slide.addText(
    "A self-supervised generative twin per customer. Continuously predicts " +
    "their next state and streams the residuals — where reality diverges from expectation.",
    {
      x: 1.1, y: 2.95, w: 5.2, h: 0.8,
      fontSize: 12, color: BRAND.textMuted, fontFace: "Arial", lineSpacingMultiple: 1.3,
    }
  );

  slide.addShape(pptx.shapes.RECTANGLE, {
    x: 1.1, y: 3.85, w: 5.2, h: 0.02, fill: { color: BRAND.primary },
  });

  slide.addText("TRAINING DATA:", {
    x: 1.1, y: 4.0, w: 5.2, h: 0.3,
    fontSize: 10, color: BRAND.highlight, fontFace: "Arial", bold: true,
  });
  slide.addText(
    "The 99% of behavioural signal both silos throw away.",
    {
      x: 1.1, y: 4.3, w: 5.2, h: 0.3,
      fontSize: 11, color: BRAND.text, fontFace: "Arial", italic: true,
    }
  );

  slide.addText("WHY IT WINS:", {
    x: 1.1, y: 4.8, w: 5.2, h: 0.3,
    fontSize: 10, color: BRAND.highlight, fontFace: "Arial", bold: true,
  });
  slide.addText(
    "Detects change vs the customer's own past, not the population. " +
    "Strictly more sensitive for bust-out, where the identity is real but the behaviour has shifted.",
    {
      x: 1.1, y: 5.1, w: 5.2, h: 0.6,
      fontSize: 11, color: BRAND.textMuted, fontFace: "Arial", lineSpacingMultiple: 1.3,
    }
  );

  // Right card: Arena
  slide.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
    x: 6.9, y: 1.9, w: 5.8, h: 4.8, rectRadius: 0.15,
    fill: { color: BRAND.surface },
    line: { color: BRAND.error, width: 1 },
  });
  slide.addText("LAYER 06", {
    x: 7.2, y: 2.1, w: 2, h: 0.3,
    fontSize: 9, color: BRAND.error, fontFace: "Arial", bold: true, letterSpacing: 2,
  });
  slide.addText("The Arena", {
    x: 7.2, y: 2.4, w: 5.2, h: 0.45,
    fontSize: 20, color: BRAND.text, fontFace: "Arial", bold: true,
  });
  slide.addText(
    "Continuously running adversarial agents — synthetic fraud rings, deepfake " +
    "applicants, AI-built bust-out personas — attack the live system in a shadow environment.",
    {
      x: 7.2, y: 2.95, w: 5.2, h: 0.8,
      fontSize: 12, color: BRAND.textMuted, fontFace: "Arial", lineSpacingMultiple: 1.3,
    }
  );

  slide.addShape(pptx.shapes.RECTANGLE, {
    x: 7.2, y: 3.85, w: 5.2, h: 0.02, fill: { color: BRAND.error },
  });

  slide.addText("WHAT 'ADAPTIVE' MEANS:", {
    x: 7.2, y: 4.0, w: 5.2, h: 0.3,
    fontSize: 10, color: BRAND.error, fontFace: "Arial", bold: true,
  });
  slide.addText(
    "Not quarterly retraining — a live immune response.",
    {
      x: 7.2, y: 4.3, w: 5.2, h: 0.3,
      fontSize: 11, color: BRAND.text, fontFace: "Arial", italic: true,
    }
  );

  slide.addText("WHY NOW:", {
    x: 7.2, y: 4.8, w: 5.2, h: 0.3,
    fontSize: 10, color: BRAND.error, fontFace: "Arial", bold: true,
  });
  slide.addText(
    "Fraudsters now use generative AI. You cannot fight generative with static — " +
    "only generative with generative.",
    {
      x: 7.2, y: 5.1, w: 5.2, h: 0.6,
      fontSize: 11, color: BRAND.textMuted, fontFace: "Arial", lineSpacingMultiple: 1.3,
    }
  );

  addFooter(slide, "06", 13);
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 7 — WHY NOW
// ═══════════════════════════════════════════════════════════════
{
  const slide = pptx.addSlide();
  slide.background = { fill: BRAND.bg };
  addSectionTag(slide, "06 · WHY NOW");

  slide.addText("Three forces converge in 2026.", {
    x: 0.8, y: 1.0, w: 10, h: 0.6,
    fontSize: 32, color: BRAND.text, fontFace: "Arial", bold: true,
  });

  const forces = [
    {
      num: "01",
      title: "Causal ML tooling",
      desc: "EconML, DoWhy, doubly-robust estimators make counterfactual training operationalisable at production scale.",
    },
    {
      num: "02",
      title: "Vector DBs + sequence models",
      desc: "256-dim real-time updates and millions of live generative twins are now computationally feasible.",
    },
    {
      num: "03",
      title: "Regulator openness",
      desc: "MAS, EBA, OCC signal acceptance of continuously-learning models, provided a frozen shadow is maintained for audit.",
    },
  ];

  forces.forEach((f, i) => {
    const x = 0.8 + i * 4.1;
    slide.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
      x, y: 2.0, w: 3.8, h: 2.8, rectRadius: 0.12,
      fill: { color: BRAND.surface },
      line: { color: BRAND.primary, width: 0.75 },
    });
    slide.addText(f.num, {
      x: x + 0.2, y: 2.15, w: 0.6, h: 0.4,
      fontSize: 22, color: BRAND.accent, fontFace: "Arial", bold: true,
    });
    slide.addText(f.title, {
      x: x + 0.2, y: 2.6, w: 3.4, h: 0.4,
      fontSize: 15, color: BRAND.text, fontFace: "Arial", bold: true,
    });
    slide.addText(f.desc, {
      x: x + 0.2, y: 3.1, w: 3.4, h: 1.4,
      fontSize: 11, color: BRAND.textMuted, fontFace: "Arial",
      lineSpacingMultiple: 1.4,
    });
  });

  // Market metrics
  const metrics = [
    { value: "$12B", label: "TAM · ANNUAL\nSOFTWARE SPEND", sub: "Growing 14% YoY" },
    { value: "$487B", label: "ANNUAL\nFRAUD LOSSES", sub: "Global Financial Services" },
    { value: "$84T", label: "WEALTH\nTRANSFER BY 2045", sub: "Digital-native HNW" },
    { value: "10×", label: "FASTER MODEL\nDEPLOYMENT", sub: "vs siloed MRM" },
  ];

  metrics.forEach((m, i) => {
    const x = 0.8 + i * 3.1;
    slide.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
      x, y: 5.2, w: 2.8, h: 1.5, rectRadius: 0.1,
      fill: { color: BRAND.surface },
      line: { color: BRAND.primary, width: 0.5 },
    });
    slide.addText(m.value, {
      x, y: 5.3, w: 2.8, h: 0.6,
      fontSize: 22, color: BRAND.highlight, fontFace: "Arial", bold: true, align: "center",
    });
    slide.addText(m.label, {
      x, y: 5.85, w: 2.8, h: 0.4,
      fontSize: 8, color: BRAND.text, fontFace: "Arial", bold: true, align: "center",
      letterSpacing: 1,
    });
    slide.addText(m.sub, {
      x, y: 6.25, w: 2.8, h: 0.3,
      fontSize: 8, color: BRAND.textMuted, fontFace: "Arial", align: "center",
    });
  });

  addFooter(slide, "07", 13);
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 8 — SEE IT WORK
// ═══════════════════════════════════════════════════════════════
{
  const slide = pptx.addSlide();
  slide.background = { fill: BRAND.bg };
  addSectionTag(slide, "07 · SEE IT WORK");

  slide.addText("Two scenarios, one engine.", {
    x: 0.8, y: 1.0, w: 10, h: 0.6,
    fontSize: 32, color: BRAND.text, fontFace: "Arial", bold: true,
  });

  // Scenario 1
  slide.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
    x: 0.8, y: 1.85, w: 5.8, h: 3.2, rectRadius: 0.12,
    fill: { color: BRAND.surface },
    line: { color: BRAND.warning, width: 0.75 },
  });
  slide.addText("SCENARIO 01", {
    x: 1.1, y: 2.0, w: 2, h: 0.3,
    fontSize: 9, color: BRAND.warning, fontFace: "Arial", bold: true, letterSpacing: 2,
  });
  slide.addText("Mei, 34 — real person, real documents", {
    x: 1.1, y: 2.3, w: 5.2, h: 0.35,
    fontSize: 15, color: BRAND.text, fontFace: "Arial", bold: true,
  });
  slide.addText(
    "Her doppelgänger detects: salary deposits landing later each month, " +
    "three new digital credit accounts, top-ups to an unfamiliar e-wallet cluster, " +
    "2 a.m. sessions from a second device.",
    {
      x: 1.1, y: 2.75, w: 5.2, h: 0.8,
      fontSize: 11, color: BRAND.textMuted, fontFace: "Arial", lineSpacingMultiple: 1.3,
    }
  );

  slide.addText("OLD WORLD:", {
    x: 1.1, y: 3.6, w: 5.2, h: 0.25,
    fontSize: 9, color: BRAND.textMuted, fontFace: "Arial", bold: true,
  });
  slide.addText(
    'Fraud model says "legitimate". Credit score hasn\'t caught up.',
    {
      x: 1.1, y: 3.85, w: 5.2, h: 0.3,
      fontSize: 10, color: BRAND.textMuted, fontFace: "Arial", italic: true,
    }
  );

  slide.addText("AURA:", {
    x: 1.1, y: 4.2, w: 5.2, h: 0.25,
    fontSize: 9, color: BRAND.success, fontFace: "Arial", bold: true,
  });
  slide.addText(
    "Medium-scale shift + intent manifold = early bust-out transition. " +
    "Action: consolidation offer + limit adjustment. Loss prevented, customer saved.",
    {
      x: 1.1, y: 4.45, w: 5.2, h: 0.45,
      fontSize: 10, color: BRAND.success, fontFace: "Arial",
    }
  );

  // Scenario 2
  slide.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
    x: 6.9, y: 1.85, w: 5.8, h: 3.2, rectRadius: 0.12,
    fill: { color: BRAND.surface },
    line: { color: BRAND.error, width: 0.75 },
  });
  slide.addText("SCENARIO 02", {
    x: 7.2, y: 2.0, w: 2, h: 0.3,
    fontSize: 9, color: BRAND.error, fontFace: "Arial", bold: true, letterSpacing: 2,
  });
  slide.addText("Synthetic identity ring — 200 flawless deepfakes", {
    x: 7.2, y: 2.3, w: 5.2, h: 0.35,
    fontSize: 15, color: BRAND.text, fontFace: "Arial", bold: true,
  });
  slide.addText(
    "200 applications filed. Individually pristine. Collectively: all 200 doppelgängers " +
    "share one residual signature — identical application micro-cadence, one device cluster, " +
    "synchronised behaviour templates.",
    {
      x: 7.2, y: 2.75, w: 5.2, h: 0.8,
      fontSize: 11, color: BRAND.textMuted, fontFace: "Arial", lineSpacingMultiple: 1.3,
    }
  );

  slide.addText("RISK FIELD:", {
    x: 7.2, y: 3.6, w: 5.2, h: 0.25,
    fontSize: 9, color: BRAND.error, fontFace: "Arial", bold: true,
  });
  slide.addText(
    "Lights up as a cluster diverging from reality at once.",
    {
      x: 7.2, y: 3.85, w: 5.2, h: 0.3,
      fontSize: 10, color: BRAND.error, fontFace: "Arial",
    }
  );

  slide.addText("OUTCOME:", {
    x: 7.2, y: 4.2, w: 5.2, h: 0.25,
    fontSize: 9, color: BRAND.success, fontFace: "Arial", bold: true,
  });
  slide.addText(
    "Ring killed at application — not at first missed payment.",
    {
      x: 7.2, y: 4.45, w: 5.2, h: 0.3,
      fontSize: 10, color: BRAND.success, fontFace: "Arial",
    }
  );

  // GXS-specific box
  slide.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
    x: 0.8, y: 5.3, w: 11.7, h: 1.4, rectRadius: 0.12,
    fill: { color: "0F1A2E" },
    line: { color: BRAND.accent, width: 0.75 },
  });
  slide.addText("WHY GXS SPECIFICALLY", {
    x: 1.1, y: 5.4, w: 4, h: 0.3,
    fontSize: 10, color: BRAND.highlight, fontFace: "Arial", bold: true, letterSpacing: 2,
  });
  slide.addText(
    "GXS serves the thin-file customers the bureau can't price — gig workers, young earners, " +
    "the underbanked. When there's no credit history, behaviour is the only signal, and AURA " +
    "is a behaviour-first engine. GXS's digital-native data exhaust is exactly the fuel this " +
    "system needs. This isn't a bolt-on; it's GXS's structural advantage weaponised.",
    {
      x: 1.1, y: 5.75, w: 11.1, h: 0.8,
      fontSize: 11, color: BRAND.textMuted, fontFace: "Arial", lineSpacingMultiple: 1.3,
    }
  );

  addFooter(slide, "08", 13);
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 9 — BUSINESS MODEL
// ═══════════════════════════════════════════════════════════════
{
  const slide = pptx.addSlide();
  slide.background = { fill: BRAND.bg };
  addSectionTag(slide, "08 · BUSINESS MODEL");

  slide.addText("Aligned economics.", {
    x: 0.8, y: 1.0, w: 10, h: 0.6,
    fontSize: 32, color: BRAND.text, fontFace: "Arial", bold: true,
  });

  slide.addText(
    "We earn meaningfully only when GXS Bank's losses demonstrably fall.\n" +
    "The first 90 days are at zero licence cost.",
    {
      x: 0.8, y: 1.7, w: 10, h: 0.7,
      fontSize: 13, color: BRAND.textMuted, fontFace: "Arial",
      lineSpacingMultiple: 1.4,
    }
  );

  // Three-tier pricing
  const tiers = [
    {
      name: "SHADOW PILOT",
      highlight: true,
      price: "Zero cost",
      duration: "90 days",
      features: [
        "Single product line",
        "Divergence baseline",
        "No production decisions",
        "Proof before commitment",
      ],
    },
    {
      name: "BASE LICENSE",
      highlight: false,
      price: "Annual · Tiered",
      duration: "by volume",
      features: [
        "Platform access",
        "Embedding + horizon heads",
        "Regulatory shadow",
        "Standard MRM support",
      ],
    },
    {
      name: "PERFORMANCE",
      highlight: false,
      price: "% of verified loss",
      duration: "reduction",
      features: [
        "Indexed to baseline",
        "Audited quarterly",
        "Aligns our P&L with yours",
        "Capped at 3× base fee",
      ],
    },
  ];

  tiers.forEach((t, i) => {
    const x = 0.8 + i * 4.1;
    const lineColor = t.highlight ? BRAND.success : BRAND.primary;
    slide.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
      x, y: 2.8, w: 3.8, h: 3.8, rectRadius: 0.12,
      fill: { color: t.highlight ? "0A1F1A" : BRAND.surface },
      line: { color: lineColor, width: t.highlight ? 1.5 : 0.75 },
    });

    if (t.highlight) {
      slide.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
        x: x + 1.2, y: 2.6, w: 1.4, h: 0.3, rectRadius: 0.15,
        fill: { color: BRAND.success },
      });
      slide.addText("RECOMMENDED", {
        x: x + 1.2, y: 2.6, w: 1.4, h: 0.3,
        fontSize: 7, color: BRAND.white, fontFace: "Arial", bold: true,
        align: "center", valign: "middle", letterSpacing: 1,
      });
    }

    slide.addText(t.name, {
      x: x + 0.3, y: 3.0, w: 3.2, h: 0.35,
      fontSize: 13, color: t.highlight ? BRAND.success : BRAND.highlight,
      fontFace: "Arial", bold: true, letterSpacing: 2,
    });

    slide.addText(t.price, {
      x: x + 0.3, y: 3.4, w: 3.2, h: 0.4,
      fontSize: 18, color: BRAND.text, fontFace: "Arial", bold: true,
    });
    slide.addText(t.duration, {
      x: x + 0.3, y: 3.8, w: 3.2, h: 0.25,
      fontSize: 10, color: BRAND.textMuted, fontFace: "Arial",
    });

    slide.addShape(pptx.shapes.RECTANGLE, {
      x: x + 0.3, y: 4.2, w: 3.2, h: 0.01, fill: { color: BRAND.primary },
    });

    t.features.forEach((f, j) => {
      slide.addText(`•  ${f}`, {
        x: x + 0.3, y: 4.35 + j * 0.4, w: 3.2, h: 0.35,
        fontSize: 11, color: BRAND.textMuted, fontFace: "Arial",
      });
    });
  });

  addFooter(slide, "09", 13);
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 10 — PROJECTED IMPACT
// ═══════════════════════════════════════════════════════════════
{
  const slide = pptx.addSlide();
  slide.background = { fill: BRAND.bg };
  addSectionTag(slide, "09 · IMPACT");

  slide.addText("Projected impact.", {
    x: 0.8, y: 1.0, w: 10, h: 0.6,
    fontSize: 32, color: BRAND.text, fontFace: "Arial", bold: true,
  });

  slide.addText(
    "Three-year P&L impact  ·  Mid-sized bank  ·  US$50B portfolio  ·  Treated segments only",
    {
      x: 0.8, y: 1.65, w: 10, h: 0.35,
      fontSize: 11, color: BRAND.textMuted, fontFace: "Arial",
    }
  );

  // Impact table
  const impactRows = [
    [
      { text: "", options: { fill: { color: BRAND.primary } } },
      { text: "Y1", options: { bold: true, color: BRAND.white, fill: { color: BRAND.primary }, align: "center" } },
      { text: "Y2", options: { bold: true, color: BRAND.white, fill: { color: BRAND.primary }, align: "center" } },
      { text: "Y3", options: { bold: true, color: BRAND.white, fill: { color: BRAND.primary }, align: "center" } },
    ],
    [
      { text: "Credit loss reduction", options: { bold: true, color: BRAND.text } },
      { text: "10%", options: { color: BRAND.success, align: "center" } },
      { text: "17%", options: { color: BRAND.success, align: "center" } },
      { text: "25%", options: { color: BRAND.success, align: "center", bold: true } },
    ],
    [
      { text: "Fraud loss reduction", options: { bold: true, color: BRAND.text } },
      { text: "22%", options: { color: BRAND.accent, align: "center" } },
      { text: "35%", options: { color: BRAND.accent, align: "center" } },
      { text: "45%", options: { color: BRAND.accent, align: "center", bold: true } },
    ],
    [
      { text: "False-positive reduction", options: { bold: true, color: BRAND.text } },
      { text: "6%", options: { color: BRAND.highlight, align: "center" } },
      { text: "12%", options: { color: BRAND.highlight, align: "center" } },
      { text: "20%", options: { color: BRAND.highlight, align: "center", bold: true } },
    ],
    [
      { text: "P&L impact (US$M)", options: { bold: true, color: BRAND.text } },
      { text: "$20M", options: { color: BRAND.warning, align: "center", bold: true } },
      { text: "$45M", options: { color: BRAND.warning, align: "center", bold: true } },
      { text: "$65M", options: { color: BRAND.warning, align: "center", bold: true } },
    ],
  ];

  slide.addTable(impactRows, {
    x: 0.8, y: 2.3, w: 11.7,
    colW: [4.0, 2.57, 2.57, 2.57],
    rowH: [0.5, 0.55, 0.55, 0.55, 0.55],
    border: { type: "solid", pt: 0.5, color: BRAND.primary },
  });

  // Year 3 outcome callout
  slide.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
    x: 2.0, y: 5.2, w: 9.3, h: 1.2, rectRadius: 0.15,
    fill: { color: "0F1A0F" },
    line: { color: BRAND.success, width: 1.5 },
  });
  slide.addText("YEAR 3 OUTCOME", {
    x: 2.3, y: 5.3, w: 8.7, h: 0.35,
    fontSize: 10, color: BRAND.success, fontFace: "Arial", bold: true, letterSpacing: 2,
  });
  slide.addText("~US$50–80M annual P&L impact", {
    x: 2.3, y: 5.65, w: 8.7, h: 0.55,
    fontSize: 24, color: BRAND.text, fontFace: "Arial", bold: true,
  });

  addFooter(slide, "10", 13);
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 11 — IMPLEMENTATION ROADMAP
// ═══════════════════════════════════════════════════════════════
{
  const slide = pptx.addSlide();
  slide.background = { fill: BRAND.bg };
  addSectionTag(slide, "10 · ROADMAP");

  slide.addText("36 months. 4 phases. 1 gate per phase.", {
    x: 0.8, y: 1.0, w: 10, h: 0.6,
    fontSize: 30, color: BRAND.text, fontFace: "Arial", bold: true,
  });

  const phases = [
    {
      num: "01",
      title: "Shadow",
      time: "0–6 mo",
      desc: "Build embedding + doppelgängers on existing features. Run as shadow. Measure divergence.",
      gate: "EXIT: Divergence baseline established",
      color: BRAND.highlight,
    },
    {
      num: "02",
      title: "Time Telescopes",
      time: "6–12 mo",
      desc: "Deploy horizon heads. Live decisions on next-tx + 30-day heads in low-risk segments.",
      gate: "EXIT: FP reduction ≥ 5%",
      color: BRAND.accent,
    },
    {
      num: "03",
      title: "Loop + Arena",
      time: "12–24 mo",
      desc: "Counterfactual replay loop + Arena live. Train on interventions and adversarial exploits.",
      gate: "EXIT: Credit loss ↓ ≥ 10%",
      color: BRAND.warning,
    },
    {
      num: "04",
      title: "Genome + Action",
      time: "24–36 mo",
      desc: "Risk Field primary substrate. Action Layer live. Migrate shadow to graph-explainable.",
      gate: "EXIT: Full deployment · MRM sign-off",
      color: BRAND.success,
    },
  ];

  // Timeline line
  slide.addShape(pptx.shapes.RECTANGLE, {
    x: 0.8, y: 2.7, w: 11.7, h: 0.04, fill: { color: BRAND.primary },
  });

  phases.forEach((p, i) => {
    const x = 0.8 + i * 3.1;
    // Timeline dot
    slide.addShape(pptx.shapes.OVAL, {
      x: x + 1.15, y: 2.55, w: 0.35, h: 0.35,
      fill: { color: p.color },
    });
    slide.addText(p.num, {
      x: x + 1.15, y: 2.55, w: 0.35, h: 0.35,
      fontSize: 10, color: BRAND.white, fontFace: "Arial",
      bold: true, align: "center", valign: "middle",
    });

    // Phase card
    slide.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
      x, y: 3.15, w: 2.85, h: 3.4, rectRadius: 0.1,
      fill: { color: BRAND.surface },
      line: { color: p.color, width: 0.75 },
    });

    slide.addText(`${p.time}`, {
      x: x + 0.15, y: 3.25, w: 2.55, h: 0.25,
      fontSize: 9, color: p.color, fontFace: "Arial", bold: true, letterSpacing: 1,
    });
    slide.addText(p.title, {
      x: x + 0.15, y: 3.5, w: 2.55, h: 0.35,
      fontSize: 16, color: BRAND.text, fontFace: "Arial", bold: true,
    });
    slide.addText(p.desc, {
      x: x + 0.15, y: 3.95, w: 2.55, h: 1.2,
      fontSize: 10, color: BRAND.textMuted, fontFace: "Arial", lineSpacingMultiple: 1.3,
    });

    // Exit criterion
    slide.addShape(pptx.shapes.RECTANGLE, {
      x: x + 0.15, y: 5.5, w: 2.55, h: 0.01, fill: { color: p.color, transparency: 50 },
    });
    slide.addText(p.gate, {
      x: x + 0.15, y: 5.6, w: 2.55, h: 0.5,
      fontSize: 8, color: p.color, fontFace: "Arial", bold: true,
      lineSpacingMultiple: 1.3,
    });
  });

  addFooter(slide, "11", 13);
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 12 — TEAM
// ═══════════════════════════════════════════════════════════════
{
  const slide = pptx.addSlide();
  slide.background = { fill: BRAND.bg };
  addSectionTag(slide, "11 · TEAM");

  slide.addText("The intersection that makes AURA possible.", {
    x: 0.8, y: 1.0, w: 10, h: 0.6,
    fontSize: 30, color: BRAND.text, fontFace: "Arial", bold: true,
  });

  const team = [
    {
      initials: "MC",
      name: "Dr. Maya Chen",
      role: "CEO",
      desc: "Ex-CRO, DBS Consumer Bank. 18 yrs APAC retail credit. Led DBS model-risk transformation (2019–23).",
    },
    {
      initials: "AP",
      name: "Arjun Patel",
      role: "CTO",
      desc: "Built fraud ML at Stripe & Paytm. Architected feature stores at 12M QPS. Stanford CS PhD candidate.",
    },
    {
      initials: "LP",
      name: "Dr. Lena Petrova",
      role: "CHIEF SCIENTIST",
      desc: "Co-author, foundational doubly-robust counterfactual estimation paper (JMLR 2021). Ex-Microsoft Research NYC.",
    },
    {
      initials: "MT",
      name: "Marcus Tan",
      role: "HEAD OF REG ENGINEERING",
      desc: "Ex-MAS regulator (TRM). Authored portions of the MAS model-risk notice. Ensures AURA ships audit-ready.",
    },
  ];

  team.forEach((t, i) => {
    const x = 0.8 + i * 3.1;
    slide.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
      x, y: 2.0, w: 2.85, h: 4.2, rectRadius: 0.12,
      fill: { color: BRAND.surface },
      line: { color: BRAND.primary, width: 0.75 },
    });

    // Avatar circle
    slide.addShape(pptx.shapes.OVAL, {
      x: x + 0.85, y: 2.2, w: 1.15, h: 1.15,
      fill: { color: BRAND.primary },
    });
    slide.addText(t.initials, {
      x: x + 0.85, y: 2.2, w: 1.15, h: 1.15,
      fontSize: 24, color: BRAND.white, fontFace: "Arial",
      bold: true, align: "center", valign: "middle",
    });

    slide.addText(t.name, {
      x: x + 0.2, y: 3.5, w: 2.45, h: 0.35,
      fontSize: 14, color: BRAND.text, fontFace: "Arial", bold: true,
      align: "center",
    });
    slide.addText(t.role, {
      x: x + 0.2, y: 3.85, w: 2.45, h: 0.25,
      fontSize: 9, color: BRAND.highlight, fontFace: "Arial",
      bold: true, align: "center", letterSpacing: 1,
    });

    slide.addShape(pptx.shapes.RECTANGLE, {
      x: x + 0.6, y: 4.25, w: 1.65, h: 0.01, fill: { color: BRAND.primary },
    });

    slide.addText(t.desc, {
      x: x + 0.2, y: 4.4, w: 2.45, h: 1.5,
      fontSize: 10, color: BRAND.textMuted, fontFace: "Arial",
      align: "center", lineSpacingMultiple: 1.4,
    });
  });

  slide.addText("NOTE  Names shown are placeholders — replace with actual founders prior to submission.", {
    x: 0.8, y: 6.5, w: 11.7, h: 0.3,
    fontSize: 9, color: BRAND.warning, fontFace: "Arial", italic: true,
  });

  addFooter(slide, "12", 13);
}

// ═══════════════════════════════════════════════════════════════
// SLIDE 13 — THE ASK
// ═══════════════════════════════════════════════════════════════
{
  const slide = pptx.addSlide();
  slide.background = { fill: BRAND.bg };
  addSectionTag(slide, "12 · THE ASK");

  slide.addText("Ninety days. Zero risk.", {
    x: 0.8, y: 1.0, w: 10, h: 0.7,
    fontSize: 36, color: BRAND.text, fontFace: "Arial", bold: true,
  });

  // Three asks
  const asks = [
    {
      num: "01",
      title: "90-day shadow deployment",
      desc: "Zero licence · single product line · establish divergence baseline",
    },
    {
      num: "02",
      title: "Executive sponsor",
      desc: "CRO or CDO level · convene credit, fraud, model-risk functions",
    },
    {
      num: "03",
      title: "3 years of historical decision data",
      desc: "With outcome labels · counterfactual training begins on day one",
    },
  ];

  asks.forEach((a, i) => {
    const y = 2.2 + i * 1.1;
    slide.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
      x: 0.8, y, w: 11.7, h: 0.9, rectRadius: 0.1,
      fill: { color: BRAND.surface },
      line: { color: BRAND.primary, width: 0.5 },
    });

    // Number badge
    slide.addShape(pptx.shapes.OVAL, {
      x: 1.1, y: y + 0.2, w: 0.5, h: 0.5,
      fill: { color: BRAND.accent },
    });
    slide.addText(a.num, {
      x: 1.1, y: y + 0.2, w: 0.5, h: 0.5,
      fontSize: 14, color: BRAND.white, fontFace: "Arial",
      bold: true, align: "center", valign: "middle",
    });

    slide.addText(a.title, {
      x: 1.9, y: y + 0.1, w: 5, h: 0.35,
      fontSize: 15, color: BRAND.text, fontFace: "Arial", bold: true,
    });
    slide.addText(a.desc, {
      x: 1.9, y: y + 0.45, w: 10, h: 0.3,
      fontSize: 11, color: BRAND.textMuted, fontFace: "Arial",
    });
  });

  // Commitment box
  slide.addShape(pptx.shapes.ROUNDED_RECTANGLE, {
    x: 0.8, y: 5.6, w: 11.7, h: 0.9, rectRadius: 0.12,
    fill: { color: "0F1A0F" },
    line: { color: BRAND.success, width: 1 },
  });
  slide.addText(
    "In return, we commit to a measurable reduction in combined credit and fraud losses " +
    "within twelve months — or AURA reverts to GXS Bank at no cost.",
    {
      x: 1.1, y: 5.7, w: 11.1, h: 0.7,
      fontSize: 13, color: BRAND.success, fontFace: "Arial",
      italic: true, align: "center", lineSpacingMultiple: 1.3,
    }
  );

  // Final logo
  slide.addText("AURA", {
    x: 5.0, y: 6.6, w: 3.3, h: 0.5,
    fontSize: 28, color: BRAND.accent, fontFace: "Arial",
    bold: true, align: "center", letterSpacing: 8,
  });
  slide.addText("CONTINUUM RISK LABS  ·  2026", {
    x: 4.0, y: 7.0, w: 5.3, h: 0.3,
    fontSize: 9, color: BRAND.textMuted, fontFace: "Arial", align: "center",
  });

  addFooter(slide, "13", 13);
}

// ═══════════════════════════════════════════════════════════════
// SAVE
// ═══════════════════════════════════════════════════════════════
pptx.writeFile({ fileName: "assets/pdfs/AURA_Pitch_Deck_v2.pptx" })
  .then(() => console.log("✅ Created: assets/pdfs/AURA_Pitch_Deck_v2.pptx"))
  .catch((err) => console.error("❌ Error:", err));
