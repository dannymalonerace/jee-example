# CLAUDE.md

Entry point for Claude Code sessions in this repo.

## Project overview

A Jakarta EE 10 "Hello, World" web app on WildFly + MySQL. Server-rendered JSPs, a single CRUD-light entity (`Greeting`), POST-Redirect-GET form handling with inline Bean Validation errors. The repo doubles as a reusable starter template — layering, conventions, and the test pyramid are intentional and worth preserving.

## Stack & versions

- Java 17 (compiled via `--release 17`; tests run on whatever JDK invokes `./mvnw`)
- Maven 3.9.9 (via wrapper — `./mvnw`)
- Jakarta EE 10 Web Profile (`jakarta.jakartaee-web-api:10.0.0`, `jakarta.*` namespace only)
- WildFly 30.0.1.Final (`quay.io/wildfly/wildfly:30.0.1.Final-jdk17`)
- MySQL 8.0
- Hibernate ORM (provided by WildFly)
- Flyway 10.20.1 (runs in-app at startup via `boot/FlywayBootstrap`)
- JUnit 5, Mockito 5.20, AssertJ, Testcontainers 1.21, REST-assured
- Tailwind CSS v3 via Play CDN (script tag in `header.jspf`) — no build pipeline; swap to the standalone CLI for production

## Repository layout

```
.
├── CLAUDE.md             # this file
├── README.md             # human-facing docs
├── Dockerfile            # multi-stage: maven build → WildFly with datasource baked in
├── docker-compose.yml    # mysql + wildfly services
├── Makefile              # build / test / up / down / logs / smoke
├── pom.xml               # single WAR module
├── mvnw, .mvn/           # Maven Wrapper — use ./mvnw, not system mvn
├── docker/
│   ├── datasource.cli    # JBoss CLI: registers MySQL JDBC driver + java:/jdbc/HelloDS
│   └── modules/com/mysql/jdbc/main/module.xml
└── src/
    ├── main/
    │   ├── java/com/example/hello/
    │   │   ├── entity/         # JPA entities
    │   │   ├── repository/     # @ApplicationScoped JPA gateways
    │   │   ├── service/        # @ApplicationScoped @Transactional CDI beans
    │   │   ├── web/            # @WebServlet controllers
    │   │   ├── web/dto/        # request/response DTOs (no business logic)
    │   │   └── boot/           # FlywayBootstrap @Singleton @Startup
    │   ├── resources/META-INF/persistence.xml
    │   ├── resources/db/migration/V*.sql        # Flyway migrations
    │   └── webapp/             # WEB-INF/views/*.jsp + static/css
    └── test/
        ├── java/com/example/hello/
        │   ├── service/*Test.java       # surefire — pure unit, Mockito
        │   ├── repository/*IT.java      # failsafe — Testcontainers MySQL
        │   └── web/*IT.java             # failsafe — Testcontainers WildFly+MySQL
        └── resources/META-INF/persistence.xml   # test PU, RESOURCE_LOCAL
```

## Common commands

| Task | Command |
| --- | --- |
| Build WAR (skip tests) | `./mvnw -DskipTests package` |
| Run unit tests only | `./mvnw test` |
| Run a single unit test | `./mvnw test -Dtest=GreetingServiceTest` |
| Run unit + integration + JaCoCo gate | `./mvnw clean verify` |
| Run a single IT | `./mvnw verify -Dit.test=GreetingRepositoryIT -DfailIfNoTests=false -Dsurefire.failIfNoSpecifiedTests=false -Dtest='!*'` |
| Bring up app via Docker | `make up` (or `docker compose up --build -d`) |
| Tail server logs | `make logs` |
| Tear down + drop volume | `make clean` |

The app is reachable at `http://localhost:8080/hello/`.

## Architecture rules

- **Layering**: Servlet → Service → Repository → Entity. One direction only.
- **JSPs are dumb**: only JSTL (`c:forEach`, `c:if`, `c:out`) and EL bound to request attributes. No scriptlets, no service lookups, no business logic, no DB calls.
- **Servlets** route via `@WebServlet`; they convert request params to DTOs, call services, set request attributes, forward to JSPs (or `sendRedirect` for POST-Redirect-GET).
- **Services** own validation (`Validator` + `InvalidGreetingException`) and transactions (`@Transactional`).
- **Repositories** are thin JPA gateways — no business rules, no cross-entity orchestration.
- **DTOs in `web/dto`** are excluded from the JaCoCo coverage gate; do not put logic there.
- **Package convention**: everything under `com.example.hello.<layer>`.

## Testing conventions

- `*Test` → surefire, pure unit, no Docker, no I/O.
- `*IT` → failsafe, may use Testcontainers and the network. Build phase: `integration-test` / `verify`.
- Repository ITs talk to a real MySQL 8 Testcontainer (no H2). Driven by a resource-local `helloPU-test` persistence unit (`src/test/resources/META-INF/persistence.xml`).
- HTTP ITs (`HelloAppIT`) build the project Dockerfile via `ImageFromDockerfile` and start WildFly + MySQL on a Testcontainers `Network`. First run is slow — buildkit cache helps subsequent runs.
- JaCoCo line-coverage gate is **80%** on `com.example.hello.service.*` and `com.example.hello.web.*` (entity and `web.dto` excluded). Don't loosen this without a real reason.
- Mockito is wired as a Java agent in surefire (`-javaagent:${org.mockito:mockito-core:jar}`) so tests work on JDK 21+.
- Testcontainers requires `-Dapi.version=1.44` for Docker Desktop 29+; this is set in surefire/failsafe `<systemPropertyVariables>`.

## Database & migrations

- **Flyway is the source of truth** for schema. Hibernate runs with `hibernate.hbm2ddl.auto=none` — never `update` or `create`. (`validate` would fire before `FlywayBootstrap` gets to create tables, since the JTA persistence unit boots before `@Startup @Singleton` EJBs.)
- Migrations live in `src/main/resources/db/migration/` named `V<n>__<snake_case>.sql`.
- To add a migration: create the next `V<n>__<...>.sql`, never edit an applied one. Flyway runs at app startup (`FlywayBootstrap`), so new migrations apply on the next deploy.
- The MySQL container in compose persists to a named volume `mysql-data`; `make clean` drops it so Flyway re-applies from V1.

## Things to avoid

- `javax.*` imports — Jakarta EE 10 uses `jakarta.*` only. Importing `javax.servlet.*` etc. silently won't resolve.
- `hibernate.hbm2ddl.auto=update` or `create` in committed config. Keep it `none`; Flyway owns the schema.
- Hard-coded credentials or DB URLs anywhere — they must come from env vars, plumbed through `docker-compose.yml` and `Dockerfile`.
- Business logic in JSPs, scriptlets in JSPs.
- Adding a SPA framework, JS bundler, or a `webjars` dependency. (Tailwind via Play CDN is allowed; swap to the standalone CLI before production.)
- Replacing the WildFly built-in logging — keep the SLF4J → JBoss LogManager bridge; do not bundle Logback in the WAR.
- H2 or in-memory substitutes in tests. Repository tests must hit real MySQL via Testcontainers.

## Definition of done for any change

1. `./mvnw clean verify` is green (unit + IT) and the JaCoCo 80% gate passes.
2. `docker compose up --build` brings the app up and `curl -fsS http://localhost:8080/hello/` returns 200.
3. The user-facing form/list flow still works end-to-end (submit valid → appears in list; submit blank → inline error + preserved input).
4. README updated if user-facing behavior or commands changed.
