# Sable — Galaxy Watch 6 watch face

A Watch Face Format (WFF v2) watch face. No code and no GUI tools: the whole face is
`res/raw/watchface.xml` plus fonts and three small icons. You build it with two Android
SDK command-line tools and install it over Wi‑Fi with `adb`.

## What it shows

| Part | Data | Notes |
|---|---|---|
| `14` / `37` stacked | Time, 24‑hour | Space Grotesk Bold, white over rust |
| Rust colon | — | Breathes once a second (20% ↔ 100% opacity, smooth) |
| Right arc (rust) | Step goal % | Fills 20° → 160° |
| Left arc (white) | Heart rate | Empty at 40 bpm, full at 180 bpm |
| Top arc (tan) | Battery % | Turns red at 15% or below |
| Left column | Heart rate | Heart icon pops once per beat at your real BPM |
| Right column | Steps | Shows `8.4k` style above 1,000 |
| Bottom curve | Weather + date | Falls back to just the date if weather isn't available. One UI's Now Bar can cover it while active |
| Top curve | Battery % | Tan, follows the battery arc inside the seconds-dot path |
| Seconds sweep | Seconds | Rust gradient behind the digits, spinning smoothly from the centre; its bright edge points at the current second; moves as smoothly as the watch allows |

The seconds are shown by a rust sweep spinning behind the digits.

**Always‑on mode** keeps only the time, a static colon and the battery bar, dimmed.

## One‑time setup (≈30 min)

### 1. Tools on your PC

You need a JDK (17+) and the Android SDK command-line tools. You don't need Android Studio.

1. Install a JDK from your distro (Gentoo: `dev-java/openjdk-bin:17` or `:21`).
2. Download **Command line tools only** for Linux from
   <https://developer.android.com/studio#command-line-tools-only>.
3. Unpack it so you get `~/Android/Sdk/cmdline-tools/latest/bin/sdkmanager`:
   ```bash
   mkdir -p ~/Android/Sdk/cmdline-tools
   unzip commandlinetools-linux-*.zip -d ~/Android/Sdk/cmdline-tools
   mv ~/Android/Sdk/cmdline-tools/cmdline-tools ~/Android/Sdk/cmdline-tools/latest
   ```
4. Install the bits this project needs:
   ```bash
   export ANDROID_HOME=~/Android/Sdk
   $ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager "platform-tools" "build-tools;35.0.0" "platforms;android-34"
   export PATH="$PATH:$ANDROID_HOME/platform-tools"
   ```
   (Put the two `export` lines in your shell rc so they stick.)

### 2. Developer mode on the watch

1. **Settings → About watch → Software information** → tap **Software version** 5 times.
2. **Settings → Developer options** → turn on **ADB debugging** and **Wireless debugging**.
3. Tap **Wireless debugging → Pair new device**. It shows an IP:port and a code.
4. On the PC (same Wi‑Fi):
   ```bash
   adb pair 192.168.x.x:PAIRPORT      # enter the code
   adb connect 192.168.x.x:PORT       # the port on the main Wireless debugging screen
   ```

## Build and install

```bash
./build.sh      # → build/sable.apk
./install.sh    # installs over adb
```

Then long-press the current watch face on the watch, scroll to **Sable**, and tap it.

After the first time, an update is just `./install.sh` again. The pairing usually
survives, but you may need to `adb connect` again after the watch reboots.

## Tweaking it

Everything is in `res/raw/watchface.xml` and the comments label each section. The colours
are ARGB hex: rust `#FFD07A3A`, tan `#FFE8C9A0`, white `#FFFFFFFF`. Positions are on a
480×480 canvas.

Some easy edits:
- **Heart-rate arc range:** change `40` and `140` in the `hrLevel` transform (min bpm and range).
- **Colon breathing depth:** change `51 + 204` (lowest alpha 51 = 20%, out of 255).
- **Low-battery threshold:** change `<= 15` in `batteryLow`.

## Notes and known unknowns

- The XML passes Google's official WFF v2 schema (from github.com/google/watchface).
  I haven't been able to build or run it on a real watch, so treat the first install as a test.
- If the digits sit a few pixels too high or low, change the `y` on the two `DigitalClock`
  elements. If the colon crowds the `14`, change the `x="329"` on both colon groups.
- The breathing colon, seconds dot, heart pop and glow redraw continuously while the
  screen is on. That costs a little battery compared with a fully static face, but they
  all switch off in always-on.
- Fonts: Space Grotesk and Outfit, both SIL Open Font License (see `licenses/`).
