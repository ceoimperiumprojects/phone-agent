#!/bin/bash
# phone-session-summary.sh — Stop hook
# If phone was used this session, run learn and append summary to Obsidian daily note

TODAY=$(date +%Y-%m-%d)
LOG_FILE="/media/pavle/Data/Projects 1/PhoneAgent/logs/sessions/$TODAY.jsonl"

# Check if any phone session flag exists
FOUND=0
for f in /tmp/.phone-session-*; do
  [ -f "$f" ] && FOUND=1 && break
done
[ "$FOUND" -eq 0 ] && exit 0
[ ! -f "$LOG_FILE" ] && exit 0

COUNT=$(wc -l < "$LOG_FILE" 2>/dev/null || echo 0)
[ "$COUNT" -lt 3 ] && exit 0

# Run learn and capture output
LEARN_OUTPUT=$("/media/pavle/Data/Projects 1/PhoneAgent/scripts/phone_learn.sh" "$TODAY" 2>/dev/null || echo "Learn script failed")

# Append to Obsidian daily note
DAILY="$HOME/Obsidian/Imperium/Daily/$TODAY.md"
if [ -f "$DAILY" ]; then
  {
    echo ""
    echo "### Phone Session Summary ($COUNT actions)"
    echo ""
    echo "$LEARN_OUTPUT"
  } >> "$DAILY"
fi

# Clean up session flags
rm -f /tmp/.phone-session-* 2>/dev/null
