# Stage 1: Build the Flutter Web app
FROM debian:latest AS build-env

# Set non-interactive mode
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter -b stable
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Mark flutter directory as safe for git
RUN git config --global --add safe.directory /usr/local/flutter

# Enable web and warm up flutter
RUN flutter config --no-analytics
RUN flutter config --enable-web
RUN flutter doctor

# Copy project files
WORKDIR /app
COPY . .

# Ensure dependencies are fetched correctly
RUN flutter pub get
RUN flutter build web --release

# Stage 2: Serve the app using Nginx
FROM nginx:alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Expose port 80 (Render's default)
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
