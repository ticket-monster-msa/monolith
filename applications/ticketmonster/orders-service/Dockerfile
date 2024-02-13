# Use a base image with Java 11 and Maven installed
FROM maven:3.8.4-openjdk-11 AS builder

WORKDIR /build

# Copy over files
COPY src ./src
COPY pom.xml .

# Build the application
RUN mvn clean package -DskipTests

# Use a base image with Java 11 and WildFly
FROM jboss/wildfly:23.0.2.Final

# Set the environment variables
ENV DEPLOYMENT_DIR /opt/jboss/wildfly/standalone/deployments/
ENV APP_NAME orders-service-1.0.0-SNAPSHOT.jar

# orders-service-1.0.0-SNAPSHOT.jar
# orders-service-1.0.0-SNAPSHOT-exec.jar

# Copy the application WAR file to the deployment directory
COPY --from=builder /build/target/${APP_NAME} ${DEPLOYMENT_DIR}

USER root

RUN yum update -y && yum install -y wget
# RUN apt-get update && apt-get install -y wget
# Install Java Profiler Agent
RUN wget https://www.yourkit.com/download/docker/YourKit-JavaProfiler-2023.5-docker.zip -P /tmp/ && \
  unzip /tmp/YourKit-JavaProfiler-2023.5-docker.zip -d /usr/local && \
  rm /tmp/YourKit-JavaProfiler-2023.5-docker.zip

ENV JAVA_OPTS="$JAVA_OPTS -agentpath:/usr/local/YourKit-JavaProfiler-2023.5/bin/linux-x86-64/libyjpagent.so=port=10001,listen=all"

USER jboss

# Expose the default HTTP port
# EXPOSE 8080 10001

# Start WildFly in standalone mode
CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0"]
# CMD ["/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-agentpath:/usr/local/YourKit-JavaProfiler-2023.5/bin/linux-x86-64/libyjpagent.so=port=10001,listen=all"]

 
# # For debugging
# ENTRYPOINT ["tail"]
# CMD ["-f","/dev/null"]