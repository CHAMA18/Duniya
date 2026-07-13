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
#   - Pinned to FLUTTER_VERSION (default 3.24.5) for reproducibility.
#   - Uses --web-renderer html — the canvaskit build of this app OOMs
#     on Render's 512 MB free-tier builders.
#   - Skips --tree-shake-icons (long, memory-heavy step with no
#     observable bundle-size benefit for this app).
# =====================================================================
set -euo pipefail

FLUTTER_VERSION="${FLUTTER_VERSION:-3.24.5}"
FLUTTER_CHANNEL="${FLUTTER_CHANNEL:-stable}"

echo "==> Building Duniya web app with Flutter ${FLUTTER_VERSION} (${FLUTTER_CHANNEL})"

# ---------------------------------------------------------------------
# 1. Install Flutter SDK (cached on Render via /opt/render-cache)
# ---------------------------------------------------------------------
FLUTTER_HOME="${FLUTTER_HOME:-/opt/render-cache/flutter}"
FLUTTER_TARBALL="https://storage.googleapis.com/flutter_infra_release/releases/${FLUTTER_CHANNEL}/${FLUTTER_PLATFORM:-linux}/${FLUTTER_ARCH:-x64}/flutter_${FLUTTER_PLATFORM:-linux}_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.${FLUTTER_ARCH:-x64}.tar.xz"

if [[ -x "${FLUTTER_HOME}/bin/flutter" && "$(${FLUTTER_HOME}/bin/flutter --version --machine 2>/dev/null | grep -o '"frameworkVersion": "[^"]*"' | cut -d'"' -f4)" == "${FLUTTER_VERSION}" ]]; then
  echo "==> Reusing cached Flutter ${FLUTTER_VERSION} at ${FLUTTER_HOME}"
else
  echo "==> Downloading Flutter ${FLUTTER_VERSION} from ${FLUTTER_TARBALL}"
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
echo "==> flutter build web"
flutter build web --release \
  --no-tree-shake-icons \
  --web-renderer html \
  --dart-define=FLUTTER_WEB_USE_SKIA=false

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
