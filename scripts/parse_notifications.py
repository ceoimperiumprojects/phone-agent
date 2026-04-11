#!/usr/bin/env python3
"""Parse dumpsys notification output into readable list."""
import sys, re

raw = sys.stdin.read()
blocks = raw.split('NotificationRecord(')
idx = 0
for block in blocks[1:]:
    pkg = re.search(r'pkg=(\S+)', block)
    title = re.search(r'android\.title=String\s*\((.*?)\)', block)
    text = re.search(r'android\.text=String\s*\((.*?)\)', block)
    when = re.search(r'when=(\d+)', block)
    pkg_name = pkg.group(1) if pkg else 'unknown'
    t = title.group(1) if title else ''
    tx = text.group(1) if text else ''
    if t or tx:
        idx += 1
        print(f'{idx}. [{pkg_name}] {t}: {tx}')

if idx == 0:
    print("No notifications.")
