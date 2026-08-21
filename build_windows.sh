#!/usr/bin/env bash
# =====================================================================
# Pulse — Build Windows Desktop App
# =====================================================================
# Builds a Windows .exe installer for Pulse.
#
# Prerequisites:
#   - Flutter SDK 3.24+ with Windows desktop support enabled
#   - Visual Studio 2022 with C++ desktop development workload
#   - Inno Setup 6 (for creating the installer)
#
# Usage:
#   ./build_windows.sh
#
# Output:
#   ./build/windows/x64/runner/Release/ — the compiled executable
#   ./release/Duniya-Setup.exe — the installer (if Inno Setup is available)
# =====================================================================
set -euo pipefail

APP_NAME="Pulse"
APP_VERSION="$(grep 'version:' pubspec.yaml | head -1 | awk '{print $2}' | cut -d'+' -f1)"
BUILD_DIR="build/windows/x64/runner/Release"
RELEASE_DIR="release"

echo "==> Building ${APP_NAME} v${APP_VERSION} for Windows"

# ---------------------------------------------------------------------
# 1. Ensure Flutter is available
# ---------------------------------------------------------------------
if ! command -v flutter &> /dev/null; then
  echo "ERROR: Flutter SDK not found. Install Flutter 3.24+ and add to PATH."
  exit 1
fi

# Enable Windows desktop support
flutter config --enable-windows-desktop

# ---------------------------------------------------------------------
# 2. Get dependencies
# ---------------------------------------------------------------------
echo "==> flutter pub get"
flutter pub get

# ---------------------------------------------------------------------
# 3. Build the Windows app
# ---------------------------------------------------------------------
echo "==> flutter build windows"
flutter build windows --release \
  --build-name="${APP_VERSION}" \
  --build-number="$(date +%s)"

echo "==> Build complete. Output: ${BUILD_DIR}"
ls -la "${BUILD_DIR}"

# ---------------------------------------------------------------------
# 4. Create release directory
# ---------------------------------------------------------------------
mkdir -p "${RELEASE_DIR}"

# ---------------------------------------------------------------------
# 5. Create ZIP archive
# ---------------------------------------------------------------------
echo "==> Creating ZIP archive"
cd "${BUILD_DIR}"
zip -r "${OLDPWD}/${RELEASE_DIR}/${APP_NAME}-${APP_VERSION}-windows.zip" ./*
cd "${OLDPWD}"

echo "==> ZIP created: ${RELEASE_DIR}/${APP_NAME}-${APP_VERSION}-windows.zip"

# ---------------------------------------------------------------------
# 6. Create installer with Inno Setup (if available)
# ---------------------------------------------------------------------
if command -v iscc &> /dev/null; then
  echo "==> Creating installer with Inno Setup"
  cat > /tmp/pulse_setup.iss <<EOF
[Setup]
AppName=${APP_NAME}
AppVersion=${APP_VERSION}
AppPublisher=Pulse Healthcare
AppPublisherURL=https://ivm.duniyahealthcare.com
DefaultDirName={autopf}\\${APP_NAME}
DefaultGroupName=${APP_NAME}
OutputBaseFilename=${APP_NAME}-Setup
Compression=lzma2/ultra64
SolidCompression=yes
SetupIconFile=assets/images/app_launcher_icon.png
UninstallDisplayIcon={app}\\${APP_NAME}.exe

[Files]
Source: "${BUILD_DIR}\\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs

[Icons]
Name: "{group}\\${APP_NAME}"; Filename: "{app}\\${APP_NAME}.exe"
Name: "{autodesktop}\\${APP_NAME}"; Filename: "{app}\\${APP_NAME}.exe"

[Run]
Filename: "{app}\\${APP_NAME}.exe"; Description: "Launch ${APP_NAME}"; Flags: nowait postinstall skipifsilent
EOF

  iscc /tmp/pulse_setup.iss
  mv /tmp/Output/${APP_NAME}-Setup.exe "${RELEASE_DIR}/" 2>/dev/null || true
  echo "==> Installer created: ${RELEASE_DIR}/${APP_NAME}-Setup.exe"
else
  echo "==> Inno Setup not found. Skipping installer creation."
  echo "    Install Inno Setup 6 to create .exe installers."
fi

echo "==> Windows build complete!"
echo "    Release files in: ${RELEASE_DIR}/"
ls -la "${RELEASE_DIR}/"
/"
