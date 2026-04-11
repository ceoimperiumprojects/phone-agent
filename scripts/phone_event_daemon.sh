#!/bin/bash
# Phone Event Daemon (BASH version) — runs in Termux, streams state via TCP
# No Python needed! Pure bash + netcat + dumpsys
# Broadcasts state changes as JSONL to connected clients on port 9876

PORT=9876
POLL_INTERVAL=1
STATE_FILE="/tmp/.phone-daemon-state"

# Initialize state
echo "" > "$STATE_FILE.app"
echo "" > "$STATE_FILE.screen"
echo "0" > "$STATE_FILE.notifs"

get_app() {
  dumpsys window 2>/dev/null | grep mCurrentFocus | grep -oP '\S+/\S+' | head -1
}

get_screen() {
  dumpsys power 2>/dev/null | grep "Display Power" | grep -o "ON\|OFF"
}

get_notif_count() {
  dumpsys notification --noredact 2>/dev/null | grep -c "NotificationRecord(" || echo 0
}

poll_and_broadcast() {
  while true; do
    app=$(get_app)
    screen=$(get_screen)
    ncount=$(get_notif_count)

    prev_app=$(cat "$STATE_FILE.app" 2>/dev/null)
    prev_screen=$(cat "$STATE_FILE.screen" 2>/dev/null)
    prev_ncount=$(cat "$STATE_FILE.notifs" 2>/dev/null)

    changed=""
    [ "$app" != "$prev_app" ] && changed="${changed}\"app\":\"$app\","
    [ "$screen" != "$prev_screen" ] && changed="${changed}\"screen\":\"$screen\","
    [ "$ncount" != "$prev_ncount" ] && changed="${changed}\"notif_count\":$ncount,"

    if [ -n "$changed" ]; then
      echo "$app" > "$STATE_FILE.app"
      echo "$screen" > "$STATE_FILE.screen"
      echo "$ncount" > "$STATE_FILE.notifs"
      ts=$(date +%s)
      msg="{\"type\":\"change\",${changed}\"ts\":$ts}"
      # Write to FIFO for connected clients
      echo "$msg" >> /tmp/.phone-daemon-events 2>/dev/null
    fi

    sleep "$POLL_INTERVAL"
  done
}

serve_clients() {
  # Simple TCP server using socat or nc
  rm -f /tmp/.phone-daemon-events
  mkfifo /tmp/.phone-daemon-events 2>/dev/null || true

  while true; do
    # Send initial state + stream changes
    {
      app=$(cat "$STATE_FILE.app" 2>/dev/null)
      screen=$(cat "$STATE_FILE.screen" 2>/dev/null)
      ncount=$(cat "$STATE_FILE.notifs" 2>/dev/null || echo 0)
      echo "{\"type\":\"state\",\"app\":\"$app\",\"screen\":\"$screen\",\"notif_count\":${ncount:-0},\"ts\":$(date +%s)}"
      tail -f /tmp/.phone-daemon-events 2>/dev/null
    } | nc -l -p "$PORT" -q 1 2>/dev/null || sleep 1
  done
}

echo "Phone Event Daemon starting on port $PORT..."
# Run poller in background
poll_and_broadcast &
POLLER_PID=$!

# Serve clients (foreground)
trap "kill $POLLER_PID 2>/dev/null; rm -f /tmp/.phone-daemon-events $STATE_FILE.*; exit" INT TERM
serve_clients
