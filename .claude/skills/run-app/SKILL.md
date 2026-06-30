---
name: run-app
description: Use when asked to run, start, boot, launch, or smoke-test the hello app (this Jakarta EE 10 / WildFly + MySQL repo) locally with Docker Compose — and to drive it to confirm it actually serves.
---

# Run the hello app (Docker Compose)

Boots the Jakarta EE 10 demo (`hello.war`) on WildFly with a MySQL backend, via
`docker compose`. The WAR is **compiled by Maven inside the Docker build** — you
do not need Java or Maven on the host to run it; you only need Docker.

## Prerequisites

- Docker daemon running (`docker version` succeeds).
- Run from the **repo root** (the directory with `docker-compose.yml`). Docker
  Compose names the stack after this directory — running from a git worktree
  creates a *separate* set of containers. Use the main checkout for one shared stack.

## Launch

```bash
docker compose up --build -d        # or: make up
```

First run pulls the WildFly base image (~700 MB) and downloads all Maven
dependencies inside the build — expect a few minutes. Later runs hit the
BuildKit cache and are fast.

## Wait until it's actually ready

`up -d` returns once containers *start*, but WildFly still has to deploy the WAR
and run Flyway. Wait for the deploy + boot markers before driving it:

```bash
until docker compose logs wildfly 2>&1 | grep -qE 'WFLYSRV0025|WFLYCTL.*failed|ERROR'; do sleep 3; done
docker compose logs wildfly 2>&1 | grep -E 'Flyway applied|Deployed "hello.war"|started in'
```

Healthy boot shows: `Flyway applied N migration(s)`, `Deployed "hello.war"`,
and `WFLYSRV0025: WildFly ... started in <ms>`.

## Drive it (don't just launch it)

Smoke the home route, then exercise the core POST-Redirect-GET feature:

```bash
make smoke                          # curls http://localhost:8080/hello/ until HTTP 200
```

Create a greeting and confirm it persists (proves WildFly → JPA → MySQL works):

```bash
# NOTE: the form POSTs to /greetings/new (NewGreetingServlet), NOT /greetings.
#       Fields are name + message. A 302 -> /hello/greetings means success.
curl -i -d 'name=Keith&message=hello' http://localhost:8080/hello/greetings/new
curl -s http://localhost:8080/hello/greetings | grep -i keith
```

(If `curl` is blocked in your environment, run the same request from inside the
container with a `/dev/tcp` call to `localhost:8080`, or open the URL in a browser.)

## URLs and ports

- App: **http://localhost:8080/hello/** — routes: `/`, `/greetings`,
  `/greetings/new` (form), `/about`
- WildFly management console: http://localhost:9990 (no users seeded)
- MySQL: host port **3307** → container 3306

## Manage

| Command | Action |
| --- | --- |
| `make logs` | tail WildFly logs |
| `make down` | stop containers (keeps MySQL volume/data) |
| `make clean` | stop **and drop the MySQL volume** (fresh schema next boot) |

## After a code change

To see a change you must rebuild — nothing is hot-reloaded and the WAR is baked
into the image. Use the **rebuild-app** skill.

## Gotchas

- `400 Bad Request` on the form → wrong path or fields. POST to
  `/hello/greetings/new` with `name` and `message`.
- `/hello/` returns 404 → WAR name/context root drifted; `pom.xml` must keep
  `<finalName>hello</finalName>`.
- Integration tests (not needed to run the app) require the Docker daemon and
  `./mvnw clean verify`.
