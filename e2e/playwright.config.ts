import { defineConfig, devices } from '@playwright/test';

/**
 * Playwright config for the hello app E2E suite.
 *
 * The app is a Docker-hosted WildFly + MySQL stack served at
 * http://localhost:8080/hello/ — its lifecycle is owned by the `run-app`
 * skill, NOT by Playwright, so there is deliberately no `webServer` block.
 */
export default defineConfig({
  testDir: './tests',
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: 0,
  reporter: [
    ['list'],
    ['html', { outputFolder: 'playwright-report', open: 'never' }],
  ],
  outputDir: 'test-results',
  use: {
    // App context path is /hello; specs use absolute /hello/... paths.
    baseURL: 'http://localhost:8080',
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  ],
});
