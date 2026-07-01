---
name: add-jee-page
description: Use when adding a new static/informational page (a new nav route like /contact, /credits, /docs) to the hello Jakarta EE app — a server-rendered JSP reachable from the top navigation.
---

# Add a new page to the hello app

A "page" in this app is always the same parts wired together. Adding the
servlet + JSP and stopping there *looks* done in the browser but leaves the
build, tests, and docs behind. **All parts below are required for every page —
none is optional.** Pick three values up front and reuse them everywhere:

- **PATH** — the URL after the context root, e.g. `/contact`
- **TITLE** — the visible heading + nav label, e.g. `Contact`
- **NAVKEY** — a lowercase `activeNav` key, e.g. `contact`

**Look and feel — required.** The new page MUST look and feel like the existing
pages: same header/footer, same page-title block, same card, spacing and
typography classes. Use **`about.jsp` as the worked example** and copy its
structure so the new page is visually indistinguishable in style from About —
only the wording changes. A page that works but looks different from the rest of
the app is not done.

## 1. Servlet — `src/main/java/com/example/hello/web/<Title>Servlet.java`

Mirror `AboutServlet`. `jakarta.*` only (never `javax.*`). It just sets
`activeNav` and forwards — no business logic.

```java
package com.example.hello.web;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/contact")                       // PATH
public class ContactServlet extends HttpServlet {   // <Title>Servlet
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("activeNav", "contact");   // NAVKEY
        req.getRequestDispatcher("/WEB-INF/views/contact.jsp").forward(req, resp);
    }
}
```

## 2. View — `src/main/webapp/WEB-INF/views/<navkey>.jsp`

Include the shared header/footer; render inside a `<section>`. JSPs are dumb —
only JSTL/EL, no scriptlets, no service or DB calls. Reuse the `about.jsp` card
classes so it matches.

```jsp
<%@ include file="layout/header.jspf" %>
<section class="space-y-6">
  <div>
    <h1 class="text-3xl font-bold tracking-tight">Contact</h1>          <!-- TITLE -->
    <p class="text-sm text-slate-600 mt-1">One-line subtitle.</p>
  </div>
  <div class="rounded-2xl border border-slate-200 bg-white shadow-sm p-6 sm:p-8 space-y-6">
    <p class="text-sm text-slate-700 leading-relaxed">Page content here.</p>
  </div>
</section>
<%@ include file="layout/footer.jspf" %>
```

## 3. Nav link — `src/main/webapp/WEB-INF/views/layout/header.jspf`

Add a link inside `<nav>` (after the About link). The `activeNav == 'NAVKEY'`
test must match the servlet's NAVKEY exactly, or the link never highlights.

```jsp
      <a href="${pageContext.request.contextPath}/contact"
         class="${activeNav == 'contact' ? 'bg-slate-100 text-slate-900' : 'text-slate-600 hover:text-slate-900 hover:bg-slate-50'} px-3 py-1.5 rounded-md font-medium transition-colors">Contact</a>
```

## 4. Integration test — `src/test/java/com/example/hello/web/HelloAppIT.java`

**Required, not optional.** The servlet lives in `com.example.hello.web.*`, which
is under the **JaCoCo 80% line-coverage gate**. An untested servlet adds uncovered
lines and can push `./mvnw verify` red; either way it breaks the test-pyramid
convention every other page follows. Add a smoke test beside the existing ones
(no new imports needed):

```java
    @Test
    void contact_returns_200_and_shows_title() {
        Response r = RestAssured.given().get(baseUrl + "/contact");   // PATH
        assertThat(r.statusCode()).isEqualTo(200);
        assertThat(r.asString()).contains("Contact");                 // TITLE
    }
```

## 5. Browser E2E test (Page Object Model) — `e2e/pom/`

**Required.** The IT in part 4 is HTTP-level; every nav page also gets a
**browser-level** test that hits the route the way a user does — clicking through
the nav. This repo uses the **Page Object Model**: the page's locators live in a
class under `e2e/pom/pages/`, and the spec reads as intent. Two small additions,
mirroring `ContactPage`:

**a. Page object — `e2e/pom/pages/<Title>Page.ts`** (copy `ContactPage.ts`, swap
the three values):

```ts
import { type Page, type Locator } from '@playwright/test';

/** The <TITLE> page (<navkey>.jsp) at /hello/<path>. */
export class ContactPage {                                              // <Title>Page
  readonly heading: Locator;

  constructor(private readonly page: Page) {
    this.heading = page.getByRole('heading', { name: 'Contact', level: 1 });  // TITLE
  }

  async goto(): Promise<void> {
    await this.page.goto('/hello/contact');                            // PATH
  }
}
```

**b. Nav test — add a case to `e2e/pom/tests/navigation.spec.ts`.** The
`NavBar.link(name)` locator is generic, so no NavBar change is needed:

```ts
import { ContactPage } from '../pages/ContactPage';                     // <Title>Page

test('can navigate to the Contact page from the nav', async ({ page }) => {  // TITLE
  const home = new HomePage(page);
  await home.goto();
  await home.nav.link('Contact').click();                              // TITLE

  const contact = new ContactPage(page);
  await expect(page).toHaveURL(/\/hello\/contact$/);                   // PATH
  await expect(contact.heading).toBeVisible();
});
```

Also add the new nav label to the existing **"nav exposes the main sections"**
assertions in the same file, so the link's presence is covered too.

## Then: docs + rebuild + run the E2E suite (Definition of Done)

- **README** — add the new route to the page list under "Run locally" (e.g.
  `` - `/hello/contact` — … ``). Adding a nav page is user-facing.

<!-- DISABLED FOR DEMO — do NOT run this step. `./mvnw clean verify` builds a
     Testcontainers image and runs the full IT suite (~10+ min), too slow for a
     live demo. Re-enable by uncommenting when the full gate is wanted again.
- **Verify** — `./mvnw clean verify` must be green (unit + IT + the 80% gate).
  Don't claim done until you've seen it pass.
-->

- **Rebuild** — the WAR is baked into the image, so the new page only appears
  after a rebuild. **Ask the user whether to rebuild the app** (via the
  **rebuild-app** skill) — don't rebuild automatically.

- **Run the POM E2E suite** — the browser test from part 5 hits the *running*
  app, so it can only pass **after** the rebuild. Once the app is rebuilt, run
  the POM suite via the **e2e-playwright-pom** skill (or directly from `e2e/`:
  `npx playwright test --config playwright.pom.config.ts`). Confirm it's green,
  **including the new test**, then hit the route in a browser and check the page
  renders, matches the other pages, and the nav link highlights. Don't claim the
  page is done until the POM suite passes.

## Checklist (all required)

| # | Part | Done when |
| - | --- | --- |
| 1 | `<Title>Servlet.java` | `@WebServlet("PATH")`, sets `activeNav="NAVKEY"`, forwards |
| 2 | `<navkey>.jsp` | header/footer included, dumb JSP, looks & feels like `about.jsp` |
| 3 | nav link in `header.jspf` | `activeNav == 'NAVKEY'` matches the servlet |
| 4 | test in `HelloAppIT` | GET PATH → 200 + body contains TITLE |
| 5 | POM object + nav test | `e2e/pom/pages/<Title>Page.ts` + case in `navigation.spec.ts` |
| 6 | README page list | new route listed |
| 7 | ask to rebuild | asked the user whether to rebuild via **rebuild-app** |
| 8 | POM suite green | `npx playwright test --config playwright.pom.config.ts` passes incl. the new test |

<!-- DISABLED FOR DEMO — re-enable together with the Verify step above:
| 9 | `./mvnw clean verify` | green, including JaCoCo 80% gate |
-->
