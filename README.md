# PhoneAgent

AI agent that controls an Android phone autonomously.  
PC = Brain (LLM reasoning, skills, memory). Phone = Hands + Eyes (tap, swipe, type, read screen).

## Hardware
- **Phone:** Samsung Galaxy A14 (SM-A145R, 4GB RAM, 128GB, Android 13)
- **PC:** HP ProBook 450 G4 (Ubuntu 25.10)
- **Connection:** USB or WiFi ADB

## Quick Start

```bash
# 1. Plug in phone via USB, accept debugging prompt

# 2. Test connection
python3 scripts/quick_test.py

# 3. See phone screen on PC
scrcpy

# 4. Setup wireless (optional)
bash scripts/setup_wifi_adb.sh

# 5. Run a skill
python3 scripts/phone_controller.py
```

## Project Structure

```
PhoneAgent/
├── scripts/
│   ├── phone_controller.py    # Core controller (ADB wrapper)
│   ├── quick_test.py          # Verify phone connection
│   └── setup_wifi_adb.sh      # WiFi ADB setup
├── skills/                    # Action instructions (.md)
│   ├── linkedin-post.md
│   ├── linkedin-engage.md
│   ├── linkedin-outreach.md
│   └── instagram-dm.md
├── memory/                    # Self-improving knowledge
│   ├── patterns.md
│   ├── errors.md
│   └── performance.md
├── config/
│   ├── schedule.md
│   └── rate-limits.md
├── logs/                      # Daily execution logs
└── README.md
```

## Architecture

```
PC (Brain)                    Phone (Hands)
┌─────────────┐    ADB     ┌──────────────┐
│ LLM Router  │◄──────────►│ Accessibility │
│ Skill Engine│    USB/    │ Service       │
│ Phone Ctrl  │    WiFi    │ (tap/swipe/   │
│ Memory      │            │  type/read)   │
└─────────────┘            └──────────────┘
```
