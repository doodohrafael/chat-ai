# Etapa 1: Build
FROM eclipse-temurin:25-jdk-jammy AS build
WORKDIR /app

# Copia os arquivos de configuração do Maven Wrapper
COPY .mvn/ .mvn
COPY mvnw pom.xml ./
# Garante que o script mvnw tenha permissão de execução
RUN chmod +x mvnw

# Baixa as dependências (camada de cache)
RUN ./mvnw dependency:go-offline -B

# Copia o código e compila
COPY src ./src
RUN ./mvnw clean package -DskipTests

# Etapa 2: Runtime
FROM eclipse-temurin:25-jre-jammy
WORKDIR /app

ENV SPRING_AI_VERTEX_AI_GEMINI_LOCATION="us-east4"

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8081
ENTRYPOINT ["java", \
            "--enable-native-access=ALL-UNNAMED", \
            "--add-opens=java.base/jdk.internal.misc=ALL-UNNAMED", \
            "-jar", "app.jar", "--server.port=8081"]