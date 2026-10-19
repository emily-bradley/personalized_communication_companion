import { defineConfig, devices } from "@playwright/test";

export default defineConfig({
  testDir: "e2e",
  fullyParallel: true,
  reporter: [["list"]],
  use: { baseURL: "http://localhost:4321", ...devices["Desktop Chrome"] },
  webServer: {
    command: "pnpm exec astro preview --port 4321 --ignore-lock",
    url: "http://localhost:4321",
    reuseExistingServer: !process.env.CI,
    timeout: 60_000,
  },
});
