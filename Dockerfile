# ==========================
# Étape 1 : Base & Dépendances (pour mettre en cache les Jars)
# ==========================
FROM gradle:9.1.0-jdk-25-and-25 AS cache
WORKDIR /home/gradle/src
COPY build.gradle settings.gradle /home/gradle/src/
# On télécharge les dépendances en amont pour profiter du cache Docker
RUN gradle dependencies --no-daemon || true

# ==========================
# Étape 2 : tests
# ==========================
FROM cache AS test
COPY --chown=gradle:gradle . /home/gradle/src
# 💡 Remplacement de CMD par RUN pour forcer l'exécution des tests au build
RUN gradle test --no-daemon

# ==========================
# Étape 3 : build
# ==========================
FROM cache AS build
COPY --chown=gradle:gradle . /home/gradle/src
# 💡 On build l'application (tu peux ajouter -x test si tu considères que l'étape précédente suffit)
RUN gradle bootJar --no-daemon -x test

# ==========================
# Étape 4 : production
# ==========================
FROM eclipse-temurin:25-jre AS prod
WORKDIR /app
COPY --from=build /home/gradle/src/build/libs/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]