# Use a base image with Java 11 and Maven installed
FROM maven:3.8.4-openjdk-11 AS builder

# Copy over files
COPY src .
COPY pom.xml

# Build the application
RUN mvn clean package

# Use a base image with Java 11 and WildFly
FROM jboss/wildfly:25.0.1.Final

# Set the environment variables
ENV DEPLOYMENT_DIR /opt/jboss/wildfly/standalone/deployments/
ENV APP_NAME ticket-monster.war

# Copy the application WAR file to the deployment directory
COPY --from=builder target/${APP_NAME} ${DEPLOYMENT_DIR}

# Expose the default HTTP port
EXPOSE 8080

# Start WildFly in standalone mode
CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]
