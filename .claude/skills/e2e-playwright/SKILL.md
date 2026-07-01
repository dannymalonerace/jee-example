---
name: e2e-playwright
description: Use when asked to run the Playwright end-to-end (browser) tests against the hello app, or to E2E-test / smoke-test the running app through a real browser. Drives the greetings form and site navigation in headless Chromium and reports pass/fail with trace artifacts.
---

# Playwright E2E tests (browser-driven)

Runs the Playwright suite in `e2e/` against the running hello app at
`http://localhost:8080/hello/`. Unlike the Testcontainers IT (`HelloAppIT`,
HTTP-level), these tests drive a **real Chromium browser** — filling the
greeting form, submitting, and clicking through the nav.

The suite lives in `e2e/` and is a standalone Node project; it does **not**
touch the Maven build or the WAR.

## Prerequisites

- Node.js + npm on the host (`node --version`).
- The app must be running (this skill starts it for you if it isn't — see below).

## Step 1 — Make sure the app is up

Probe the home route:

```bash
curl -sfo /dev/null http://localhost:8080/hello/ && echo UP || echo DOWN
```

If it prints `DOWN`, start the app with the **run-app** skill
(`docker compose up --build -d`) and wait for the WildFly boot markers before
continuing:

```bash
until docker compose logs wildfly 2>&1 | grep -qE 'WFLYSRV0025|ERROR'; do sleep 3; done
```

Do **not** run Playwright until the probe prints `UP`. Testing against a dead
app produces noise, not signal.

## Step 2 — Install Playwright (idempotent)

From the `e2e/` directory:

```bash
cd e2e
npm install
npx playwright install chromium
```

`npm install` is a no-op after the first run; `playwright install chromium`
downloads the browser binary once and is fast thereafter.

## Step 3 — Run the suite

```bash
npx playwright test          # from e2e/
```

Expected: all specs green —

- `greetings.spec.ts` — create a greeting (POST-Redirect-GET) and see it in the
  list; blank-name submit shows the `[data-field="name"]` validation error and
  preserves the typed message.
- `navigation.spec.ts` — home hero renders; nav links present; Contact page
  reachable by clicking through the nav.

## Step 4 — Report

- On success: state that all N tests passed.
- On failure: do **not** claim success. Point to the artifacts:
  - HTML report: `e2e/playwright-report/` (open with `npx playwright show-report`)
  - Per-failure trace + screenshot under `e2e/test-results/`

## Notes

- Chromium only, headless. To watch it run, add `--headed`; to debug a single
  test, `npx playwright test --debug`.
- The app lifecycle is owned by `run-app`, not Playwright — that's why
  `playwright.config.ts` has no `webServer` block.
- After changing app code, rebuild with the **rebuild-app** skill before
  re-running these tests, or they'll hit the old WAR.
