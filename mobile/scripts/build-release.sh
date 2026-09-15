#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT"

echo "[mobile-release] root: $ROOT"

if [ -f "$ROOT/.env.mobile-release" ]; then
  set -a
  # shellcheck disable=SC1091
  . "$ROOT/.env.mobile-release"
  set +a
fi

echo "[mobile-release] Android release APK/AAB"
(
  cd mobile/android
  gradle :app:clean :app:assembleRelease :app:bundleRelease
)

ANDROID_APK="$ROOT/mobile/android/app/build/outputs/apk/release/app-release-unsigned.apk"
ANDROID_AAB="$ROOT/mobile/android/app/build/outputs/bundle/release/app-release.aab"
if [ -f "$ROOT/mobile/android/app/build/outputs/apk/release/app-release.apk" ]; then
  ANDROID_APK="$ROOT/mobile/android/app/build/outputs/apk/release/app-release.apk"
fi

echo "[mobile-release] Android APK: $ANDROID_APK"
echo "[mobile-release] Android AAB: $ANDROID_AAB"

echo "[mobile-release] done (Android only; Apple distribution suspended)"
