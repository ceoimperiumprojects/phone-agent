#!/bin/bash
# phone-session-learner.sh — PostToolUse hook
# Detects phone_fast.sh usage, marks session as phone-active,
# and periodically injects learning reminders into Claude context

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null || echo "")
TOOL_INPUT=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('command',''))" 2>/dev/null || echo "")
SESSION_ID=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('session_id','default'))" 2>/dev/null || echo "default")

# Only care about Bash tool calls
[ "$TOOL_NAME" != "Bash" ] && exit 0

# Check if command involves phone_fast.sh or PF variable
if ! echo "$TOOL_INPUT" | grep -qE 'phone_fast|PF.*tap|PF.*nav|PF.*type|PF.*swipe|PF.*scroll|PF.*key|PF.*screen|PF.*batch|adb.*192\.168\.1\.146'; then
  exit 0
fi

# Mark session as phone-active and track action count
FLAG="/tmp/.phone-session-${SESSION_ID}"
TODAY=$(date +%Y-%m-%d)
LOG_FILE="/media/pavle/Data/Projects 1/PhoneAgent/logs/sessions/$TODAY.jsonl"

PREV_COUNT=0
[ -f "$FLAG" ] && PREV_COUNT=$(cat "$FLAG" 2>/dev/null || echo 0)
CURR_COUNT=0
[ -f "$LOG_FILE" ] && CURR_COUNT=$(wc -l < "$LOG_FILE" 2>/dev/null || echo 0)

echo "$CURR_COUNT" > "$FLAG"

# Debounce: only inject reminder every 20 new actions
DIFF=$((CURR_COUNT - PREV_COUNT))
if [ "$DIFF" -lt 20 ] && [ "$PREV_COUNT" -gt 0 ]; then
  exit 0
fi

# Quick check for undocumented apps
REFS_DIR="$HOME/.claude/skills/phone-use/references"
NEW_THINGS=""
if [ -f "$LOG_FILE" ]; then
  while read -r pkg; do
    base=$(echo "$pkg" | cut -d/ -f1)
    case "$base" in
      com.linkedin.android) name="linkedin" ;;
      com.instagram.android) name="instagram" ;;
      com.whatsapp) name="whatsapp" ;;
      org.telegram.messenger) name="telegram" ;;
      com.google.android.youtube) name="youtube" ;;
      com.android.chrome) name="chrome" ;;
      *) name=$(echo "$base" | rev | cut -d. -f1 | rev) ;;
    esac
    [ ! -f "$REFS_DIR/$name.md" ] && [ "$name" != "unknown" ] && NEW_THINGS="${NEW_THINGS}${name} ($base), "
  done < <(grep -oP '"app":"[^"]*"' "$LOG_FILE" 2>/dev/null | sort -u | grep -oP '(?<=:"")[^"]+')
fi

MSG="PHONE SESSION ACTIVE: $CURR_COUNT actions logged today."
[ -n "$NEW_THINGS" ] && MSG="$MSG Undocumented apps: ${NEW_THINGS%, }."
MSG="$MSG When you finish the current phone task, run \\\$PF learn to review new coordinates/flows, then update references/<app>.md per the Self-Improving Protocol."

cat << EOF
{"hookSpecificOutput":{"hookEventName":"PostToolUse","additionalContext":"$MSG"}}
EOF
