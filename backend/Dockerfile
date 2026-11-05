# Build Stage
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Cache dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code and package application
COPY src ./src
RUN mvn clean package -DskipTests

# Runtime Stage
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Add unprivileged user for security
RUN addgroup -S edlearn && adduser -S edlearn -G edlearn
USER edlearn:edlearn

# Copy compiled JAR from build stage
COPY --from=build /app/target/edlearn-backend-*.jar app.jar

# Render injects PORT dynamically (defaults to 5000 if not set)
ENV PORT=5000
EXPOSE 5000

# Run Spring Boot application
ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-Djava.net.preferIPv4Stack=true", "-jar", "app.jar"]

