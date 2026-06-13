# Multi-stage build for MediTracker Flutter Web App
# Stage 1: Build the Flutter web app
# Stage 2: Serve with nginx

# ---- Build Stage ----
FROM debian:bookworm-slim AS builder

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable /opt/flutter --depth 1
ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Pre-cache Flutter
RUN flutter precache --web
RUN flutter config --no-analytics

# Set working directory
WORKDIR /app

# Copy pubspec files first for dependency caching
COPY pubspec.yaml pubspec.lock ./

# Get dependencies
RUN flutter pub get

# Copy the rest of the source code
COPY . .

# Build the web app
RUN flutter build web --release --no-tree-shake-icons

# ---- Serve Stage ----
FROM nginx:alpine

# Copy built web files to nginx serve directory
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
