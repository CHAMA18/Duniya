# Multi-stage Dockerfile for the Duniya Flutter Web App.
#
# Optimisations vs. the previous version:
#   1. Pinned Flutter image (no git clone of the SDK — saves ~1 GB and
#      removes a flaky network dependency from the build).
#   2. pubspec.* copied before the rest of the source, so `flutter pub get`
#      is cached unless deps change.
#   3. `--no-tree-shake-icons --web-renderer html` keeps the build RAM
#      usage under ~1.5 GB (canvaskit builds of this app OOM at 512 MB,
#      which is Render free-tier build limit).
#   4. Final stage is just nginx:alpine serving /usr/share/nginx/html —
#      ~10 MB image. No Flutter SDK shipped to runtime.
#
# This Dockerfile is now a FALLBACK. The recommended Render setup is the
# "Static Site" service type in render.yaml — it has no instance-hour
# limit. Use this Dockerfile only if you need the Docker runtime.

# ---- Build Stage ----
FROM ghcr.io/cirruslabs/flutter:3.24.5 AS builder

# Disable analytics telemetry during build.
RUN flutter config --no-analytics

WORKDIR /app

# Copy pubspec first for dependency caching. If pubspec.* haven't changed,
# Docker reuses the cached `pub get` layer — saves ~30-60s per rebuild.
COPY pubspec.yaml pubspec.lock ./

RUN flutter pub get

# Now copy the rest of the source (the .dockerignore already excluded
# skills/, upload/, ios/, android/, .git/, etc.).
COPY . .

# Build the web app.
#   --release              optimised build
#   --no-tree-shake-icons  avoids the long icon-tree-shaking step that
#                          frequently OOMs on constrained builders
#   --web-renderer html    lighter renderer, smaller bundle, lower build
#                          RAM (~1.5 GB vs ~3 GB for canvaskit)
RUN flutter build web --release \
      --no-tree-shake-icons \
      --web-renderer html \
      --dart-define=FLUTTER_WEB_USE_SKIA=false

# ---- Serve Stage ----
FROM nginx:alpine

# Copy built web files to nginx serve directory
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
