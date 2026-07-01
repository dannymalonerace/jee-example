---
name: code-quality-review
description: Use when reviewing a change or diff to the hello Jakarta EE app for quality before committing or merging — checks this repo's layering, Bean Validation, POST-Redirect-GET, the JaCoCo coverage gate, config-from-env, and JSP/JPA security rules.
---

# Code-quality review (hello Jakarta EE app)

Reviews a diff against **this repo's** conventions, not generic style. It
complements the generic `/code-review` — run this for the project-specific rules
below. Review the diff (`git diff`, or the PR), then walk every dimension.

## Architecture: respect the layering

The dependency direction is strict — **web → service → repository → entity**.

```
web/         servlets + web/dto (GreetingForm, FieldErrors)   <- HTTP only
service/     GreetingService, InvalidGreetingException        <- business + validation
repository/  GreetingRepository                               <- persistence (EntityManager)
entity/      Greeting                                         <- @Entity only
boot/        FlywayBootstrap                                  <- startup migrations
```

- **No `EntityManager`, JPQL, or JPA imports in `web/`.** Servlets call the
  service; only `repository/` touches persistence.
- Servlets get collaborators via **CDI `@Inject`** (see `NewGreetingServlet`),
  never `new GreetingService()`.
- Business rules and validation live in **`service/`**, not the servlet. The
  service throws `InvalidGreetingException` carrying `FieldErrors`.

## Web behaviour: POST-Redirect-GET + validation

- A successful POST must **redirect**: `resp.sendRedirect(req.getContextPath() + "/…")`
  — never render HTML directly on POST (prevents double-submit).
- On invalid input: set **`SC_BAD_REQUEST` (400)** and re-render the form JSP with
  the submitted `form` + `errors` attributes. Match the `NewGreetingServlet` shape.
- New routes: `@WebServlet("/path")`, forward to `/WEB-INF/views/<x>.jsp`, set
  `activeNav` for the nav highlight.

## Coverage gate (will fail the build)

`./mvnw verify` enforces JaCoCo **LINE ≥ 80%** on the `BUNDLE`, scoped to:

- **Included:** `com.example.hello.service.*`, `com.example.hello.web.*`
- **Excluded:** `com.example.hello.entity.*`, `com.example.hello.web.dto.*`

So any new logic in `service/` or `web/` needs tests. Adding a servlet or service
method without a matching `*Test`/`*IT` likely drops the bundle under 80%.

## Security

- **XSS:** JSPs must escape user data — use JSTL `<c:out>` / `${fn:escapeXml(...)}`,
  never drop raw `${greeting.message}` into markup.
- **SQL/JPQL injection:** repository queries must be **parameterized** (named/positional
  params or Criteria) — no string-concatenated user input.
- **No secrets in code:** the datasource reads `DB_URL` / `DB_USER` / `DB_PASSWORD`
  from the environment. Flag any hard-coded URL, credential, or connection string.
- **Bean Validation:** DTO constraints (`@NotBlank`, `@Size`) must actually be
  enforced by the service before persistence, with the failure surfaced as
  `FieldErrors` (not a 500).

## Review checklist

- [ ] No persistence (`EntityManager`/JPQL/JPA) leaking into `web/`
- [ ] Service injected via `@Inject`; validation + rules in `service/`
- [ ] POST success redirects; invalid input returns 400 + re-rendered form
- [ ] New `service/`/`web/` logic has tests; bundle stays ≥ 80% (`./mvnw verify`)
- [ ] User data escaped in JSPs; queries parameterized
- [ ] Config from env vars, no hard-coded secrets
- [ ] New migration is a **new** `V<n>__*.sql` (never edits an applied one)

## Verify, don't assume

For anything you claim passes, run it: `./mvnw verify` (unit + IT + coverage gate).
Report findings most-severe first; cite `file:line`.
