#!/usr/bin/env bash
# phone_fast.sh — Fast phone commands via persistent ADB shell
# Eliminates per-command ADB process overhead
#
# Usage:
#   phone_fast.sh nav linkedin          # Open LinkedIn
#   phone_fast.sh nav instagram         # Open Instagram
#   phone_fast.sh tap X Y               # Tap coordinates
#   phone_fast.sh type "text"           # Type text
#   phone_fast.sh swipe X1 Y1 X2 Y2    # Swipe
#   phone_fast.sh scroll up|down        # Scroll
#   phone_fast.sh key home|back|enter   # Key press
#   phone_fast.sh screen               # Dump UI → /tmp/ui.xml (parsed summary to stdout)
#   phone_fast.sh screenshot            # Screenshot → /tmp/phone.png
#   phone_fast.sh batch "cmd1;cmd2;..."  # Multiple commands in ONE adb shell session
#   phone_fast.sh info                  # Device info + battery + current app
#   phone_fast.sh connect               # Connect to phone

set -euo pipefail

DEVICE="192.168.1.146:5555"
ADB="adb -s $DEVICE"

# ── Logging (async, non-blocking) ──
LOG_DIR="/media/pavle/Data/Projects 1/PhoneAgent/logs/sessions"
LOG_FILE="$LOG_DIR/$(date +%Y-%m-%d).jsonl"

_log_action() {
  local cmd="$1" args="$2" app="${3:-}"
  local cache="/tmp/.phone-current-app"
  # Use cached app if not provided
  if [ -z "$app" ]; then
    app=$(cat "$cache" 2>/dev/null || echo "unknown")
  else
    # Update cache when app is known (from nav)
    echo "$app" > "$cache"
  fi
  local ts=$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)
  mkdir -p "$LOG_DIR" 2>/dev/null
  printf '{"ts":"%s","app":"%s","cmd":"%s","args":"%s"}\n' \
    "$ts" "$app" "$cmd" "$args" >> "$LOG_FILE"
}

case "${1:-help}" in

  connect)
    # Layer 1: Try saved 5555 connection
    adb connect "$DEVICE" 2>/dev/null
    if $ADB shell echo "ok" >/dev/null 2>&1; then
      echo "OK: Connected to $DEVICE"
      exit 0
    fi

    # Layer 2: SSH in, find wireless debug port, flip to 5555
    echo "5555 cold — trying SSH recovery via phone:8022..."
    if ! nc -z -w 3 192.168.1.146 8022 2>/dev/null; then
      echo "FAIL: SSH port 8022 also down. Phone likely asleep — unlock screen, then rerun."
      exit 1
    fi

    # Port scan for wireless-debug port (Android restricts /proc/net/tcp)
    echo "Scanning for wireless-debug port (30000-50000)..."
    WDPORT=$(for p in $(seq 30000 2 49998); do (echo >/dev/tcp/192.168.1.146/$p) 2>/dev/null && echo $p & done; wait | head -1)
    if [ -n "$WDPORT" ] && [ "$WDPORT" != "8022" ]; then
      echo "Found wireless-debug port: $WDPORT"
      adb connect "192.168.1.146:$WDPORT" 2>/dev/null
      sleep 1
      if adb -s "192.168.1.146:$WDPORT" tcpip 5555 >/dev/null 2>&1; then
        sleep 2
        adb connect "$DEVICE" 2>/dev/null
        $ADB shell echo ok >/dev/null 2>&1 && echo "OK: Recovered, connected to $DEVICE" && exit 0
      fi
    fi

    echo "FAIL: Auto-recovery failed. On phone: Settings → Developer options → Wireless debugging (turn ON), then rerun."
    exit 1
    ;;

  nav)
    app="${2:-}"
    declare -A PACKAGES=(
      [linkedin]="com.linkedin.android"
      [instagram]="com.instagram.android"
      [whatsapp]="com.whatsapp"
      [telegram]="org.telegram.messenger"
      [chrome]="com.android.chrome"
      [youtube]="com.google.android.youtube"
      [gmail]="com.google.android.gm"
      [tiktok]="com.zhiliaoapp.musically"
      [twitter]="com.twitter.android"
      [facebook]="com.facebook.katana"
      [messenger]="com.facebook.orca"
      [settings]="com.android.settings"
      [camera]="com.sec.android.app.camera"
    )
    pkg="${PACKAGES[$app]:-}"
    if [ -z "$pkg" ]; then
      echo "Unknown app: $app"
      echo "Available: ${!PACKAGES[*]}"
      exit 1
    fi
    $ADB shell "monkey -p $pkg 1" 2>/dev/null
    echo "Launched: $app ($pkg)"
    ( _log_action "nav" "$app" "$pkg" ) &
    ;;

  tap)
    $ADB shell "input tap ${2} ${3}"
    ( _log_action "tap" "${2} ${3}" ) &
    ;;

  type)
    text="${2:-}"
    escaped="${text// /%s}"
    $ADB shell "input text '$escaped'"
    ( _log_action "type" "$text" ) &
    ;;

  swipe)
    $ADB shell "input swipe ${2} ${3} ${4} ${5} ${6:-300}"
    ( _log_action "swipe" "${2} ${3} ${4} ${5} ${6:-300}" ) &
    ;;

  scroll)
    dir="${2:-down}"
    if [ "$dir" = "up" ]; then
      $ADB shell "input swipe 540 500 540 1500 300"
    else
      $ADB shell "input swipe 540 1500 540 500 300"
    fi
    ( _log_action "scroll" "$dir" ) &
    ;;

  key)
    k="${2:-}"
    declare -A KEYS=([home]=3 [back]=4 [enter]=66 [recent]=187 [power]=26 [tab]=61 [delete]=67)
    code="${KEYS[$k]:-$k}"
    $ADB shell "input keyevent $code"
    ( _log_action "key" "$k" ) &
    ;;

  screen)
    # Dump UI and parse in ONE pipeline — fastest possible screen read
    $ADB shell "uiautomator dump /sdcard/ui.xml && cat /sdcard/ui.xml" 2>/dev/null | \
      python3 -c "
import sys, xml.etree.ElementTree as ET, re
try:
    tree = ET.parse(sys.stdin)
except:
    print('ERROR: Could not parse UI tree'); sys.exit(1)
for node in tree.getroot().iter('node'):
    text = node.get('text','')
    desc = node.get('content-desc','')
    bounds = node.get('bounds','')
    click = node.get('clickable','false')
    rid = node.get('resource-id','')
    if text or desc:
        m = re.match(r'\[(\d+),(\d+)\]\[(\d+),(\d+)\]', bounds)
        if m:
            x1,y1,x2,y2 = map(int, m.groups())
            cx,cy = (x1+x2)//2, (y1+y2)//2
        else:
            cx,cy = 0,0
        label = text or desc
        c = ' [TAP]' if click == 'true' else ''
        r = f' #{rid.split(\"/\")[-1]}' if rid else ''
        print(f'({cx},{cy}) {label}{c}{r}')
"
    ;;

  screenshot)
    out="${2:-/tmp/phone.png}"
    $ADB shell "screencap /sdcard/screen.png"
    $ADB pull /sdcard/screen.png "$out" 2>/dev/null
    echo "$out"
    ;;

  batch)
    # Run multiple commands in ONE adb shell — massive speed boost
    # Example: phone_fast.sh batch "input tap 540 800;sleep 0.5;input tap 200 400"
    $ADB shell "${2}"
    ( _log_action "batch" "${2}" ) &
    ;;

  info)
    $ADB shell "
      echo MODEL: \$(getprop ro.product.model)
      echo ANDROID: \$(getprop ro.build.version.release)
      echo BATTERY: \$(dumpsys battery | grep level | awk '{print \$2}')%
      echo SCREEN: \$(dumpsys power | grep 'Display Power' | grep -o 'ON\|OFF')
      echo WIFI: \$(ip addr show wlan0 | grep 'inet ' | awk '{print \$2}')
      echo APP: \$(dumpsys window | grep mCurrentFocus | grep -oP '\S+/\S+' | head -1)
    "
    ;;

  # ── File Transfer ──
  push)
    local_file="${2:?Usage: phone_fast.sh push <local_file> [remote_dir]}"
    remote_dir="${3:-/sdcard/Download}"
    $ADB push "$local_file" "$remote_dir/"
    echo "Pushed: $local_file → $remote_dir/$(basename "$local_file")"
    ( _log_action "push" "$local_file" ) &
    ;;

  pull)
    remote_file="${2:?Usage: phone_fast.sh pull <remote_path> [local_dir]}"
    local_dir="${3:-/tmp}"
    $ADB pull "$remote_file" "$local_dir/"
    echo "Pulled: $remote_file → $local_dir/$(basename "$remote_file")"
    ( _log_action "pull" "$remote_file" ) &
    ;;

  # ── Clipboard ──
  copy)
    result=$(ssh -i ~/.ssh/phone_agent -p 8022 -o ConnectTimeout=3 192.168.1.146 "termux-clipboard-get" 2>/dev/null)
    if [ $? -eq 0 ]; then
      echo "$result"
    else
      echo "ERROR: termux-clipboard-get failed. Install: pkg install termux-api + Termux:API APK"
    fi
    ( _log_action "copy" "clipboard" ) &
    ;;

  paste)
    text="${2:?Usage: phone_fast.sh paste \"text\"}"
    ssh -i ~/.ssh/phone_agent -p 8022 -o ConnectTimeout=3 192.168.1.146 "termux-clipboard-set '${text}'" 2>/dev/null
    $ADB shell "input keyevent 279" 2>/dev/null || $ADB shell "input keyevent 113 && input keyevent 50 && input keyevent 113"
    echo "Pasted: $text"
    ( _log_action "paste" "$text" ) &
    ;;

  # ── Notifications ──
  notifs)
    subcmd="${2:-list}"
    case "$subcmd" in
      list|ls)
        $ADB shell "dumpsys notification --noredact" 2>/dev/null | python3 "/media/pavle/Data/Projects 1/PhoneAgent/scripts/parse_notifications.py"
        ;;
      clear)
        $ADB shell "service call notification 1"
        echo "Notifications cleared"
        ;;
      tap)
        n="${3:?Usage: phone_fast.sh notifs tap <number>}"
        $ADB shell "cmd statusbar expand-notifications"
        sleep 0.5
        y=$((280 + (n - 1) * 160))
        $ADB shell "input tap 540 $y"
        ;;
    esac
    ( _log_action "notifs" "$subcmd ${3:-}" ) &
    ;;

  # ── Contacts + SMS + Call ──
  sms)
    number="${2:?Usage: phone_fast.sh sms \"+381...\" \"message\"}"
    message="${3:?Usage: phone_fast.sh sms \"+381...\" \"message\"}"
    escaped="${message// /%s}"
    $ADB shell "am start -a android.intent.action.SENDTO -d 'sms:${number}' --es sms_body '${escaped}'"
    sleep 1.5
    # Try send button — Samsung Messages typically has it at bottom-right
    $ADB shell "input tap 990 2179" 2>/dev/null
    echo "SMS sent to $number"
    ( _log_action "sms" "$number" ) &
    ;;

  contacts)
    subcmd="${2:-search}"
    query="${3:?Usage: phone_fast.sh contacts search \"name\"}"
    case "$subcmd" in
      search)
        $ADB shell "content query --uri content://com.android.contacts/contacts --projection display_name --where \"display_name LIKE '%${query}%'\"" 2>/dev/null | sed 's/Row: [0-9]* //g'
        ;;
      phones)
        $ADB shell "content query --uri content://com.android.contacts/data/phones --projection display_name:data1 --where \"display_name LIKE '%${query}%'\"" 2>/dev/null | sed 's/Row: [0-9]* //g'
        ;;
    esac
    ( _log_action "contacts" "$subcmd $query" ) &
    ;;

  call)
    number="${2:?Usage: phone_fast.sh call \"+381...\"}"
    $ADB shell "am start -a android.intent.action.CALL -d 'tel:${number}'"
    echo "Calling: $number"
    ( _log_action "call" "$number" ) &
    ;;

  # ── Event Daemon ─���
  events)
    subcmd="${2:-status}"
    case "$subcmd" in
      start)
        pkill -f phone_event_listener 2>/dev/null || true
        python3 "/media/pavle/Data/Projects 1/PhoneAgent/scripts/phone_event_listener.py" &
        echo "Event listener started. State: /tmp/.phone-state.json"
        ;;
      stop)
        ssh -i ~/.ssh/phone_agent -p 8022 -o ConnectTimeout=5 192.168.1.146 "pkill -f phone_event_daemon" 2>/dev/null || true
        pkill -f phone_event_listener 2>/dev/null || true
        rm -f /tmp/.phone-state.json
        echo "Event system stopped"
        ;;
      status)
        if [ -f /tmp/.phone-state.json ]; then
          python3 -m json.tool /tmp/.phone-state.json 2>/dev/null || cat /tmp/.phone-state.json
        else
          echo "Event system not running. Use: $0 events start"
        fi
        ;;
    esac
    ;;

  learn)
    exec bash "/media/pavle/Data/Projects 1/PhoneAgent/scripts/phone_learn.sh" "${2:-}"
    ;;

  help|*)
    echo "phone_fast.sh — Fast phone control"
    echo ""
    echo "  connect                    Connect to phone"
    echo "  nav <app>                  Launch app"
    echo "  tap <x> <y>               Tap coordinates"
    echo "  type \"text\"               Type text"
    echo "  swipe <x1> <y1> <x2> <y2> Swipe"
    echo "  scroll up|down             Scroll"
    echo "  key home|back|enter        Key press"
    echo "  screen                     Read screen (parsed UI)"
    echo "  screenshot [path]          Screenshot"
    echo "  batch \"cmd1;cmd2;...\"      Run multiple in one shell"
    echo "  info                       Device info"
    echo "  learn [date]               Analyze session log"
    echo ""
    echo "  push <file> [dir]          Push file to phone"
    echo "  pull <path> [dir]          Pull file from phone"
    echo "  copy                       Get clipboard"
    echo "  paste \"text\"              Set clipboard + paste"
    echo "  notifs [list|clear|tap N]  Notifications"
    echo "  sms \"+381...\" \"msg\"       Send SMS"
    echo "  contacts search|phones \"q\" Search contacts"
    echo "  call \"+381...\"             Make a call"
    echo "  events start|stop|status   Real-time event daemon"
    ;;
esac
