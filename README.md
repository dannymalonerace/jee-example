# hello — Jakarta EE 10 starter on WildFly + MySQL

A small "Hello, World" web app meant as a learning scaffold and a reusable starter. Server-rendered JSPs styled with Tailwind CSS (Play CDN), a single `Greeting` entity, full POST-Redirect-GET form handling with inline Bean Validation errors, Flyway-managed schema, and a real test pyramid (unit, JPA repository, full HTTP integration) — all runnable with `./mvnw clean verify` and `docker compose up`.

## Prerequisites

- **Docker** (Docker Desktop 4.40+ or equivalent)
- **JDK 17 or newer** on `PATH` — the build targets bytecode 17 via `--release 17`, but a newer JDK is fine
- That's it. Maven is provided via `./mvnw`.

## Build

```bash
./mvnw -DskipTests package        # WAR at target/hello.war
./mvnw clean verify               # unit + integration tests + JaCoCo 80% gate
./mvnw test -Dtest=GreetingServiceTest   # one unit test class
```

The integration tests require a running Docker daemon — see [Testing](#testing).

## Run locally

```bash
docker compose up --build         # foreground; Ctrl-C to stop
# or
make up                           # detached
make logs                         # tail wildfly
make smoke                        # curl http://localhost:8080/hello/ until 200
make down                         # stop
make clean                        # stop + drop mysql volume
```

The app is at **http://localhost:8080/hello/**. Pages:

- `/hello/` — home
- `/hello/greetings` — list (newest-first)
- `/hello/greetings/new` — form (Bean Validation, POST-Redirect-GET)
- `/hello/about` — stack info

The WildFly management console is at http://localhost:9990 (no users seeded by default).

### Configuration

Database connection comes from environment variables, not from any hard-coded config:

| Variable | Default in compose | Purpose |
| --- | --- | --- |
| `DB_URL` | `jdbc:mysql://mysql:3306/hello?…` | JDBC URL injected into `java:/jdbc/HelloDS` |
| `DB_USER` | `hello` | datasource user |
| `DB_PASSWORD` | `hello` | datasource password |
| `MYSQL_DATABASE` / `MYSQL_USER` / `MYSQL_PASSWORD` / `MYSQL_ROOT_PASSWORD` | see `.env.example` | bootstrap values for the MySQL container |

Copy `.env.example` to `.env` if you want to override defaults; `docker compose` picks it up automatically.

## Testing

Three layers, all run by `./mvnw clean verify`:

1. **Unit tests** (`*Test`) — pure JUnit 5 + Mockito + AssertJ, no Docker. Run with `./mvnw test`.
2. **JPA repository ITs** (`*IT` under `repository/`) — boot a real MySQL 8 container via Testcontainers and exercise the repository through a resource-local persistence unit. Flyway migrates the schema before each suite.
3. **HTTP ITs** (`*IT` under `web/`) — `HelloAppIT` builds the project Dockerfile via `ImageFromDockerfile`, starts WildFly + MySQL on a shared Testcontainers `Network`, and drives the HTTP endpoints with REST-assured. First run is slow because the WildFly base image is ~700MB; subsequent runs hit BuildKit cache.

JaCoCo enforces a **80% line coverage** gate on `com.example.hello.service.*` and `com.example.hello.web.*`. The entity and `web.dto` packages are excluded (no logic to cover).

## Troubleshooting

**`Could not find a valid Docker environment` / `Status 400 … client version 1.32 is too old`**
Docker 29+ rejects the very old API version that older docker-java clients negotiate. The build sets `-Dapi.version=1.44` in surefire/failsafe; if you're running tests outside Maven, set the same system property or `DOCKER_API_VERSION=1.44`.

**`Mockito: Could not modify all classes`**
This shows up if surefire isn't passing `-javaagent:${org.mockito:mockito-core:jar}`. Make sure you didn't disable the `maven-dependency-plugin:properties` execution — it resolves the agent jar path before surefire forks.

**Wrapper can't download Maven**
On first run `./mvnw` downloads Maven 3.9.9 from `repo.maven.apache.org` into `~/.m2/wrapper/`. Behind a proxy, set `MAVEN_OPTS="-Dhttp.proxyHost=… -Dhttp.proxyPort=…"`.

**App is up but `/hello/` returns 404**
The WAR file name controls the context root. Make sure `pom.xml` still has `<finalName>hello</finalName>` and that the WAR landed at `$JBOSS_HOME/standalone/deployments/hello.war` inside the container (`docker exec hello-wildfly ls /opt/jboss/wildfly/standalone/deployments/`).

**Datasource fails to start: "could not find driver mysql"**
The Dockerfile installs `mysql-connector-j` as a JBoss module via curl from Maven Central. If the curl failed during build (network), rebuild with `docker compose build --no-cache wildfly`. The version is set by `MYSQL_DRIVER_VERSION` build arg in the Dockerfile.

**Migrations don't apply**
Flyway runs at app startup via `boot/FlywayBootstrap`. Check the WildFly log for `Flyway applied N migration(s)`. If the schema is drifted (you edited an applied V<n> file), drop the volume with `make clean` and start fresh.

## Layout

See [`CLAUDE.md`](./CLAUDE.md) for the package layout, architecture rules, and conventions.

## License

Sample code — use however you like.
