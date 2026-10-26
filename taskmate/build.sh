#!/usr/bin/env bash
#
# Builds the Flutter web bundle on Render (or any Linux box with git).
# Nothing needs to be installed first - this script fetches Flutter itself.
#
# Render settings:
#   Build Command      bash build.sh
#   Publish Directory  build/web

set -euo pipefail

FLUTTER_DIR="${HOME}/flutter"

echo "==> Flutter SDK"
if [ ! -d "${FLUTTER_DIR}" ]; then
  # Full clone of the stable branch: a --depth 1 clone leaves Flutter unable
  # to work out its own version, which breaks the build.
  git clone https://github.com/flutter/flutter.git -b stable "${FLUTTER_DIR}"
else
  git -C "${FLUTTER_DIR}" pull --ff-only || true
fi

export PATH="${FLUTTER_DIR}/bin:${PATH}"
export PUB_CACHE="${HOME}/.pub-cache"

flutter --version
flutter config --no-analytics --no-cli-animations >/dev/null 2>&1 || true

# The repo ships web/index.html and web/manifest.json. If they are ever
# missing, let Flutter generate the platform files - but put our own sources
# back afterwards so nothing of ours can be overwritten.
if [ ! -f web/index.html ]; then
  echo "==> Generating web platform files"
  cp -r lib /tmp/taskmate_lib
  cp pubspec.yaml /tmp/taskmate_pubspec.yaml

  flutter create . --platforms=web --project-name taskmate --org com.example

  rm -rf lib && cp -r /tmp/taskmate_lib lib
  cp /tmp/taskmate_pubspec.yaml pubspec.yaml
fi

echo "==> Dependencies"
flutter pub get

echo "==> Analyze (informational - does not stop the build)"
flutter analyze || true

echo "==> Build"
flutter build web --release

echo "==> Done. Output is in build/web"
ls -la build/web | head

# The git repo root is one level above this project folder, and Render looks
# for the publish directory from the repo root. Copy the bundle up there so
# "build/web" resolves no matter which way the service is configured.
if [ -d ../.git ]; then
  echo "==> Copying bundle to the repo root for Render"
  rm -rf ../build/web
  mkdir -p ../build
  cp -r build/web ../build/web
  ls -la ../build/web | head -3
fi
