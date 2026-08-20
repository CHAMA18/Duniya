#!/usr/bin/env bash
# =====================================================================
# Pulse — Build macOS Desktop App
# =====================================================================
# Builds a macOS .app bundle and .dmg for Pulse.
#
# Prerequisites:
#   - Flutter SDK 3.24+ with macOS desktop support enabled
#   - Xcode 14+ with Command Line Tools
#   - CocoaPods
#
# Usage:
#   ./build_macos.sh
#
# Output:
#   ./build/macos/Build/Products/Release/ — the compiled .app
#   ./release/Pulse.dmg — the disk image
# =====================================================================
set -euo pipefail

APP_NAME="Pulse"
APP_VERSION="$(grep 'version:' pubspec.yaml | head -1 | awk '{print $2}' | cut -d'+' -f1)"
BUILD_DIR="build/macos/Build/Products/Release"
RELEASE_DIR="release"

echo "==> Building ${APP_NAME} v${APP_VERSION} for macOS"

# ---------------------------------------------------------------------
# 1. Ensure Flutter is available
# ---------------------------------------------------------------------
if ! command -v flutter &> /dev/null; then
  echo "ERROR: Flutter SDK not found. Install Flutter 3.24+ and add to PATH."
  exit 1
fi

# Enable macOS desktop support
flutter config --enable-macos-desktop

# ---------------------------------------------------------------------
# 2. Get dependencies
# ---------------------------------------------------------------------
echo "==> flutter pub get"
flutter pub get

# ---------------------------------------------------------------------
# 3. Install CocoaPods
# ---------------------------------------------------------------------
echo "==> pod install"
cd macos
pod install --repo-update 2>/dev/null || true
cd ..

# ---------------------------------------------------------------------
# 4. Build the macOS app
# ---------------------------------------------------------------------
echo "==> flutter build macos"
flutter build macos --release \
  --build-name="${APP_VERSION}" \
  --build-number="$(date +%s)"

echo "==> Build complete. Output: ${BUILD_DIR}"
ls -la "${BUILD_DIR}"

# ---------------------------------------------------------------------
# 5. Create release directory
# ---------------------------------------------------------------------
mkdir -p "${RELEASE_DIR}"

# ---------------------------------------------------------------------
# 6. Copy .app bundle
# ---------------------------------------------------------------------
echo "==> Copying .app bundle"
cp -R "${BUILD_DIR}/${APP_NAME}.app" "${RELEASE_DIR}/"

# ---------------------------------------------------------------------
# 7. Create DMG (if hdiutil is available)
# ---------------------------------------------------------------------
if command -v hdiutil &> /dev/null; then
  echo "==> Creating DMG"
  hdiutil create -volname "${APP_NAME}" \
    -srcfolder "${RELEASE_DIR}/${APP_NAME}.app" \
    -ov -format UDZO \
    "${RELEASE_DIR}/${APP_NAME}.dmg"

  echo "==> DMG created: ${RELEASE_DIR}/${APP_NAME}.dmg"
else
  echo "==> hdiutil not found (not on macOS?). Skipping DMG creation."
  echo "    Run this script on macOS to create .dmg files."
fi

echo "==> macOS build complete!"
echo "    Release files in: ${RELEASE_DIR}/"
ls -la "${RELEASE_DIR}/"
