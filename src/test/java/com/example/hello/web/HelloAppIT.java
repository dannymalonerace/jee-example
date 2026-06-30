package com.example.hello.web;

import io.restassured.RestAssured;
import io.restassured.config.RedirectConfig;
import io.restassured.config.RestAssuredConfig;
import io.restassured.response.Response;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.testcontainers.containers.GenericContainer;
import org.testcontainers.containers.MySQLContainer;
import org.testcontainers.containers.Network;
import org.testcontainers.containers.wait.strategy.Wait;
import org.testcontainers.images.builder.ImageFromDockerfile;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.utility.MountableFile;

import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.Duration;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.containsString;

@Testcontainers
class HelloAppIT {

    static final Network NETWORK = Network.newNetwork();
    static final String DB_NAME = "hello";
    static final String DB_USER = "hello";
    static final String DB_PASS = "hello";

    @Container
    static MySQLContainer<?> mysql = new MySQLContainer<>("mysql:8.0")
            .withNetwork(NETWORK)
            .withNetworkAliases("mysql")
            .withDatabaseName(DB_NAME)
            .withUsername(DB_USER)
            .withPassword(DB_PASS);

    @Container
    static GenericContainer<?> wildfly = new GenericContainer<>(
            new ImageFromDockerfile("hello-app-it", false)
                    .withFileFromPath(".", projectRoot()))
            .withNetwork(NETWORK)
            .withNetworkAliases("wildfly")
            .withEnv("DB_URL", "jdbc:mysql://mysql:3306/" + DB_NAME
                    + "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC")
            .withEnv("DB_USER", DB_USER)
            .withEnv("DB_PASSWORD", DB_PASS)
            .withExposedPorts(8080)
            .waitingFor(Wait.forHttp("/hello/").forStatusCode(200)
                    .withStartupTimeout(Duration.ofMinutes(3)))
            .dependsOn(mysql);

    static String baseUrl;

    @BeforeAll
    static void configureRestAssured() {
        baseUrl = "http://" + wildfly.getHost() + ":" + wildfly.getMappedPort(8080) + "/hello";
        RestAssured.config = RestAssuredConfig.config()
                .redirect(RedirectConfig.redirectConfig().followRedirects(false));
    }

    static Path projectRoot() {
        Path here = Paths.get("").toAbsolutePath();
        return here;
    }

    @Test
    void home_returns_200_and_says_hello() {
        Response r = RestAssured.given().get(baseUrl + "/");
        assertThat(r.statusCode()).isEqualTo(200);
        assertThat(r.asString()).contains("Hello, World");
    }

    @Test
    void greetings_list_returns_200() {
        Response r = RestAssured.given().get(baseUrl + "/greetings");
        assertThat(r.statusCode()).isEqualTo(200);
        assertThat(r.asString()).containsIgnoringCase("greetings");
    }

    @Test
    void post_new_greeting_redirects_then_appears_in_list() {
        Response post = RestAssured.given()
                .contentType("application/x-www-form-urlencoded")
                .formParam("name", "Ada-" + System.currentTimeMillis())
                .formParam("message", "Hello from the IT")
                .post(baseUrl + "/greetings/new");

        assertThat(post.statusCode()).isEqualTo(302);
        assertThat(post.getHeader("Location")).endsWith("/hello/greetings");

        Response list = RestAssured.given().get(baseUrl + "/greetings");
        assertThat(list.statusCode()).isEqualTo(200);
        assertThat(list.asString()).contains("Hello from the IT");
    }

    @Test
    void post_blank_name_renders_validation_error_and_preserves_message() {
        String preserved = "preserve-me-" + System.currentTimeMillis();
        Response r = RestAssured.given()
                .contentType("application/x-www-form-urlencoded")
                .formParam("name", "")
                .formParam("message", preserved)
                .post(baseUrl + "/greetings/new");

        assertThat(r.statusCode()).isEqualTo(400);
        String body = r.asString();
        org.hamcrest.MatcherAssert.assertThat(body, containsString("data-field=\"name\""));
        assertThat(body).contains(preserved);
    }
}
