# -------------------------
# Étape 1 : Builder Spring Boot
# -------------------------
FROM eclipse-temurin:21-jdk AS builder-spring
WORKDIR /app
COPY civilink/ ./civilink/
WORKDIR /app/civilink
RUN ./mvnw clean package -DskipTests

# -------------------------
# Étape 2 : Builder Flutter Web
# -------------------------
FROM ghcr.io/cirruslabs/flutter:stable AS builder-flutter

WORKDIR /app

# Copier le frontend
COPY mon-quartier-vigilant-main-1/mon-quartier-vigilant-main/ ./flutter_app/

WORKDIR /app/flutter_app

# Récupérer les dépendances et build Web
RUN flutter pub get
RUN flutter build web --release

# -------------------------
# Étape 3 : Image finale
# -------------------------
FROM eclipse-temurin:21-jdk-alpine
WORKDIR /app

# Copier backend Spring Boot
COPY --from=builder-spring /app/civilink/target/civilink-0.0.1-SNAPSHOT.jar ./app.jar

# Copier frontend Flutter Web
COPY --from=builder-flutter /app/flutter_app/build/web ./frontend

# Expose port
EXPOSE 8080

# Run app
CMD ["java", "-jar", "app.jar"]