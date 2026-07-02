# ==========================
# Étape 1 : tests
# ==========================
FROM gradle:9.1.0-jdk-25-and-25 AS test

COPY --chown=gradle:gradle . /home/gradle/src
WORKDIR /home/gradle/src

CMD ["gradle", "test", "--no-daemon"]

# ==========================
# Étape 2 : build
# ==========================
FROM gradle:9.1.0-jdk-25-and-25 AS build

COPY --from=test /home/gradle/src /home/gradle/src
WORKDIR /home/gradle/src

RUN gradle bootJar --no-daemon

# ==========================
# Étape 3 : production
# ==========================
FROM eclipse-temurin:25-jre AS prod

WORKDIR /app

COPY --from=build /home/gradle/src/build/libs/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]