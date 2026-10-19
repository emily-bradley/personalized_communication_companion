import AxeBuilder from "@axe-core/playwright";
import { expect, test } from "@playwright/test";
import { ROUTES } from "./routes";

for (const route of ROUTES) {
  test(`axe ${route.name}`, async ({ page }) => {
    await page.emulateMedia({ reducedMotion: "reduce" });
    await page.goto(route.path);
    const results = await new AxeBuilder({ page }).withTags(["wcag2a", "wcag2aa", "wcag21a", "wcag21aa"]).analyze();
    const blocking = results.violations.filter((v) => v.impact === "serious" || v.impact === "critical");
    expect(blocking.map((v) => `${v.id}: ${v.nodes.map((n) => n.target.join(" ")).join(", ")}`)).toEqual([]);
  });

  test(`structure ${route.name}`, async ({ page }) => {
    await page.goto(route.path);
    await expect(page.locator("h1")).toHaveCount(1);
    await expect(page.locator("main")).toHaveCount(1);
    await expect(page.locator("header nav[aria-label=Primary]")).toBeVisible();
    await expect(page.locator("footer")).toHaveCount(1);
  });
}

test("early access shows the in-place success state", async ({ page }) => {
  await page.goto("/");
  const form = page.locator("form[data-early-access]");
  await form.getByRole("button", { name: "Join the list" }).click();
  await expect(page.locator("#access-error")).toContainText("Error");
  await form.getByLabel("Email address").fill("you@example.com");
  await form.getByRole("button", { name: "Join the list" }).click();
  await expect(page.getByRole("status")).toContainText("You are on the list.");
  await expect(form).toBeHidden();
});

test("current page is marked in the nav", async ({ page }) => {
  await page.goto("/story");
  await expect(page.locator("nav[aria-label=Primary] a[aria-current=page]")).toHaveText("Our story");
});
