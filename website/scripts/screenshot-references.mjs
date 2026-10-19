// Screenshots the converted design references (screenshots/ref/*.html) at 1440, 768 and 375.
import { readdirSync } from "node:fs";
import { resolve } from "node:path";
import { chromium } from "@playwright/test";

const dir = resolve("screenshots/ref");
const browser = await chromium.launch();
const page = await browser.newPage();
for (const file of readdirSync(dir).filter((f) => f.endsWith(".html"))) {
  for (const width of [1440, 768, 375]) {
    await page.setViewportSize({ width, height: 900 });
    await page.goto(`file://${dir}/${file}`);
    await page.evaluate(() => document.fonts.ready);
    await page.screenshot({ path: `${dir}/${file.replace(".html", "")}-${width}.png`, fullPage: true });
  }
}
await browser.close();
