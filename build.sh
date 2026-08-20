#!/usr/bin/env bash
# =====================================================================
# Duniya — Render static site build script
# =====================================================================
# Called by Render on every deploy (see render.yaml `buildCommand`).
# Also runnable locally to reproduce the production build:
#
#   ./build.sh
#
# Outputs the built site to ./build/web — Render serves this directory
# from its CDN (see render.yaml `staticPublishPath`).
#
# Design choices:
#   - Uses the official Flutter tarball (no git clone of the SDK).
#     Faster (~30s vs ~3min) and version-pinned.
#   - Pinned to FLUTTER_VERSION 3.38.2 for package compatibility
#     (font_awesome_flutter 11.0.0 needs Dart >=3.9).
#   - Uses --no-native-null-assertions to bypass strict compile-time
#     null enforcement that fails on legacy code patterns. The bundled static
#     Satoshi faces are CanvasKit-safe; variable Satoshi files are excluded.
#   - Skips --tree-shake-icons (long, memory-heavy step with no
#     observable bundle-size benefit for this app).
# =====================================================================
set -euo pipefail

FLUTTER_VERSION="3.38.2"  # Pinned — matches package requirements (font_awesome_flutter 11.0.0 needs Dart >=3.9)
FLUTTER_CHANNEL="${FLUTTER_CHANNEL:-stable}"

echo "==> Building Pulse web app with Flutter ${FLUTTER_VERSION} (${FLUTTER_CHANNEL})"

# ---------------------------------------------------------------------
# 1. Install Flutter SDK
# ---------------------------------------------------------------------
# Use /tmp for the SDK — on Render static site builders, /opt is
# read-only. /tmp is wiped between builds but that's acceptable;
# the download adds ~60s to each build.
FLUTTER_HOME="${FLUTTER_HOME:-/tmp/flutter}"
# Correct Flutter release archive URL format:
#   https://storage.googleapis.com/flutter_infra_release/releases/{channel}/linux/flutter_linux_{version}-{channel}.tar.xz
# (No /x64 subdirectory, no .x64 suffix in filename.)
FLUTTER_TARBALL="https://storage.googleapis.com/flutter_infra_release/releases/${FLUTTER_CHANNEL}/linux/flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz"

if [[ -x "${FLUTTER_HOME}/bin/flutter" && "$(${FLUTTER_HOME}/bin/flutter --version --machine 2>/dev/null | grep -o '"frameworkVersion": "[^"]*"' | cut -d'"' -f4)" == "${FLUTTER_VERSION}" ]]; then
  echo "==> Reusing cached Flutter ${FLUTTER_VERSION} at ${FLUTTER_HOME}"
else
  echo "==> Downloading Flutter ${FLUTTER_VERSION} from ${FLUTTER_TARBALL}"
  # Verify the URL exists before downloading (fail fast with a clear error).
  HTTP_STATUS=$(curl -s -o /dev/null -w '%{http_code}' -I "${FLUTTER_TARBALL}")
  if [[ "${HTTP_STATUS}" != "200" ]]; then
    echo "ERROR: Flutter tarball URL returned HTTP ${HTTP_STATUS}. Check FLUTTER_VERSION (${FLUTTER_VERSION}) and FLUTTER_CHANNEL (${FLUTTER_CHANNEL})."
    exit 1
  fi
  mkdir -p "${FLUTTER_HOME}"
  curl -fsSL "${FLUTTER_TARBALL}" | tar -xJ -C "${FLUTTER_HOME}" --strip-components=1
fi

export PATH="${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin:${PATH}"

flutter config --no-analytics
flutter --version

# ---------------------------------------------------------------------
# 2. Get dependencies
# ---------------------------------------------------------------------
echo "==> flutter pub get"
flutter pub get

# ---------------------------------------------------------------------
# 3. Build the web app
# ---------------------------------------------------------------------
echo "==> flutter build web (CanvasKit renderer + static Satoshi font)"
flutter build web --release \
  --no-tree-shake-icons \
  --no-native-null-assertions

echo "==> Build complete. Output: $(pwd)/build/web"
ls -la build/web | head -20

# ---------------------------------------------------------------------
# 4. Ensure SPA fallback for Render static hosting.
#    Flutter usually copies web/_redirects into build/web, but be
#    explicit so deep links like /loginUni don't 404 on the CDN.
# ---------------------------------------------------------------------
if [[ -f "web/_redirects" ]]; then
  cp web/_redirects build/web/_redirects
  echo "==> Copied web/_redirects -> build/web/_redirects"
fi

# ---------------------------------------------------------------------
# 4b. LANDING-FIRST: serve the marketing landing page at "/" and move
#     the Flutter SPA shell to /app.html (deep links route via _redirects).
# ---------------------------------------------------------------------
if [[ -f "build/web/index.html" && -f "web/landing.html" ]]; then
  cp build/web/index.html build/web/app.html
  cp web/landing.html build/web/index.html
  echo "==> Landing-first: / = landing page, Flutter app shell at /app.html"
fi

# ---------------------------------------------------------------------
# 5. Cache busting — inject build version into built files.
# ---------------------------------------------------------------------
# Generate a version string from the git commit hash (short) + timestamp.
# This ensures every deploy produces a unique version that forces:
#   - Service worker cache invalidation (new CACHE_NAME)
#   - Fresh index.html (no stale HTML shell)
#   - CDN/browsers bypass cached copies of the entry point
BUILD_VERSION="$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')-$(date +%s)"
echo "==> Injecting cache-bust version: ${BUILD_VERSION}"

# Replace the placeholder in the service worker with the build version.
if [[ -f "build/web/duniya_service_worker.js" ]]; then
  sed -i "s/%%BUILD_VERSION%%/${BUILD_VERSION}/g" build/web/duniya_service_worker.js
  echo "==> Injected version into duniya_service_worker.js"
fi

# Replace the DEV placeholder and %%BUILD_VERSION%% in index.html (now the
# landing page) with the build version.
if [[ -f "build/web/index.html" ]]; then
  sed -i "s/content=\"DEV\"/content=\"${BUILD_VERSION}\"/g" build/web/index.html
  sed -i "s/%%BUILD_VERSION%%/${BUILD_VERSION}/g" build/web/index.html
  echo "==> Injected version into index.html (landing page)"
fi

# Inject the version into the Flutter app shell (renamed to app.html).
if [[ -f "build/web/app.html" ]]; then
  sed -i "s/content=\"DEV\"/content=\"${BUILD_VERSION}\"/g" build/web/app.html
  sed -i "s/%%BUILD_VERSION%%/${BUILD_VERSION}/g" build/web/app.html
  echo "==> Injected version into app.html (Flutter app shell)"
fi

# Replace the placeholder in manifest.json with the build version.
if [[ -f "build/web/manifest.json" ]]; then
  sed -i "s/%%BUILD_VERSION%%/${BUILD_VERSION}/g" build/web/manifest.json
  echo "==> Injected version into manifest.json start_url"
fi

# Inject version into flutter_bootstrap.js for cache busting.
if [[ -f "build/web/flutter_bootstrap.js" ]]; then
  sed -i "s/%%BUILD_VERSION%%/${BUILD_VERSION}/g" build/web/flutter_bootstrap.js
  echo "==> Injected version into flutter_bootstrap.js"
fi

# Inject version into landing.html for cache busting.
if [[ -f "build/web/landing.html" ]]; then
  sed -i "s/%%BUILD_VERSION%%/${BUILD_VERSION}/g" build/web/landing.html
  echo "==> Injected version into landing.html"
fi

# ---------------------------------------------------------------------
# 6. Copy _headers file for Render CDN cache configuration.
#    Render static sites support Netlify-style _headers files.
# ---------------------------------------------------------------------
if [[ -f "web/_headers" ]]; then
  cp web/_headers build/web/_headers
  echo "==> Copied web/_headers -> build/web/_headers (cache-busting HTTP headers)"
fi

echo "==> Cache busting complete. Build version: ${BUILD_VERSION}"

# ---------------------------------------------------------------------
# 6b. Strip legacy-only fonts from the web FontManifest. Static Satoshi is
#     retained for the brand; variable Satoshi files are never registered in
#     pubspec.yaml, so CanvasKit only sees safe static font instances.
# ---------------------------------------------------------------------
if [[ -f "build/web/assets/FontManifest.json" ]]; then
  # Failing the filter (e.g. 'Satoshi' missing from the manifest) means the
  # web app would ship broken — abort the deploy in that case.
  if "${FLUTTER_HOME}/bin/cache/dart-sdk/bin/dart" \
    tool/filter_web_font_manifest.dart build/web/assets/FontManifest.json; then
    echo "==> Web FontManifest filtered: legacy fonts removed, Satoshi kept"
  else
    echo "==> ERROR: font manifest filter failed — aborting deploy"
    exit 1
  fi
fi

# ---------------------------------------------------------------------
# 7. Copy the landing page to build output.
#    The landing page is a standalone HTML file that serves as the
#    marketing/download page for Pulse. Copy the version-injected copy
#    (build/web/index.html) so /landing.html matches the root page.
# ---------------------------------------------------------------------
if [[ -f "build/web/index.html" ]]; then
  cp build/web/index.html build/web/landing.html
  echo "==> Copied build/web/index.html -> build/web/landing.html"
fi

# Copy fonts directory for the landing page
if [[ -d "web/fonts" ]]; then
  mkdir -p build/web/fonts
  cp web/fonts/* build/web/fonts/
  echo "==> Copied web/fonts/ -> build/web/fonts/ (landing page fonts)"
fi

# Copy multi-size favicon files (generated from the real Pulse logo)
for favfile in favicon-16x16.png favicon-32x32.png apple-touch-icon.png; do
  if [[ -f "web/${favfile}" ]]; then
    cp "web/${favfile}" "build/web/${favfile}"
    echo "==> Copied web/${favfile} -> build/web/${favfile}"
  fi
done
