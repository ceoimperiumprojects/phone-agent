---
name: phone-use
description: Control Android phone (Samsung Galaxy A14) via ADB/SSH — tap, swipe, type, read screen, launch apps, screenshot, notifications. Use when the user asks to interact with phone, post on social media via phone, send messages, control apps, or automate phone tasks.
trigger: when user asks to use phone, control phone, tap phone, open app on phone, post from phone, send message on phone, check phone, phone screenshot, instagram post, linkedin from phone, whatsapp message, telefon, koristi telefon
---

# Phone Use — Android Phone Control

Samsung Galaxy A14 (Android 15) | WiFi ADB `192.168.1.146:5555` | SSH port `8022`

## Fast CLI (ALWAYS use this)

```bash
PF="/media/pavle/Data/Projects 1/PhoneAgent/scripts/phone_fast.sh"

$PF connect                          # Connect to phone
$PF nav linkedin                     # Launch app (linkedin/instagram/whatsapp/telegram/chrome/youtube/...)
$PF screen                           # Read screen — parsed UI elements (SLOW ~2-3s, minimize use!)
$PF tap 540 800                      # Tap coordinates
$PF type "Hello world"               # Type text
$PF scroll down                      # Scroll up/down
$PF key home                         # home/back/enter/recent/power/delete
$PF screenshot                       # Screenshot → /tmp/phone.png
$PF info                             # Device info + battery + current app
$PF batch "input tap 540 800;sleep 0.5;input tap 200 400"  # FASTEST: chain actions in one shell

# ── File Transfer ──
$PF push image.png                   # Push file to phone (/sdcard/Download/)
$PF pull /sdcard/Download/file.pdf   # Pull file from phone (to /tmp/)

# ── Clipboard ──
$PF copy                             # Get clipboard content (via Termux:API)
$PF paste "text to paste"            # Set clipboard + paste into active field

# ── Notifications ──
$PF notifs                           # List all notifications
$PF notifs clear                     # Clear all notifications
$PF notifs tap 3                     # Open 3rd notification

# ── Contacts + SMS + Call ──
$PF sms "+381641234567" "Hey!"       # Send SMS
$PF contacts search "Ognjen"         # Search contacts by name
$PF contacts phones "Ognjen"         # Search with phone numbers
$PF call "+381641234567"             # Make a phone call

# ── Real-time Event Daemon ──
$PF events start                     # Start daemon (phone) + listener (desktop)
$PF events stop                      # Stop both
$PF events status                    # Current phone state (INSTANT, no ADB call)
```

**Event Daemon** — when running (`$PF events start`), phone state is at `/tmp/.phone-state.json`:
- Read it INSTEAD of `$PF info` for instant app/screen state (no ADB call)
- Daemon detects app switches, screen on/off, notification count changes in <500ms
- Auto-reconnects if phone disconnects

**Speed rules:**
- `$PF batch` chains multiple taps in ONE ADB session — always prefer this
- `$PF screen` parser may fail on some apps. Use raw uiautomator dump instead:
  ```bash
  ADB="adb -s 192.168.1.146:5555"
  $ADB shell "uiautomator dump /sdcard/ui.xml" && $ADB pull /sdcard/ui.xml /tmp/ui.xml
  ```
  Then parse /tmp/ui.xml with Python for exact coordinates (see references/general-apps.md)
- After tapping something, you often KNOW what comes next — go direct, don't read screen
- **Live screen mirror:** `/tmp/scrcpy-linux-x86_64-v3.3.4/scrcpy --serial=192.168.1.146:5555 --no-control`

## App References — Load On Demand

| App | Package | Reference |
|-----|---------|-----------|
| LinkedIn | `com.linkedin.android` | Read `references/linkedin.md` |
| Instagram | `com.instagram.android` | Read `references/instagram.md` |
| WhatsApp | `com.whatsapp` | Read `references/whatsapp.md` |

Read `references/general-apps.md` for raw ADB commands, Python API, all package names, cross-app patterns.
Read `references/anti-detection.md` BEFORE any social media automation.
Read `references/troubleshooting.md` when something breaks.

**Other app packages** (no dedicated reference yet):

| App | Package |
|-----|---------|
| Telegram | `org.telegram.messenger` |
| Chrome | `com.android.chrome` |
| YouTube | `com.google.android.youtube` |
| Gmail | `com.google.android.gm` |
| TikTok | `com.zhiliaoapp.musically` |
| Twitter/X | `com.twitter.android` |
| Facebook | `com.facebook.katana` |
| Settings | `com.android.settings` |

## Self-Improving Protocol

After completing a complex phone task:
1. If you learned NEW coordinates, flows, or UI patterns — **update the relevant `references/<app>.md`**
2. Add the flow as a new `####` section with exact `$PF` commands and coordinates
3. Update `Last verified: YYYY-MM-DD` on any section you used successfully
4. If a documented coordinate was WRONG, replace it (don't keep both)
5. If you worked with a NEW app — create `references/<app>.md` using the same template + add to the dispatch table above
6. Cross-app patterns → `references/general-apps.md`

## Phone Specs

Model: Samsung Galaxy A14 (SM-A145R) | Android 15 | Screen 1080x2408
RAM: 3.6GB (1.3GB free) | Storage: 107GB (102GB free) | Debloated (90 pkgs removed)
Always on charger | Screen always on | No lock | Animations OFF

## Key Files

| What | Path |
|------|------|
| Fast CLI | `/media/pavle/Data/Projects 1/PhoneAgent/scripts/phone_fast.sh` |
| Python controller | `/media/pavle/Data/Projects 1/PhoneAgent/scripts/phone_controller.py` |
| Skills/automations | `/media/pavle/Data/Projects 1/PhoneAgent/skills/` |
| Config | `/media/pavle/Data/Projects 1/PhoneAgent/config/` |
| Logs | `/media/pavle/Data/Projects 1/PhoneAgent/logs/` |
