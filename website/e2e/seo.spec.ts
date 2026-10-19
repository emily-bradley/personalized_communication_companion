import { expect, test } from "@playwright/test";
import { ROUTES } from "./routes";

for (const route of ROUTES) {
  test(`meta ${route.name}`, async ({ page }) => {
    await page.goto(route.path);
    await expect(page).toHaveTitle(/Selvo/);
    for (const selector of [
      "meta[name=description]",
      "link[rel=canonical]",
      "meta[property='og:title']",
      "meta[property='og:description']",
      "meta[property='og:image']",
    ]) {
      const value = await page.locator(selector).getAttribute(selector.startsWith("link") ? "href" : "content");
      expect(value, selector).toBeTruthy();
    }
  });
}

test("every internal link resolves", async ({ page, request }) => {
  const seen = new Set<string>();
  for (const route of ROUTES.filter((r) => r.name !== "404")) {
    await page.goto(route.path);
    const hrefs = await page.locator("a[href^='/']").evaluateAll((links) => links.map((a) => a.getAttribute("href")));
    for (const href of hrefs) if (href) seen.add(href.split("#")[0] || "/");
  }
  for (const href of [
    ...seen,
    "/og.png",
    "/favicon.svg",
    "/apple-touch-icon.png",
    "/robots.txt",
    "/sitemap-index.xml",
  ]) {
    const response = await request.get(href);
    expect(response.status(), href).toBe(200);
  }
});
