---
name: rebuild-app
description: Use when you changed the hello app's code (Java, JSP, CSS, Flyway migration, Dockerfile) and need to rebuild and redeploy it on the running WildFly + MySQL Docker stack so the change takes effect.
---

# Rebuild the hello app after a change

Nothing in this stack is hot-reloaded: the WAR is compiled by Maven and **baked
into the WildFly image** at build time (no source or `target/` volume is mounted).
So *any* change — Java, JSP, CSS, or a new Flyway migration — needs a rebuild +
redeploy before it shows up. This skill does that.

Run from the **repo root** (where `docker-compose.yml` is), same stack the
**run-app** skill started.

## Default: rebuild the image and recreate WildFly

This is correct for **every** change type (including `Dockerfile`, datasource, or
a dependency bump) because it rebuilds the WAR from source through the Dockerfile.

```bash
docker compose up --build -d        # or: make up
```

BuildKit caches the Maven dependency layer, so after the first build only
"copy `src` → `mvn package` → assemble image" re-runs — usually tens of seconds.
Compose recreates the `wildfly` container only if its image changed; MySQL and
its data volume are untouched.

Then wait for the redeploy and smoke it:

```bash
until docker compose logs wildfly 2>&1 | grep -qE 'WFLYSRV0025|WFLYCTL.*failed|ERROR'; do sleep 3; done
docker compose logs wildfly 2>&1 | grep -E 'Flyway applied|Deployed "hello.war"|started in'
make smoke                          # http://localhost:8080/hello/ -> 200
```

## Faster inner loop (app code / JSP / CSS only)

If you're iterating on Java/JSP/CSS and **not** touching the Dockerfile or
datasource, skip the image rebuild: build just the WAR on the host and drop it
into WildFly's deployment scanner, which auto-redeploys in a few seconds.
Requires a JDK 17+ on the host (`./mvnw` provides Maven).

```bash
./mvnw -DskipTests package
docker cp target/hello.war hello-wildfly:/opt/jboss/wildfly/standalone/deployments/hello.war
```

Want this to be the standing loop? Mount the WAR once in `docker-compose.yml`
under the `wildfly` service, then every `./mvnw package` is auto-picked-up:

```yaml
    volumes:
      - ./target/hello.war:/opt/jboss/wildfly/standalone/deployments/hello.war
```

## Picking the path

| Situation | Use |
| --- | --- |
| Any change, or unsure | `docker compose up --build -d` (default) |
| Changed `Dockerfile` / datasource / dependency | `docker compose up --build -d` (required) |
| Tight Java/JSP/CSS loop, JDK on host | `./mvnw package` + `docker cp` |
| Just restart, no code change | `docker compose restart wildfly` |

## Migration caveat

A **new** `V<n>__*.sql` applies on the next (re)deploy. But if you **edit an
already-applied** `V<n>` file, Flyway's checksum check fails on boot. Reset with:

```bash
make clean                          # stops and drops the MySQL volume
docker compose up --build -d        # fresh schema, migrations re-applied
```

## Verify it took effect

Don't assume — confirm the redeploy and that the change is live:

- Boot markers present: `Deployed "hello.war"` + `WFLYSRV0025 ... started in`.
- `make smoke` returns 200.
- Hit the specific route you changed and check the new behavior/output.
