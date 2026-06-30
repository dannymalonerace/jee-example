create a prompt to develop a J2EE hello world web application with a [CLAUDE.md](http://CLAUDE.md), full tests sweet and local docker image to run development locally.  Add some navigation and forms for entry of some data, use JBOSS as the server and mysql as the database

# Prompt: J2EE Hello World Web Application

## Objective

Build a production-ready J2EE "Hello World" web application that serves as a learning scaffold and a reusable starter template. The deliverable must run locally end-to-end via Docker Compose with **WildFly/JBoss** as the application server and **MySQL** as the database, include a full automated test suite, and ship with a `CLAUDE.md` file that documents the project for future Claude Code sessions.

## Tech Stack (non-negotiable)

- **Language:** Java 17 (LTS)
- **Build tool:** Maven (multi-module not required; single WAR module is fine)
- **Application server:** WildFly 30+ (JBoss) — use the official `quay.io/wildfly/wildfly` image
- **Database:** MySQL 8.x (official `mysql:8` image)
- **Web framework:** Jakarta EE 10 (Servlet 6, JSP, JSTL, CDI 4, JPA 3.1, Bean Validation)
- **Persistence:** JPA with Hibernate (bundled in WildFly)
- **Frontend:** Server-rendered JSPs with a small amount of vanilla CSS — no SPA framework. Keep it clean and minimal.
- **Testing:** JUnit 5, Mockito, AssertJ for unit tests; Arquillian **or** Testcontainers + REST-assured for integration tests (prefer Testcontainers for simplicity)

> Note: Jakarta EE 10 uses the `jakarta.*` namespace (not `javax.*`). Confirm the WildFly version chosen supports Jakarta EE 10 before scaffolding.

## Functional Requirements

1. **Home page (`/`)** — A landing page with a friendly "Hello, World" message and a top navigation bar.
2. **Navigation bar** present on every page with at least these links:
    - Home
    - Greetings (list view)
    - New Greeting (form)
    - About
3. **Greeting entity** persisted in MySQL with these fields:
    - `id` (auto-generated)
    - `name` (required, 1–100 chars)
    - `message` (required, 1–500 chars)
    - `createdAt` (auto-populated server-side timestamp)
4. **New Greeting form (`/greetings/new`)** — Bean Validation annotations on the entity/DTO; server-side validation errors must render inline next to the offending field. Successful submission redirects to the list view (POST-Redirect-GET pattern).
5. **Greetings list (`/greetings`)** — Renders all greetings newest-first in a simple table.
6. **About page (`/about`)** — Static page describing the stack and linking to the README.

Architecture should follow a clean layering: **Servlet/Controller → Service (CDI bean) → Repository (JPA) → Entity**. No business logic in JSPs.

## Non-Functional Requirements

- All configuration (DB URL, credentials, etc.) must come from environment variables, not hard-coded. Use a WildFly datasource defined via CLI script or `standalone.xml` overlay, sourcing values from env vars.
- Use Flyway for database schema migrations — do **not** rely on `hibernate.hbm2ddl.auto=update` for anything other than local experimentation.
- Structured logging via SLF4J + Logback (or JBoss Logging — pick one and be consistent).
- Sensible `.gitignore`, `.dockerignore`, and `.editorconfig`.

## Test Suite Requirements

The phrase "full test suite" means all of the following, and CI-runnable via a single `mvn verify`:

1. **Unit tests** for the service layer with Mockito for repository mocks.
2. **Repository/JPA tests** using Testcontainers with a real MySQL 8 container — no H2 substitution.
3. **Integration tests** that boot the deployed WAR (via Arquillian managed WildFly **or** Testcontainers running the WildFly image with the WAR mounted) and exercise the HTTP endpoints with REST-assured or the Jakarta `HttpClient`. Cover at least: GET home, GET list, POST new greeting (happy path), POST new greeting (validation failure).
4. **JaCoCo** code coverage report wired into the verify phase, with a minimum line coverage threshold of 80% on the service and controller packages (the entity/DTO layer can be excluded).
5. Test reports written to `target/surefire-reports` and `target/failsafe-reports` as usual.

## Local Development & Docker

- A single `docker compose up` from the project root must bring up:
    - A `mysql` service with a named volume for persistence and a healthcheck.
    - A `wildfly` service that builds from a project `Dockerfile`, deploys the WAR, and waits for MySQL to be healthy before starting.
- The WildFly Dockerfile should:
    - Start from the official WildFly 30+ image.
    - Add the MySQL JDBC driver as a module.
    - Register a datasource named `java:/jdbc/HelloDS` pointing at the MySQL container.
    - Copy the built WAR into `$JBOSS_HOME/standalone/deployments/`.
    - Expose port 8080 (app) and 9990 (management console).
- Provide a `Makefile` (or shell scripts) with at minimum: `make build`, `make up`, `make down`, `make test`, `make logs`.
- The app should be reachable at `http://localhost:8080/hello/` once `docker compose up` is healthy.

## Deliverables

Produce all of the following files, with real content (no TODO placeholders):

1. `pom.xml` with all dependencies, plugins, and the JaCoCo + Failsafe configuration.
2. Full Java source tree under `src/main/java`.
3. JSPs under `src/main/webapp/WEB-INF/views/` (do not expose JSPs directly; route via servlets).
4. `web.xml` only if needed — prefer annotation-based configuration.
5. Flyway migrations under `src/main/resources/db/migration/`.
6. `persistence.xml` referencing the JNDI datasource.
7. Full test sources under `src/test/java`.
8. `Dockerfile` for the WildFly image.
9. `docker-compose.yml`.
10. `Makefile`.
11. `README.md` covering: prerequisites, how to build, how to run locally, how to run tests, how to access the app, and a troubleshooting section.
12. **`CLAUDE.md`** at the repo root — see the next section for what this must contain.

## CLAUDE.md Requirements

The `CLAUDE.md` is the entry point for any future Claude Code session working in this repo. It should be concise, scannable, and high signal — not a copy of the README. Include:

- **Project overview** — one paragraph: what this app is and its intended audience.
- **Stack & versions** — Java, Jakarta EE, WildFly, MySQL, Maven versions pinned.
- **Repository layout** — a short tree of the top-level directories with one-line descriptions of each.
- **Common commands** — the exact Maven, Docker, and Make commands for build, test, run, and clean. Include the single command to run a single test class so Claude doesn't run the full suite when iterating.
- **Architecture rules** — the layering rule (Servlet → Service → Repository), the package convention, and the rule that JSPs must not contain business logic.
- **Testing conventions** — naming (`*Test` for unit, `*IT` for integration), where Testcontainers is used, and the coverage threshold.
- **Database & migrations** — Flyway is the source of truth; never edit applied migrations; how to add a new one.
- **Things to avoid** — no `javax.*` imports (Jakarta only), no `hbm2ddl=update` in committed config, no hard-coded credentials, no business logic in JSPs, no SPA framework additions.
- **Definition of done for any change** — `mvn verify` passes, JaCoCo threshold met, `docker compose up` still works end-to-end, README updated if user-facing behavior changed.

Keep `CLAUDE.md` under ~200 lines. Use a Read-Plan-Act framing if helpful, but don't pad.

## Working Process

1. **Plan first.** Before writing code, output a short plan: the package structure, the list of classes you'll create, the Flyway migration filenames, and the test classes. Wait for confirmation only if anything in this prompt is ambiguous — otherwise proceed.
2. **Build incrementally and verify.** Implement in this order: Maven skeleton → entity + migration → repository + repository tests → service + unit tests → servlets + JSPs → integration tests → Docker setup → `CLAUDE.md` and `README.md`. Run `mvn verify` (or the relevant subset) after each major step.
3. **Prove it works.** End with the exact commands to run and the expected output, including a curl/browser check against `http://localhost:8080/hello/` and the greetings endpoints.

## Acceptance Criteria

- `mvn clean verify` passes locally with all tests green and JaCoCo threshold met.
- `docker compose up --build` brings the app up and `curl -fsS http://localhost:8080/hello/` returns HTTP 200.
- Submitting a greeting via the form persists it to MySQL and it appears on the list page after redirect.
- Validation errors render inline without losing the user's input.
- `CLAUDE.md` is present, accurate, and matches the actual repo layout and commands.



# Some things to try

Upgrade to latest Wildfly 40 and MySQL 8.0.29 with the latest Jakarta EE 11
Try and add a feature - you pick=Add a feature to allow users to delete their greetings
