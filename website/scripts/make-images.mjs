// Generates public/favicon.svg, public/apple-touch-icon.png and public/og.png from the tokens.
// Run after changing the brand look: node scripts/make-images.mjs
import { readFileSync, writeFileSync } from "node:fs";
import { chromium } from "@playwright/test";

const t = JSON.parse(readFileSync(new URL("../src/design/tokens.json", import.meta.url), "utf8")).color;
const bars = (fill) =>
  `<rect x="4" y="30" width="10" height="44" rx="5" fill="${fill}"/><rect x="22" y="6" width="10" height="92" rx="5" fill="${fill}"/><rect x="40" y="38" width="10" height="28" rx="5" fill="${fill}"/>`;

const orbSvg = (
  size,
) => `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" width="${size}" height="${size}">
<defs><radialGradient id="g" cx="36%" cy="32%" r="75%"><stop offset="0" stop-color="${t["orb-glow"]}"/><stop offset="0.48" stop-color="${t.orb}"/><stop offset="1" stop-color="${t["orb-deep"]}"/></radialGradient></defs>
<circle cx="50" cy="50" r="50" fill="url(#g)"/>
<svg x="34.5" y="20" width="31" height="60" viewBox="0 0 54 104">${bars(t.white)}</svg>
</svg>`;

writeFileSync(new URL("../public/favicon.svg", import.meta.url), `${orbSvg(32)}\n`);

const lexend400 = readFileSync(
  new URL("../node_modules/@fontsource/lexend/files/lexend-latin-400-normal.woff2", import.meta.url),
).toString("base64");
const lexend600 = readFileSync(
  new URL("../node_modules/@fontsource/lexend/files/lexend-latin-600-normal.woff2", import.meta.url),
).toString("base64");
const fonts = `@font-face{font-family:Lexend;font-weight:400;src:url(data:font/woff2;base64,${lexend400}) format("woff2")}
@font-face{font-family:Lexend;font-weight:600;src:url(data:font/woff2;base64,${lexend600}) format("woff2")}`;

const og = `<!doctype html><html><head><style>${fonts}
body{margin:0;width:1200px;height:630px;background:${t["night-surface"]};font-family:Lexend,sans-serif;position:relative;overflow:hidden}
.wash{position:absolute;left:-220px;top:-260px;width:820px;height:640px;border-radius:999px;background:${t["night-indigo"]};opacity:.9;filter:blur(140px)}
.copy{position:absolute;left:88px;top:150px;display:flex;flex-direction:column;gap:28px}
.mark{display:inline-flex;align-items:center;gap:.06em;font-size:120px;font-weight:600;line-height:1;letter-spacing:-.02em;color:${t["night-ink"]}}
.mark svg{width:.5em;height:.96em}.vo{color:${t["night-teal"]}}
h1{margin:0;font-size:56px;line-height:1.1;font-weight:600;letter-spacing:-.01em;color:${t["night-ink"]}}
p{margin:0;font-size:28px;line-height:1.4;color:${t["night-ink-muted"]};max-width:600px}
.orb{position:absolute;right:110px;top:145px;width:340px;height:340px;border-radius:999px;box-shadow:0 0 80px 24px rgba(59,184,162,.35)}
</style></head><body><div class="wash"></div>
<div class="copy"><div class="mark"><span>Se</span><svg viewBox="0 0 54 104">${bars(t["night-ink"])}</svg><span class="vo">vo</span></div>
<h1>Your voice. Your way.</h1><p>A modern communication app for non-verbal adults.</p></div>
<div class="orb">${orbSvg(340)}</div></body></html>`;

const browser = await chromium.launch();
const page = await browser.newPage({ viewport: { width: 1200, height: 630 } });
await page.setContent(og);
await page.evaluate(() => document.fonts.ready);
await page.screenshot({ path: "public/og.png" });
await page.setViewportSize({ width: 180, height: 180 });
await page.setContent(
  `<body style="margin:0;background:${t["night-surface"]};display:flex;align-items:center;justify-content:center;width:180px;height:180px">${orbSvg(148)}</body>`,
);
await page.screenshot({ path: "public/apple-touch-icon.png" });
await browser.close();
