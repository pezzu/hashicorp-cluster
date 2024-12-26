# Stage 1: Build the application
FROM maven:3.8.5-openjdk-17-slim AS builder

# Set the working directory in the container
WORKDIR /build

# Copy the Maven project files into the container
COPY pom.xml /build/
COPY src /build/src/

# Build the JAR file using Maven
RUN mvn clean package -DskipTests

# Stage 2: Create the runtime image
FROM openjdk:17-jdk-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the JAR file from the builder stage
COPY --from=builder /build/target/web-app.jar /app/web-app.jar

# Expose port 8080
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "web-app.jar"]
