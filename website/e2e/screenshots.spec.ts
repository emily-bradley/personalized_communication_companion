import { expect, test } from "@playwright/test";
import { ROUTES, WIDTHS } from "./routes";

for (const route of ROUTES) {
  for (const width of WIDTHS) {
    test(`screenshot ${route.name} at ${width}`, async ({ page }) => {
      await page.setViewportSize({ width, height: 900 });
      await page.goto(route.path);
      await page.evaluate(() => document.fonts.ready);
      await page.screenshot({ path: `screenshots/${route.name}-${width}.png`, fullPage: true, animations: "disabled" });
      const overflow = await page.evaluate(() => document.documentElement.scrollWidth - window.innerWidth);
      expect(overflow, "no horizontal scroll").toBeLessThanOrEqual(0);
    });
  }
}
