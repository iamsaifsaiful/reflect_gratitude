#!/usr/bin/env bash
# Creates the android/ and ios/ folders with `flutter create`, then sets the
# name shown under the app icon.
#
# Safe to run more than once: `flutter create` never overwrites files that
# already exist, so everything in lib/, test/ and assets/ stays as it is.
set -euo pipefail
cd "$(dirname "$0")/.."

APP_NAME="Reflect & Gratitude"
ORG="com.yeartogether"

if [ ! -d android ] || [ ! -d ios ]; then
  flutter create --platforms=android,ios --org "$ORG" --project-name reflect_gratitude .
fi

# Android: home-screen label.
MANIFEST="android/app/src/main/AndroidManifest.xml"
if [ -f "$MANIFEST" ]; then
  sed -i.bak 's/android:label="[^"]*"/android:label="Reflect \&amp; Gratitude"/' "$MANIFEST"
  rm -f "$MANIFEST.bak"
fi

# iOS: home-screen name.
PLIST="ios/Runner/Info.plist"
if [ -f "$PLIST" ]; then
  if command -v python3 >/dev/null 2>&1; then
    python3 - "$PLIST" "$APP_NAME" <<'PY'
import plistlib
import sys

path, name = sys.argv[1], sys.argv[2]
with open(path, "rb") as f:
    data = plistlib.load(f)
data["CFBundleDisplayName"] = name
with open(path, "wb") as f:
    plistlib.dump(data, f)
PY
  elif [ -x /usr/libexec/PlistBuddy ]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName '$APP_NAME'" "$PLIST"
  fi
fi

echo "Platform folders are ready. Next: flutter pub get && flutter run"
