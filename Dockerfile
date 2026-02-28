# Stage 1: Build the Flutter Web app
FROM ubuntu:20.04 AS build-env

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter -b stable
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Enable web
RUN flutter config --enable-web

# Copy project files
WORKDIR /app
COPY . .

# Build the project
RUN flutter pub get
RUN flutter build web --release

# Stage 2: Serve the app using Nginx
FROM nginx:alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Expose port 80 (Render's default)
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
