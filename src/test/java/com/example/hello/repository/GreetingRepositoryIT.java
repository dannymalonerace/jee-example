package com.example.hello.repository;

import com.example.hello.entity.Greeting;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import org.flywaydb.core.Flyway;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.testcontainers.containers.MySQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.time.Instant;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.assertj.core.api.Assertions.assertThat;

@Testcontainers
class GreetingRepositoryIT {

    @Container
    static MySQLContainer<?> mysql = new MySQLContainer<>("mysql:8.0")
            .withDatabaseName("hello")
            .withUsername("hello")
            .withPassword("hello");

    static EntityManagerFactory emf;

    @BeforeAll
    static void setUp() {
        Flyway.configure()
                .dataSource(mysql.getJdbcUrl(), mysql.getUsername(), mysql.getPassword())
                .locations("classpath:db/migration")
                .load()
                .migrate();

        Map<String, String> props = new HashMap<>();
        props.put("jakarta.persistence.jdbc.url", mysql.getJdbcUrl());
        props.put("jakarta.persistence.jdbc.user", mysql.getUsername());
        props.put("jakarta.persistence.jdbc.password", mysql.getPassword());
        emf = Persistence.createEntityManagerFactory("helloPU-test", props);
    }

    @AfterAll
    static void tearDown() {
        if (emf != null) {
            emf.close();
        }
    }

    @BeforeEach
    void truncate() {
        runInTx(em -> em.createNativeQuery("TRUNCATE TABLE greetings").executeUpdate());
    }

    @Test
    void saves_and_loads_a_greeting() {
        Greeting saved = runInTx(em -> {
            GreetingRepository repo = new GreetingRepository(em);
            return repo.save(new Greeting("Ada", "Hello"));
        });

        assertThat(saved.getId()).isNotNull();
        assertThat(saved.getCreatedAt()).isNotNull();

        List<Greeting> all = runInTx(em -> new GreetingRepository(em).findAllNewestFirst());
        assertThat(all).hasSize(1);
        assertThat(all.get(0).getName()).isEqualTo("Ada");
        assertThat(all.get(0).getMessage()).isEqualTo("Hello");
    }

    @Test
    void orders_results_newest_first() throws InterruptedException {
        runInTx(em -> new GreetingRepository(em).save(new Greeting("first", "msg-1")));
        Thread.sleep(10);
        runInTx(em -> new GreetingRepository(em).save(new Greeting("second", "msg-2")));
        Thread.sleep(10);
        runInTx(em -> new GreetingRepository(em).save(new Greeting("third", "msg-3")));

        List<Greeting> all = runInTx(em -> new GreetingRepository(em).findAllNewestFirst());

        assertThat(all).extracting(Greeting::getName)
                .containsExactly("third", "second", "first");
    }

    @Test
    void auto_populates_created_at_when_unset() {
        Instant before = Instant.now().minusSeconds(1);
        Greeting saved = runInTx(em -> new GreetingRepository(em).save(new Greeting("Bob", "hi")));
        Instant after = Instant.now().plusSeconds(1);

        assertThat(saved.getCreatedAt()).isBetween(before, after);
    }

    interface Tx<T> {
        T run(EntityManager em);
    }

    static <T> T runInTx(Tx<T> work) {
        EntityManager em = emf.createEntityManager();
        try {
            em.getTransaction().begin();
            T result = work.run(em);
            em.getTransaction().commit();
            return result;
        } catch (RuntimeException e) {
            if (em.getTransaction().isActive()) em.getTransaction().rollback();
            throw e;
        } finally {
            em.close();
        }
    }
}
