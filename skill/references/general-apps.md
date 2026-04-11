# General — ADB Reference, Python API, Cross-App Patterns

## Raw ADB Commands

```bash
ADB="adb -s 192.168.1.146:5555"

# === INPUT ===
$ADB shell input tap X Y                    # Tap at coordinates
$ADB shell input text "Hello%sWorld"         # Type text (%s = space)
$ADB shell input swipe X1 Y1 X2 Y2 300      # Swipe gesture
$ADB shell input keyevent 3                  # Home
$ADB shell input keyevent 4                  # Back
$ADB shell input keyevent 66                 # Enter
$ADB shell input keyevent 187                # Recent apps
$ADB shell input keyevent 26                 # Power (wake/sleep)
$ADB shell input keyevent 61                 # Tab
$ADB shell input keyevent 67                 # Delete/Backspace

# === SCREEN READING ===
$ADB shell uiautomator dump /sdcard/ui.xml   # Dump UI tree
$ADB pull /sdcard/ui.xml /tmp/ui.xml         # Pull to PC
$ADB shell screencap /sdcard/screen.png      # Screenshot
$ADB pull /sdcard/screen.png /tmp/phone.png  # Pull screenshot

# === APP CONTROL ===
$ADB shell monkey -p <package> 1             # Launch app
$ADB shell am force-stop <package>           # Force stop
$ADB shell dumpsys window | grep mCurrentFocus  # Current app
$ADB shell pm list packages                  # All installed packages
$ADB shell pm uninstall -k --user 0 <pkg>    # Remove app (user)
$ADB install /path/to/app.apk               # Install APK

# === DEVICE INFO ===
$ADB shell dumpsys battery | grep level      # Battery %
$ADB shell dumpsys power | grep 'Display Power'  # Screen on?
$ADB shell getprop ro.product.model          # Model name
$ADB shell ip addr show wlan0                # WiFi IP
$ADB shell dumpsys notification --noredact   # Notifications
```

## Parsing UI Bounds

Each UI element has `bounds="[x1,y1][x2,y2]"`. To get tap target:
```
center_x = (x1 + x2) / 2
center_y = (y1 + y2) / 2
```
Then: `$ADB shell input tap center_x center_y`

## Python Controller API

Full source: `/media/pavle/Data/Projects 1/PhoneAgent/scripts/phone_controller.py`

```python
import sys
sys.path.insert(0, "/media/pavle/Data/Projects 1/PhoneAgent/scripts")
from phone_controller import PhoneController, APPS

phone = PhoneController(device_ip="192.168.1.146")

# === Status ===
phone.get_device_info()          # {"model": "SM-A145R", "android": "15"}
phone.get_battery_level()        # 85
phone.is_screen_on()             # True
phone.get_current_app()          # "com.linkedin.android"
phone.get_wifi_ip()              # "192.168.1.146"

# === Navigation ===
phone.launch_app(APPS["linkedin"])  # Open app by name
phone.close_app("com.some.app")     # Force stop app
phone.press_home()                  # Home button
phone.press_back()                  # Back button
phone.press_enter()                 # Enter key
phone.press_recent_apps()           # Recent apps
phone.wake_screen()                 # Wake if sleeping

# === Input ===
phone.tap(540, 1200)               # Tap exact coordinates
phone.type_text("Hello World")     # Type text (escapes specials)
phone.swipe(540, 1500, 540, 500)   # Custom swipe
phone.scroll_up()                   # Scroll up (preset)
phone.scroll_down()                 # Scroll down (preset)
phone.clear_text(50)                # Select all + delete

# === Screen Reading ===
elements = phone.get_screen_text()     # All UI elements [{text, description, bounds, center, clickable, class, resource_id}]
summary = phone.get_screen_summary()   # Human-readable: "(x,y) Label [CLICKABLE]"
phone.screenshot("/tmp/phone.png")     # Screenshot to file

# === Smart Actions ===
phone.find_and_tap("Post")             # Find by text, tap center → True/False
phone.wait_for_element("Home", 10)     # Wait up to 10s → True/False
phone.find_element("Search")           # Find element info or None

# === Notifications ===
phone.open_notification_bar()
phone.get_notifications()              # Raw notification dump
phone.close_notification_bar()

# === Logging ===
phone.save_log()                       # Save action log to logs/YYYY-MM-DD.json
```

## All App Package Names

| App | Package |
|-----|---------|
| LinkedIn | `com.linkedin.android` |
| Instagram | `com.instagram.android` |
| WhatsApp | `com.whatsapp` |
| Telegram | `org.telegram.messenger` |
| Chrome | `com.android.chrome` |
| YouTube | `com.google.android.youtube` |
| Gmail | `com.google.android.gm` |
| Maps | `com.google.android.apps.maps` |
| Camera | `com.sec.android.app.camera` |
| Play Store | `com.android.vending` |
| Facebook | `com.facebook.katana` |
| Messenger | `com.facebook.orca` |
| TikTok | `com.zhiliaoapp.musically` |
| Twitter/X | `com.twitter.android` |
| Settings | `com.android.settings` |

## Pre-built Skill Docs

At `/media/pavle/Data/Projects 1/PhoneAgent/skills/`:
- `linkedin-post.md` — Post on LinkedIn
- `linkedin-engage.md` — Likes + comments
- `linkedin-outreach.md` — Connection requests
- `instagram-dm.md` — DM responses
- `influencer-leadgen.md` — Influencer outreach pipeline
- `influencer-analyze.md` — Analyze influencer profiles

## Cross-App Patterns

(Add patterns that work across multiple apps as you discover them)

#### Keyboard Dismiss
Most apps: tap outside the text field or press Back to dismiss keyboard.

#### App Switch
`$PF key recent` → shows recent apps → tap target app or swipe to close.

#### Permission Dialogs
Android permission popups: "Allow" is typically bottom-right, "Deny" bottom-left. Do a screen read on first encounter, then reuse positions.
