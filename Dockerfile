


# Stage 1 : Builder avec Maven
FROM maven:3.9.6-eclipse-temurin-17 AS builder
# Dossier de travail
WORKDIR /app
# Copier les fichiers pom.xml et sources
COPY pom.xml .
COPY src ./src
# Build du projet et création du JAR
RUN mvn clean package -DskipTests -Dcheckstyle.skip

# Stage 2 : Runtime
FROM eclipse-temurin:17-jdk
WORKDIR /app
# Copier le JAR depuis le builder
COPY --from=builder /app/target/*.jar app.jar
# Port exposé
EXPOSE 8080
# Commande pour démarrer l'application
ENTRYPOINT ["java","-jar","app.jar"]


