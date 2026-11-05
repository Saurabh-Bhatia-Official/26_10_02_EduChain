# ==========================================
# EduChain Backend - Multi-stage Dockerfile
# ==========================================

# 1. Build Stage
FROM maven:3.9.6-eclipse-temurin-17 AS build
WORKDIR /app

# Cache Maven dependencies
COPY backend/pom.xml .
RUN mvn dependency:go-offline -B

# Copy backend source and compile production JAR
COPY backend/src ./src
RUN mvn clean package -DskipTests

# 2. Runtime Stage
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Create unprivileged application user
RUN addgroup -S edlearn && adduser -S edlearn -G edlearn
USER edlearn:edlearn

# Copy compiled JAR artifact
COPY --from=build /app/target/edlearn-backend-*.jar app.jar

# Dynamic port binding for Render (defaults to 5000)
ENV PORT=5000
EXPOSE 5000

# Execute Spring Boot backend
ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-Djava.net.preferIPv4Stack=true", "-jar", "app.jar"]
