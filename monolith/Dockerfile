# Use a base image with Java 11 and Maven installed
FROM maven:3.8.4-openjdk-11 AS builder

WORKDIR /build

# Copy over files
COPY src ./src
COPY pom.xml .

# Build the application
RUN mvn clean package

# Use a base image with Java 11 and WildFly
FROM jboss/wildfly:23.0.2.Final

# Set the environment variables
ENV DEPLOYMENT_DIR /opt/jboss/wildfly/standalone/deployments/
ENV APP_NAME ticket-monster.war

# Copy the application WAR file to the deployment directory
COPY --from=builder /build/target/${APP_NAME} ${DEPLOYMENT_DIR}

# Expose the default HTTP port
EXPOSE 8080

# Start WildFly in standalone mode
CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]

# For debugging
# ENTRYPOINT ["tail"]
# CMD ["-f","/dev/null"]