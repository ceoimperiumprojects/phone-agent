# Troubleshooting — Phone Connection & Common Issues

## Connection

### Connect via WiFi ADB
```bash
adb connect 192.168.1.146:5555
adb -s 192.168.1.146:5555 devices
```

### ADB Not Connecting
```bash
adb kill-server && adb start-server
adb connect 192.168.1.146:5555
```
If still failing: check phone is on same WiFi network, ADB debugging enabled in developer options.

### SSH Access (Termux)
```bash
ssh -i ~/.ssh/phone_agent -p 8022 192.168.1.146
```
If failing:
- On phone in Termux: run `sshd`
- Or reboot phone — Termux:Boot auto-starts sshd + WiFi wake lock

### Phone Rebooted
Termux:Boot automatically starts:
- SSH server (sshd)
- WiFi wake lock
After boot: `adb connect 192.168.1.146:5555`

## Screen Issues

### UI Element Not Found
1. Run `$PF screen` to see what's actually on screen
2. If empty output — screen might be locked or app crashed
3. `$PF key home` then retry
4. Take screenshot for visual debug: `$PF screenshot`

### Screen Turned Off
```bash
$PF batch "input keyevent 26"   # Power button to wake
```
Should not happen — phone is set to stay_on_while_plugged_in.

### Wrong App in Foreground
```bash
$PF info   # Shows current app
$PF key home  # Go home first
$PF nav linkedin  # Then launch target app
```

## App Issues

### App Crashed
```bash
$ADB shell am force-stop <package>
$PF nav <app>   # Relaunch
```

### App Updated — UI Changed
1. Do a `$PF screen` to see new layout
2. Update the relevant `references/<app>.md` with new coordinates
3. Disable auto-update: Settings → Play Store → Auto-update → Don't auto-update

### Restore Deleted Package
```bash
adb -s 192.168.1.146:5555 shell cmd package install-existing com.package.name
```

## Performance

### ADB Commands Slow
- Use `$PF batch` to chain multiple commands in one ADB shell session
- Minimize `$PF screen` calls (slowest command, ~2-3s each)
- Use learned coordinates from reference files instead of screen reads

### Phone Laggy
- Check RAM: `$ADB shell dumpsys meminfo | head -5`
- Kill background apps: `$ADB shell am kill-all`
- Debloat script: `/media/pavle/Data/Projects 1/PhoneAgent/scripts/samsung_a14_debloat.sh`

## Learned Fixes

(Add new troubleshooting solutions here as you discover them)
