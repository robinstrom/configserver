FROM adoptopenjdk:16-jdk-hotspot as builder
ARG USER_ID
WORKDIR application
COPY src ./src
COPY gradlew ./gradlew
COPY gradle ./gradle
COPY build.gradle ./build.gradle
COPY settings.gradle ./settings.gradle
COPY .gradle ./.gradle
RUN --mount=type=cache,target=/root/.gradle ./gradlew build
RUN chown -R ${USER_ID} /application && chown -R ${USER_ID} /root/.gradle
USER ${USER_ID}
RUN java -Djarmode=layertools -jar build/libs/configserver.jar extract

FROM adoptopenjdk:16-jre-hotspot
USER ${USER_ID}
WORKDIR application
COPY --from=builder application/dependencies/ ./
COPY --from=builder application/snapshot-dependencies/ ./
COPY --from=builder application/spring-boot-loader/ ./
COPY --from=builder application/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]