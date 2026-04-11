#!/usr/bin/env bash
# phone_learn.sh — Analyze phone session logs and find new learnings
# Cross-references with skill reference files to identify undocumented coordinates/flows
# Usage: phone_learn.sh [YYYY-MM-DD]

set -euo pipefail

REFS_DIR="$HOME/.claude/skills/phone-use/references"
LOG_DIR="/media/pavle/Data/Projects 1/PhoneAgent/logs/sessions"
DATE="${1:-$(date +%Y-%m-%d)}"
LOG_FILE="$LOG_DIR/$DATE.jsonl"

if [ ! -f "$LOG_FILE" ]; then
  echo "No session log for $DATE"
  exit 0
fi

export REFS_DIR LOG_FILE DATE

python3 << 'PYEOF'
import json, sys, os, re
from collections import defaultdict
from pathlib import Path

refs_dir = os.environ["REFS_DIR"]
log_file = os.environ["LOG_FILE"]
date = os.environ["DATE"]

# ── Load session log ──
actions = []
with open(log_file) as f:
    for line in f:
        line = line.strip()
        if line:
            try:
                actions.append(json.loads(line))
            except json.JSONDecodeError:
                pass

if not actions:
    print("No actions in log.")
    sys.exit(0)

# ── Aggregate by app ──
app_actions = defaultdict(list)
for a in actions:
    app = a.get("app", "unknown")
    pkg = app.split("/")[0] if "/" in app else app
    app_actions[pkg].append(a)

# ── Package to app name mapping ──
PKG_TO_NAME = {
    "com.linkedin.android": "linkedin",
    "com.instagram.android": "instagram",
    "com.whatsapp": "whatsapp",
    "org.telegram.messenger": "telegram",
    "com.android.chrome": "chrome",
    "com.google.android.youtube": "youtube",
    "com.google.android.gm": "gmail",
    "com.zhiliaoapp.musically": "tiktok",
    "com.twitter.android": "twitter",
    "com.facebook.katana": "facebook",
    "com.facebook.orca": "messenger",
    "com.android.settings": "settings",
    "com.sec.android.app.camera": "camera",
}

# ── Load existing references ──
ref_coords = {}
ref_files = {}
for f in Path(refs_dir).glob("*.md"):
    name = f.stem
    content = f.read_text()
    ref_files[name] = content
    coords = set()
    for m in re.finditer(r'\|\s*(\d+)\s*\|\s*(\d+)\s*\|', content):
        coords.add((int(m.group(1)), int(m.group(2))))
    for m in re.finditer(r'\((\d+),\s*(\d+)\)', content):
        coords.add((int(m.group(1)), int(m.group(2))))
    ref_coords[name] = coords

# ── Analyze each app ──
print(f"=== Phone Session Learnings — {date} ===")
print(f"Total actions: {len(actions)}")
apps_list = [PKG_TO_NAME.get(p.split("/")[0], p.split(".")[-1]) for p in app_actions.keys()]
print(f"Apps used: {', '.join(set(apps_list))}")
print()

new_apps = []
new_coords_by_app = defaultdict(set)
flows_by_app = defaultdict(list)

for pkg, pkg_actions in app_actions.items():
    base_pkg = pkg.split("/")[0] if "/" in pkg else pkg
    app_name = PKG_TO_NAME.get(base_pkg, base_pkg.split(".")[-1] if "." in base_pkg else base_pkg)

    has_ref = app_name in ref_files
    if not has_ref and app_name != "unknown":
        new_apps.append((app_name, base_pkg))

    known = ref_coords.get(app_name, set())
    for a in pkg_actions:
        if a["cmd"] == "tap":
            parts = a["args"].split()
            if len(parts) >= 2:
                try:
                    x, y = int(parts[0]), int(parts[1])
                    is_known = any(abs(x-kx) < 30 and abs(y-ky) < 30 for kx, ky in known)
                    if not is_known:
                        new_coords_by_app[app_name].add((x, y))
                except ValueError:
                    pass

    if len(pkg_actions) >= 3:
        flows_by_app[app_name] = pkg_actions

# ── Output Report ──
if new_apps:
    print("## NEW APPS (no reference file yet)")
    for name, pkg in set(new_apps):
        print(f"  - {name} ({pkg}) — needs references/{name}.md")
    print()

if new_coords_by_app:
    print("## NEW COORDINATES (not in reference files)")
    for app, coords in sorted(new_coords_by_app.items()):
        print(f"  ### {app}")
        for x, y in sorted(coords):
            print(f"    - tap ({x}, {y})")
    print()

if flows_by_app:
    print("## FLOWS EXECUTED")
    for app, flow in sorted(flows_by_app.items()):
        print(f"  ### {app} ({len(flow)} steps)")
        for a in flow[:15]:
            print(f"    $PF {a['cmd']} {a['args']}")
        if len(flow) > 15:
            print(f"    ... and {len(flow) - 15} more steps")
    print()

if not new_apps and not new_coords_by_app:
    print("All coordinates and apps already documented. Nothing new to learn.")

if new_coords_by_app:
    print("## SUGGESTED REFERENCE UPDATES")
    for app, coords in sorted(new_coords_by_app.items()):
        ref_file = f"references/{app}.md"
        if app in ref_files:
            print(f"\n  Update {ref_file} — add to coordinate table:")
            print(f"  | Element | X | Y | Notes |")
            print(f"  |---------|---|---|-------|")
            for x, y in sorted(coords):
                print(f"  | TODO-label | {x} | {y} | Discovered {date} |")
        else:
            print(f"\n  Create {ref_file} with template:")
            print(f"  # {app.title()} — UI Map & Flows")
            print(f"  Package: `{pkg}`")
            print(f"  Screen: 1080x2408 (Samsung A14)")
PYEOF
