---
name: e2e-playwright-pom
description: Use when asked to run the Page-Object-Model (POM) version of the Playwright E2E tests, or to compare/demonstrate the POM refactor of the browser suite against the hello app. Same coverage as e2e-playwright but selectors live in page-object classes.
---

# Playwright E2E tests — Page Object Model variant

Runs the **POM** version of the browser suite in `e2e/pom/` against the running
hello app at `http://localhost:8080/hello/`. Same behaviour and coverage as the
**e2e-playwright** skill, but structured with the Page Object Model: each view
has a class in `e2e/pom/pages/` that owns its locators, and the specs read as
intent (`form.fill(...)`, `nav.goToContact()`).

Both suites share the same `e2e/` Node project and Chromium install — this
variant just uses a separate config (`playwright.pom.config.ts`) and its own
report/results dirs, so you can run either without collisions.

## When to use which

- **e2e-playwright** — the original, inline-locator suite (`e2e/tests/`).
- **e2e-playwright-pom** — this one, POM-structured (`e2e/pom/`). Use it to see
  the refactored style or to demonstrate the pattern side by side.

## Structure

```
e2e/pom/
  pages/
    NavBar.ts            # component object (header nav)
    HomePage.ts
    GreetingFormPage.ts
    GreetingsListPage.ts
    ContactPage.ts
  tests/
    greetings.spec.ts    # uses GreetingFormPage + GreetingsListPage
    navigation.spec.ts   # uses HomePage + NavBar + ContactPage
```

## Step 1 — Make sure the app is up

Probe the home route:

```bash
node -e "fetch('http://localhost:8080/hello/').then(r=>console.log(r.status===200?'UP':'DOWN '+r.status)).catch(e=>console.log('DOWN',e.message))"
```

If it prints `DOWN`, start the app with the **run-app** skill
(`docker compose up --build -d`) and wait for the WildFly boot markers:

```bash
until docker compose logs wildfly 2>&1 | grep -qE 'WFLYSRV0025|ERROR'; do sleep 3; done
```

Do **not** run Playwright until the probe prints `UP`.

## Step 2 — Install Playwright (idempotent)

From the `e2e/` directory (shared with the inline suite):

```bash
cd e2e
npm install
npx playwright install chromium
```

## Step 3 — Run the POM suite

```bash
npx playwright test --config playwright.pom.config.ts          # from e2e/
```

Add `--headed` to watch it drive a real browser, or `--headed --workers=1` to
watch the steps play one at a time.

Expected: all specs green — same assertions as the inline suite (greeting
create + validation; home hero, nav links, Contact page reachable).

## Step 4 — Report

- On success: state that all N tests passed.
- On failure: do **not** claim success. Point to the artifacts:
  - HTML report: `e2e/playwright-report-pom/`
    (`npx playwright show-report playwright-report-pom`)
  - Per-failure trace + screenshot under `e2e/test-results-pom/`

## Notes

- Chromium only, headless by default.
- App lifecycle is owned by `run-app`, not Playwright (no `webServer` block).
- After changing app code, rebuild with **rebuild-app** before re-running.
