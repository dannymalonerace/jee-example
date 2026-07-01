---
name: generate-docs
description: Use when regenerating or refreshing this hello Jakarta EE app's docs — the README route list, a package-layout/architecture doc, the config/env-var table, or the DB schema summary — by deriving them from the actual code so the docs cannot drift.
---

# Generate docs from the code (hello Jakarta EE app)

Docs drift because they're written by hand. This skill **derives** them from the
source of truth so they stay accurate. Extract from code first, then write.
Never invent routes, env vars, or schema — read them.

## Sources of truth (extract, don't guess)

| Doc section | Derive from | How |
| --- | --- | --- |
| **Routes / nav** | `@WebServlet` annotations | `grep -rhoE '@WebServlet\(([^)]*)\)' src/main/java` — map each pattern to its servlet + the JSP it forwards to |
| **Package layout** | `src/main/java` tree | `find src/main/java -name '*.java'` — group by package (web, service, repository, entity, boot) |
| **Config / env vars** | datasource + compose | `System.getenv`/`${env.*}` usage and `docker-compose.yml` — list each var, default, purpose |
| **DB schema** | Flyway migrations | `src/main/resources/db/migration/V*__*.sql` — summarise tables/columns; the highest `V<n>` is the current version |
| **Test layers** | `pom.xml` + test tree | surefire (`*Test`) vs failsafe (`*IT`); JaCoCo bundle scope + 80% gate |

## Workflow

1. **Gather** the facts with the commands above (routes, packages, env, migrations).
2. **Pick the target** — usually one of:
   - Refresh the **README** "Pages" / routes list and the config table.
   - (Re)create a **`CLAUDE.md`** package-layout / architecture-rules doc at the
     repo root — note the repo had one and it was removed, so this is often the ask.
3. **Write** the doc from the gathered facts. Keep the existing README's voice and
   structure; replace only the derived sections.
4. **Cross-check** every generated fact against code before finishing — each route
   must resolve to a real `@WebServlet`, each env var to a real read, each table to
   a migration.

## Output conventions (match the repo)

- Australian/British English; lead with the answer (Minto), plain language.
- **Blank line after every heading**, and a blank line before every list — even
  when a colon introduces it. No `---` horizontal rules in the doc body.
- Routes as a table: `Path | Servlet | View (JSP) | Purpose`.
- Env vars as a table: `Variable | Default | Purpose` (mirror the README's table).
- Keep it a **reference**, not a narrative — no "in this session we…".

## What NOT to document

- Generated/build output (`target/`), IDE files (`.idea/`).
- Anything already obvious from a one-line command (don't restate every flag —
  point at `./mvnw`, `make help`).
- Machine-local specifics (ports a user remapped, personal `.env` values).

## Verify

If you refreshed routes, confirm they're real and reachable — the running app's
routes should match the generated list (see the **run-app** skill to boot + smoke).
