# PhoneAgent

AI agent that controls a real Android phone. Tap, swipe, type, read screen, send messages, make calls — all from your terminal or AI assistant.

**PC = Brain** (LLM reasoning, skills, memory) | **Phone = Hands + Eyes** (tap, swipe, type, read screen)

```
You: "Go to LinkedIn and check my analytics"
Agent: *opens LinkedIn → navigates to profile → reads analytics → reports back*
```

## Why?

- Mobile apps have **consistent UIs** — no window resizing, no overlapping
- Android's UI tree gives **exact coordinates** for every button — no screenshot guessing
- One phone, one skill, infinite automation — Instagram DMs, LinkedIn outreach, form filling, anything

## What Can It Do?

| Feature | Command |
|---------|---------|
| Open any app | `$PF nav linkedin` |
| Tap anywhere | `$PF tap 540 800` |
| Type text | `$PF type "Hello world"` |
| Scroll | `$PF scroll down` |
| Read screen | `$PF screen` |
| Screenshot | `$PF screenshot` |
| Chain actions | `$PF batch "input tap 540 800;sleep 0.5;input tap 200 400"` |
| Push/pull files | `$PF push image.png` / `$PF pull /sdcard/file.pdf` |
| Clipboard | `$PF copy` / `$PF paste "text"` |
| Notifications | `$PF notifs` |
| Send SMS | `$PF sms "+381..." "Hey!"` |
| Make calls | `$PF call "+381..."` |
| Search contacts | `$PF contacts search "John"` |
| Real-time monitoring | `$PF events start` / `$PF events status` |
| Session analysis | `$PF learn` |

## Quick Start

### 1. Get a Phone

Any Android 10+ phone works. Cheap is fine — we tested on a Samsung Galaxy A14 (~$150).

- **Minimum:** 3GB RAM, 32GB storage
- **Recommended:** 4GB+ RAM, old flagship (Pixel 4a, Samsung S10, etc.)

### 2. Phone Setup

```bash
# Enable Developer Options: Settings → About → tap "Build Number" 7 times
# Enable USB Debugging in Developer Options
# Connect via USB, accept the debugging prompt on phone

# Test connection
adb devices
```

**Optimize for automation:**
```bash
# Disable animations (much faster navigation)
adb shell settings put global window_animation_scale 0
adb shell settings put global transition_animation_scale 0
adb shell settings put global animator_duration_scale 0

# Keep screen on while charging
adb shell settings put global stay_on_while_plugged_in 3

# Disable lock screen
adb shell settings put secure lockscreen.disabled 1
```

### 3. Go Wireless

```bash
# Make sure phone and PC are on the same WiFi

# Get phone IP
adb shell ip addr show wlan0 | grep "inet "
# Example output: inet 192.168.1.146/24

# Enable TCP/IP mode
adb tcpip 5555

# Disconnect USB cable, then:
adb connect 192.168.1.146:5555

# Test
adb -s 192.168.1.146:5555 shell echo "connected"
```

### 4. Install PhoneAgent

```bash
git clone https://github.com/YourUsername/phone-agent.git
cd phone-agent

# Edit phone IP in phone_fast.sh
nano scripts/phone_fast.sh
# Change DEVICE="192.168.1.146:5555" to your phone's IP

# Make scripts executable
chmod +x scripts/*.sh

# Set up the shortcut
echo 'PF="/path/to/phone-agent/scripts/phone_fast.sh"' >> ~/.bashrc
source ~/.bashrc

# Test
$PF connect
$PF info
```

### 5. First Automation

```bash
# Open YouTube and search for a video
$PF nav youtube
sleep 2
$PF tap 865 131          # Tap search icon (your coordinates may differ!)
$PF type "lofi hip hop"
$PF key enter
sleep 2
$PF tap 540 700          # Tap first result
```

**Important:** Coordinates depend on your phone's screen resolution. Use `$PF screen` or `uiautomator dump` to find exact coordinates for your device.

### 6. (Optional) SSH Access via Termux

Install [Termux](https://f-droid.org/packages/com.termux/) on the phone for SSH access, clipboard, and running scripts directly on the phone.

```bash
# On phone (Termux):
pkg install openssh python termux-api
sshd

# On PC:
ssh-copy-id -p 8022 192.168.1.146
ssh -p 8022 192.168.1.146
```

Also install **Termux:API** APK from F-Droid for clipboard support.

### 7. (Optional) Live Screen Mirror

```bash
# Install scrcpy (https://github.com/Genymobile/scrcpy)
# Then:
scrcpy --serial=192.168.1.146:5555 --max-size=720 --no-audio
```

## Project Structure

```
phone-agent/
├── scripts/                     # Core automation scripts
│   ├── phone_fast.sh            # Main CLI — all phone commands
│   ├── phone_controller.py      # Python wrapper class
│   ├── phone_learn.sh           # Session log analyzer
│   ├── phone_event_listener.py  # Real-time phone state monitor
│   ├── parse_notifications.py   # Notification parser
│   ├── setup_wifi_adb.sh        # WiFi ADB setup helper
│   └── samsung_a14_debloat.sh   # Samsung debloat script
├── skill/                       # Claude Code skill (phone-use)
│   ├── SKILL.md                 # Skill hub — quick reference
│   └── references/              # Per-app coordinate maps
│       ├── linkedin.md          # LinkedIn UI coordinates & flows
│       ├── instagram.md         # Instagram UI coordinates & flows
│       ├── whatsapp.md          # WhatsApp UI coordinates & flows
│       ├── general-apps.md      # Cross-app ADB patterns
│       ├── anti-detection.md    # Rate limits & safety
│       └── troubleshooting.md   # Common issues & fixes
├── skills/                      # Use case workflows
│   ├── linkedin-post.md         # Auto-post on LinkedIn
│   ├── linkedin-outreach.md     # Connection requests & follow-ups
│   ├── linkedin-engage.md       # Like & comment automation
│   ├── instagram-dm.md          # DM responder
│   ├── influencer-leadgen.md    # Find & contact influencers
│   └── influencer-analyze.md    # Analyze influencer profiles
├── hooks/                       # Claude Code hooks
│   ├── phone-session-learner.sh # Auto-detect phone sessions
│   └── phone-session-summary.sh # End-of-session Obsidian summary
├── config/
│   ├── schedule.md              # Daily automation schedule
│   └── rate-limits.md           # Per-app action limits
├── memory/                      # Self-improving knowledge
│   ├── patterns.md              # Learned UI patterns
│   ├── errors.md                # Known failure modes
│   └── performance.md           # Execution metrics
├── examples/                    # Example scripts & tutorials
├── docs/
│   └── SETUP.md                 # Detailed setup guide
└── logs/                        # Daily session logs (gitignored)
```

## How It Works

### Reading the Screen

The agent reads the screen using Android's `uiautomator` — an accessibility tool that returns every UI element with exact pixel coordinates:

```bash
# Dump UI tree
adb shell uiautomator dump /sdcard/ui.xml
adb pull /sdcard/ui.xml /tmp/ui.xml

# Parse with Python
python3 -c "
import xml.etree.ElementTree as ET
for node in ET.parse('/tmp/ui.xml').getroot().iter('node'):
    text = node.get('text', '')
    bounds = node.get('bounds', '')
    if text: print(f'{bounds} {text}')
"
```

Output: `[798,64][933,199] Search` — the Search button is at coordinates (865, 131).

### Self-Improving Skills

Every phone action is logged to `logs/sessions/YYYY-MM-DD.jsonl`. Run `$PF learn` to analyze the session and discover new coordinates not yet documented in the reference files.

The `skill/references/*.md` files contain verified coordinates for each app. When you successfully navigate an app, update the reference file with the new coordinates so the next session is faster.

### Event Monitoring

Start the event listener to get real-time phone state without slow screen dumps:

```bash
$PF events start    # Starts background listener
$PF events status   # Instant state: current app, screen on/off, notification count
$PF events stop     # Stop listener
```

State is written to `/tmp/.phone-state.json` and updated every second.

## Architecture

```
PC (Brain)                              Phone (Hands)
┌──────────────────────┐    ADB/WiFi   ┌──────────────────┐
│ AI Agent (LLM)       │◄─────────────►│ Android OS       │
│   ↓                  │               │   ↓              │
│ phone_fast.sh        │   tap/type    │ UI Automator     │
│   ↓                  │──────────────►│   (read screen)  │
│ Skill References     │               │                  │
│   ↓                  │   events      │ Termux           │
│ Auto-Learning System │◄──────────────│   (SSH, Python)  │
│   ↓                  │               │                  │
│ Session Logs         │   files       │ /sdcard/          │
│                      │◄─────────────►│   (push/pull)    │
└──────────────────────┘               └──────────────────┘
```

## Use Cases

- **LinkedIn Automation** — outreach, engagement, analytics
- **Instagram DM Responder** — auto-reply for businesses
- **Hackathon Auto-Apply** — fill out application forms automatically
- **Cross-Platform Messaging** — check & reply on all apps
- **Competitor Monitoring** — daily screenshots of competitor profiles
- **Form Filling** — any web/app form with your data
- **Price Tracking** — monitor prices on delivery/shopping apps

## Contributing

This is an open-core project. Core scripts are MIT licensed. Add your own skills by creating `.md` files in the `skills/` directory.

To add a new app reference:
1. Open the app on your phone
2. Run `adb shell uiautomator dump` to get coordinates
3. Create `skill/references/your-app.md` with the coordinate tables
4. Submit a PR

## License

MIT
