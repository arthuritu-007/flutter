# Stage 1: Build the Flutter Web app
# Usamos una imagen pre-construida de Flutter para evitar clonar todo el SDK
FROM ghcr.io/cirruslabs/flutter:stable AS build-env

# Establecemos el directorio de trabajo
WORKDIR /app

# Copiamos primero los archivos de dependencias para aprovechar la caché de Docker
COPY pubspec.yaml ./

# Obtenemos las dependencias
RUN flutter pub get

# Ahora copiamos el resto de los archivos del proyecto
COPY . .

# Compilamos para web
RUN flutter build web --release

# Stage 2: Servir la app usando Nginx
FROM nginx:alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Exponer el puerto 80
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
