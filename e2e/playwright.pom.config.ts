import { defineConfig, devices } from '@playwright/test';

/**
 * Config for the Page-Object-Model variant of the suite. Shares the same
 * Node project and Chromium install as playwright.config.ts, but points at
 * pom/tests and writes to its own report/results dirs so the two suites'
 * artifacts don't collide.
 *
 * Run with: npx playwright test --config playwright.pom.config.ts
 */
export default defineConfig({
  testDir: './pom/tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: 0,
  reporter: [
    ['list'],
    ['html', { outputFolder: 'playwright-report-pom', open: 'never' }],
  ],
  outputDir: 'test-results-pom',
  use: {
    baseURL: 'http://localhost:8080',
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  ],
});
