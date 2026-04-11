#!/usr/bin/env python3
"""Phone Event Listener — polls phone state via ADB and writes /tmp/.phone-state.json.
No daemon needed on phone! Desktop-only, uses fast ADB commands."""

import subprocess, json, os, time, re, sys

DEVICE = "192.168.1.146:5555"
STATE_FILE = "/tmp/.phone-state.json"
POLL_INTERVAL = 1.0  # seconds

def adb_raw(args, timeout=3):
    try:
        r = subprocess.run(
            ["adb", "-s", DEVICE] + args,
            capture_output=True, text=True, timeout=timeout
        )
        return r.stdout.strip()
    except:
        return ""

def get_state():
    # Single ADB call with a script file approach
    raw = adb_raw(["shell", "dumpsys window | grep mCurrentFocus; echo ---; dumpsys power | grep 'Display Power'; echo ---; dumpsys notification --noredact | grep -c NotificationRecord"], timeout=5)

    parts = raw.split("---")
    state = {"app": "", "screen": "", "notif_count": 0}

    if len(parts) >= 1:
        # Parse app from mCurrentFocus line
        for line in parts[0].strip().split('\n'):
            m = re.search(r'(\w+\.\w+[\w.]+/[\w.]+)', line)
            if m:
                state["app"] = m.group(1)

    if len(parts) >= 2:
        state["screen"] = "ON" if "ON" in parts[1] else "OFF"

    if len(parts) >= 3:
        try:
            state["notif_count"] = int(parts[2].strip())
        except:
            pass

    return state

def main():
    prev_state = {}
    print(f"Phone Event Listener started. Polling {DEVICE} every {POLL_INTERVAL}s")
    print(f"State file: {STATE_FILE}")

    while True:
        try:
            state = get_state()
            state["last_update"] = time.time()

            # Detect changes
            for k in ("app", "screen", "notif_count"):
                if state.get(k) != prev_state.get(k):
                    ts = time.strftime('%H:%M:%S')
                    print(f"[{ts}] {k}: {state[k]}")

            # Write state
            with open(STATE_FILE, "w") as f:
                json.dump(state, f, indent=2)

            prev_state = dict(state)
        except KeyboardInterrupt:
            print("Stopped.")
            if os.path.exists(STATE_FILE):
                os.remove(STATE_FILE)
            sys.exit(0)
        except Exception as e:
            print(f"Error: {e}")

        time.sleep(POLL_INTERVAL)

if __name__ == "__main__":
    main()
