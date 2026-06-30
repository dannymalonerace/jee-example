.PHONY: build test test-unit test-it up down restart logs clean smoke help

help:
	@echo "Targets:"
	@echo "  build      Build the WAR (skips tests)"
	@echo "  test       Run mvn clean verify (unit + integration tests, JaCoCo gate)"
	@echo "  test-unit  Run unit tests only (mvn test)"
	@echo "  test-it    Run integration tests only (mvn verify -DskipUTs is not used; this just runs verify)"
	@echo "  up         docker compose up --build -d"
	@echo "  down       docker compose down"
	@echo "  restart    docker compose down + up"
	@echo "  logs       Tail wildfly container logs"
	@echo "  smoke      curl http://localhost:8080/hello/ and assert HTTP 200"
	@echo "  clean      mvn clean + docker compose down -v (drops mysql volume)"

build:
	./mvnw -DskipTests package

test:
	./mvnw clean verify

test-unit:
	./mvnw test

test-it:
	./mvnw verify

up:
	docker compose up --build -d

down:
	docker compose down

restart: down up

logs:
	docker compose logs -f wildfly

smoke:
	@echo "Waiting for /hello/ ..."
	@for i in $$(seq 1 60); do \
		if curl -fsS -o /dev/null http://localhost:8080/hello/; then \
			echo "OK"; exit 0; \
		fi; \
		sleep 2; \
	done; \
	echo "FAILED"; exit 1

clean:
	./mvnw clean
	docker compose down -v
