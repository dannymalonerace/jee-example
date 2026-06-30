package com.example.hello.boot;

import jakarta.annotation.PostConstruct;
import jakarta.annotation.Resource;
import jakarta.ejb.Singleton;
import jakarta.ejb.Startup;
import jakarta.ejb.TransactionManagement;
import jakarta.ejb.TransactionManagementType;
import org.flywaydb.core.Flyway;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.sql.DataSource;

@Singleton
@Startup
@TransactionManagement(TransactionManagementType.BEAN)
public class FlywayBootstrap {

    private static final Logger log = LoggerFactory.getLogger(FlywayBootstrap.class);

    @Resource(lookup = "java:/jdbc/HelloDS")
    private DataSource dataSource;

    @PostConstruct
    void migrate() {
        log.info("Running Flyway migrations against java:/jdbc/HelloDS");
        int applied = Flyway.configure()
                .dataSource(dataSource)
                .locations("classpath:db/migration")
                .load()
                .migrate()
                .migrationsExecuted;
        log.info("Flyway applied {} migration(s)", applied);
    }
}
