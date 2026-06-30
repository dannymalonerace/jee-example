# syntax=docker/dockerfile:1.7

# ---------- Stage 1: build the WAR ----------
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /workspace

COPY pom.xml ./
RUN mvn -B -q -DskipTests dependency:go-offline || true

COPY src ./src
RUN mvn -B -q -DskipTests package

# ---------- Stage 2: WildFly with datasource baked in ----------
FROM quay.io/wildfly/wildfly:30.0.1.Final-jdk17

ARG MYSQL_DRIVER_VERSION=8.4.0
USER root

# Install MySQL JDBC driver as a JBoss module
RUN mkdir -p $JBOSS_HOME/modules/com/mysql/jdbc/main && \
    curl -fsSL -o $JBOSS_HOME/modules/com/mysql/jdbc/main/mysql-connector-j.jar \
        https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/${MYSQL_DRIVER_VERSION}/mysql-connector-j-${MYSQL_DRIVER_VERSION}.jar

COPY docker/modules/com/mysql/jdbc/main/module.xml $JBOSS_HOME/modules/com/mysql/jdbc/main/module.xml
COPY docker/datasource.cli /tmp/datasource.cli

# Bake the driver + datasource into standalone.xml.
# The CLI references ${env.DB_URL} etc., resolved at runtime.
RUN $JBOSS_HOME/bin/jboss-cli.sh --file=/tmp/datasource.cli \
    && rm /tmp/datasource.cli \
    && rm -rf $JBOSS_HOME/standalone/configuration/standalone_xml_history \
    && chown -R jboss:0 $JBOSS_HOME && chmod -R g+rw $JBOSS_HOME

# Deploy the WAR
COPY --from=build /workspace/target/hello.war $JBOSS_HOME/standalone/deployments/hello.war

USER jboss
EXPOSE 8080 9990

CMD ["/opt/jboss/wildfly/bin/standalone.sh", \
     "-b", "0.0.0.0", \
     "-bmanagement", "0.0.0.0"]
