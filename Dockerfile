# --- ETAPA 1: Construcción (Build) ---
FROM maven:3.9-eclipse-temurin-17-alpine AS builder
WORKDIR /app

# Copiar archivo pom.xml y descargar dependencias para aprovechar la caché de Docker
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copiar código fuente y compilar el JAR omitiendo pruebas
COPY src ./src
RUN mvn clean package -DskipTests -B

# --- ETAPA 2: Imagen de Ejecución (Runtime) ---
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Crear usuario sin privilegios por seguridad (buenas prácticas)
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Copiar el ejecutable generado en la etapa de compilación
COPY --from=builder /app/target/*.jar app.jar

# Usar el usuario sin privilegios
USER appuser:appgroup

# Exponer el puerto por defecto de Spring Boot
EXPOSE 8080

# Ejecutar la aplicación con soporte para límites de memoria en contenedores
ENTRYPOINT ["java", "-XX:+UseContainerSupport", "-XX:MaxRAMPercentage=75.0", "-jar", "app.jar"]
