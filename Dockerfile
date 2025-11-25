# l'ancien

## Builder stage
#FROM openjdk:17-jdk-slim as builder
#WORKDIR application
#ARG JAR_FILE=target/*.jar
#COPY ${JAR_FILE} application.jar
#RUN java -Djarmode=layertools -jar application.jar extract
#
## Final stage
#FROM openjdk:17-jdk-slim
#WORKDIR application
#COPY --from=builder application/dependencies/ ./
#COPY --from=builder application/spring-boot-loader/ ./
#COPY --from=builder application/snapshot-dependencies/ ./
#COPY --from=builder application/application/ ./
#ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]
#EXPOSE 8080
#EXPOSE 5005


# to fix the openjdk problem
## Builder stage
#FROM maven:3.9.6-eclipse-temurin-17 AS builder
#WORKDIR /app
#ARG JAR_FILE=target/*.jar
#COPY ${JAR_FILE} application.jar
#RUN java -Djarmode=layertools -jar application.jar extract
#
## Final stage
#FROM eclipse-temurin:17-jdk AS runtime
#WORKDIR /app
#COPY --from=builder /app/dependencies/ ./
#COPY --from=builder /app/spring-boot-loader/ ./
#COPY --from=builder /app/snapshot-dependencies/ ./
#COPY --from=builder /app/application/ ./
#ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]
#EXPOSE 8080


# ----------------------
# Stage 1 : Builder avec Maven
# ----------------------
FROM maven:3.9.6-eclipse-temurin-17 AS builder

# Dossier de travail
WORKDIR /app

# Copier les fichiers pom.xml et sources
COPY pom.xml .
COPY src ./src

# Build du projet et création du JAR
RUN mvn clean package -DskipTests -Dcheckstyle.skip


# ----------------------
# Stage 2 : Runtime
# ----------------------
FROM eclipse-temurin:17-jdk

WORKDIR /app

# Copier le JAR depuis le builder
COPY --from=builder /app/target/*.jar app.jar

# Port exposé
EXPOSE 8080

# Commande pour démarrer l'application
ENTRYPOINT ["java","-jar","app.jar"]





# first one suggested by gpt
## Étape 1 : builder
#FROM maven:3.9.6-eclipse-temurin-17 AS build
#WORKDIR /app
#
## Copier uniquement le pom pour optimiser le cache
#COPY pom.xml .
#RUN mvn -q -e -B dependency:go-offline
#
## Copier tout le projet
#COPY . .
#
## Générer le .jar
#RUN mvn -q -e -B package -DskipTests
#
## Étape 2 : image finale légère
#FROM eclipse-temurin:17-jdk
#WORKDIR /app
#
## Copier le jar construit
#COPY --from=build /app/target/*.jar app.jar
#
## Exposer le port Spring Boot
#EXPOSE 8080
#
## Démarrer l'application
#ENTRYPOINT ["java", "-jar", "app.jar"]
