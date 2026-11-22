#!/usr/bin/env bash
# Installs build/sable.apk on a watch that's already connected over ADB.
# First time:  adb pair <watch-ip>:<pair-port>   (enter the code shown on the watch)
# Then:        adb connect <watch-ip>:<port>
set -euo pipefail
cd "$(dirname "$0")"
[ -f build/sable.apk ] || ./build.sh
adb devices | grep -q "device$" || { echo "No device connected — run: adb connect <watch-ip>:<port>"; exit 1; }
adb install -r build/sable.apk
echo "✓ Installed. Long-press the watch face on your watch and scroll to 'Sable'."
