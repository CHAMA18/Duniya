#!/usr/bin/env node
// ═══════════════════════════════════════════════════════════════
// Convert AURA Proposal HTML → PDF
// ═══════════════════════════════════════════════════════════════
const puppeteer = require("puppeteer-core");
const path = require("path");

(async () => {
  const browser = await puppeteer.launch({
    executablePath:
      "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    headless: "new",
  });

  const page = await browser.newPage();

  const htmlPath = path.resolve("assets/pdfs/AURA_Proposal_v2.html");
  await page.goto(`file://${htmlPath}`, { waitUntil: "networkidle0" });

  await page.pdf({
    path: "assets/pdfs/AURA_Proposal_v2.pdf",
    format: "A4",
    printBackground: true,
    margin: { top: "0", right: "0", bottom: "0", left: "0" },
    preferCSSPageSize: true,
  });

  await browser.close();
  console.log("✅ Created: assets/pdfs/AURA_Proposal_v2.pdf");
})();
