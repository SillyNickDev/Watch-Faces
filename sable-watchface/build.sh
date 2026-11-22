#!/usr/bin/env bash
# Builds build/sable.apk from this folder using the Android SDK command-line tools.
# Needs: a JDK (for apksigner/keytool), Android SDK build-tools, and platforms;android-34.
set -euo pipefail
cd "$(dirname "$0")"

SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-$HOME/Android/Sdk}}"
[ -d "$SDK/build-tools" ] || { echo "Android SDK not found at $SDK (set ANDROID_HOME)"; exit 1; }
BT="$SDK/build-tools/${BUILD_TOOLS:-$(ls "$SDK/build-tools" | sort -V | tail -1)}"
PLATFORM="$SDK/platforms/android-34/android.jar"
[ -f "$PLATFORM" ] || { echo "Missing $PLATFORM — run: sdkmanager 'platforms;android-34'"; exit 1; }

VERSION_CODE="${VERSION_CODE:-1}"
VERSION_NAME="${VERSION_NAME:-1.0}"

rm -rf build && mkdir -p build
echo "→ compiling resources"
"$BT/aapt2" compile --dir res -o build/res.zip
echo "→ linking"
"$BT/aapt2" link -o build/sable-unsigned.apk \
  -I "$PLATFORM" --manifest AndroidManifest.xml \
  --min-sdk-version 34 --target-sdk-version 34 \
  --version-code "$VERSION_CODE" --version-name "$VERSION_NAME" \
  build/res.zip
echo "→ aligning"
"$BT/zipalign" -f -p 4 build/sable-unsigned.apk build/sable-aligned.apk

KS="${KEYSTORE:-$HOME/.android/debug.keystore}"
if [ ! -f "$KS" ]; then
  echo "→ creating debug keystore at $KS"
  mkdir -p "$(dirname "$KS")"
  keytool -genkeypair -v -keystore "$KS" -storepass android -keypass android \
    -alias androiddebugkey -keyalg RSA -keysize 2048 -validity 10000 \
    -dname "CN=Android Debug,O=Android,C=US" >/dev/null
fi
echo "→ signing"
"$BT/apksigner" sign --ks "$KS" --ks-pass pass:android --key-pass pass:android \
  --ks-key-alias androiddebugkey --out build/sable.apk build/sable-aligned.apk
rm -f build/sable-unsigned.apk build/sable-aligned.apk build/res.zip
echo "✓ built build/sable.apk"
