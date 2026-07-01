# Design: `e2e-playwright` skill + Playwright harness

**Date:** 2026-07-01
**Status:** Approved

## Purpose

Demonstrate two things at once for the AI-documentation-uplift work:

1. **Playwright** used for real browser-driven end-to-end testing.
2. **Claude Code skills** — an idiomatic project skill that lives beside the
   existing `run-app` / `rebuild-app` skills and orchestrates the tests.

The target application is this repo's Jakarta EE 10 hello app (WildFly + MySQL),
served at `http://localhost:8080/hello/`. The interactive feature worth testing
is the **greetings flow** (`/greetings/new` form → POST-Redirect-GET →
`/greetings` list), plus site navigation including the new Contact page.

## Scope

**In scope**

- A self-contained Playwright test harness under `e2e/`.
- Coverage of the greetings happy path + validation error, and navigation across
  home / greetings / about / contact.
- A `e2e-playwright` skill that ensures the app is up (chaining `run-app` if
  needed), installs Playwright, runs the suite headless, and reports results
  with trace/screenshot artifacts on failure.

**Out of scope (YAGNI)**

- CI wiring (GitHub Actions etc.).
- Multiple browser engines — Chromium only.
- Visual regression / snapshot testing.
- Running Playwright inside Docker. It runs on the host against the
  Docker-hosted app.

## Architecture

Two artifacts with a clean separation of concerns.

### 1. Playwright harness — new `e2e/` directory at repo root

A standalone Node project. It does **not** touch the Maven/WAR build; it only
exercises the running app over HTTP, so it stays out of `pom.xml` and the
Docker image.

- `e2e/package.json` — declares `@playwright/test` as a dev dependency and a
  `test` script (`playwright test`).
- `e2e/playwright.config.ts`:
  - `use.baseURL = http://localhost:8080/hello`
  - Chromium project only, headless.
  - `trace: 'on-first-retry'`, `screenshot: 'only-on-failure'`.
  - HTML reporter → `e2e/playwright-report/`; artifacts → `e2e/test-results/`.
  - No `webServer` block — the app lifecycle is owned by the skill / `run-app`,
    not by Playwright (the app is a Docker stack, not an `npm` process).
- `e2e/tests/greetings.spec.ts`:
  - **Happy path:** open the greeting form, fill `name` (unique per run, e.g.
    suffixed with a timestamp) + `message`, submit; assert navigation lands on
    `/greetings` and the submitted message is visible in the list.
  - **Validation:** submit with a blank `name` and a distinctive `message`;
    assert the inline error element (`[data-field="name"]`) is visible and the
    typed message is preserved in the re-rendered form.
- `e2e/tests/navigation.spec.ts`:
  - Home page renders "Hello, World".
  - Nav exposes links to `/greetings`, `/about`, `/contact`.
  - Clicking Contact navigates to the Contact page; assert the "Contact"
    heading and `hello@example.com` are present.
- `.gitignore` additions: `e2e/node_modules`, `e2e/test-results`,
  `e2e/playwright-report`.

**Selector strategy:** prefer role/text and `name=`-based locators tied to the
actual JSP markup (`greeting-form.jsp`, `greetings-list.jsp`, `contact.jsp`,
`layout/header.jspf`). The exact selectors are confirmed against the rendered
markup during implementation rather than assumed.

### 2. The skill — `.claude/skills/e2e-playwright/SKILL.md`

Sits alongside `run-app` and `rebuild-app`. Its procedure:

1. **Ensure the app is up.** Probe `http://localhost:8080/hello/`. If it does
   not return 200, invoke the **run-app** skill (`docker compose up --build -d`)
   and wait for WildFly boot markers before continuing.
2. **Install deps (idempotent).** In `e2e/`, run `npm install`, then
   `npx playwright install chromium` (downloads the browser binary the first
   time; a no-op afterwards).
3. **Run the suite.** `npx playwright test`.
4. **Report.** Summarise pass/fail. On failure, point the user to
   `e2e/playwright-report/` (HTML report) and the captured trace/screenshots.

## Data flow

```
skill → (probe) → app up? ──no──> run-app (docker compose up) → wait for boot
                    │yes                                            │
                    └──────────────┬─────────────────────────────┘
                                   ▼
             npm install + playwright install chromium
                                   ▼
                       npx playwright test
                                   ▼
        Chromium → HTTP → WildFly (/hello) → JPA → MySQL
                                   ▼
              pass/fail + report/ + trace on failure
```

## Error handling

- **App won't start:** if `run-app`'s boot markers don't appear within its
  timeout, the skill surfaces the WildFly log tail and stops — it does not run
  Playwright against a dead app.
- **Playwright browser missing:** handled by the idempotent
  `playwright install chromium` step.
- **Test failure:** non-zero exit from `playwright test`; the skill reports
  failures and the artifact locations rather than claiming success.

## Testing / verification

After building, run the skill end-to-end against the live app and confirm the
specs pass. Evidence (the Playwright run summary) is required before the work is
called done — no success claims without a green run.

## Language choice

TypeScript — Playwright's native default. `@playwright/test` runs `.ts` specs
directly under Node 22 with no separate compile step, so there is no build
tooling to add.
