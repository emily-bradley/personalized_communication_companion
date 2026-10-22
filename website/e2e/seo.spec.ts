import { expect, test } from "@playwright/test";
import { ROUTES } from "./routes";

for (const route of ROUTES) {
  test(`meta ${route.name}`, async ({ page }) => {
    await page.goto(route.path);
    await expect(page).toHaveTitle(/Selvo/);
    if (route.name === "404") {
      await expect(page.locator("meta[name=robots]")).toHaveAttribute("content", "noindex");
      await expect(page.locator("link[rel=canonical]")).toHaveCount(0);
    } else {
      await expect(page.locator("link[rel=canonical]")).toHaveAttribute("href", /^https:\/\//);
    }
    for (const selector of [
      "meta[name=description]",
      "meta[property='og:title']",
      "meta[property='og:description']",
      "meta[property='og:image']",
    ]) {
      const value = await page.locator(selector).getAttribute(selector.startsWith("link") ? "href" : "content");
      expect(value, selector).toBeTruthy();
    }
    const ogType = route.path.startsWith("/articles/") ? "article" : "website";
    await expect(page.locator("meta[property='og:type']")).toHaveAttribute("content", ogType);
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
