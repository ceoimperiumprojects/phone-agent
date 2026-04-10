#!/bin/bash
# Setup WiFi ADB — run once while phone is USB connected
# After this, phone works wirelessly

set -e

echo "=== PhoneAgent WiFi ADB Setup ==="

# Check USB connection
DEVICE=$(adb devices | grep -v "List" | grep "device" | head -1)
if [ -z "$DEVICE" ]; then
    echo "[FAIL] No device connected via USB!"
    echo "  Plug in USB cable and accept debugging prompt on phone"
    exit 1
fi

echo "[OK] Device found via USB"

# Switch to TCP/IP mode
echo "[...] Switching to WiFi mode..."
adb tcpip 5555
sleep 2

# Get phone IP
PHONE_IP=$(adb shell ip addr show wlan0 | grep "inet " | awk '{print $2}' | cut -d/ -f1)

if [ -z "$PHONE_IP" ]; then
    echo "[FAIL] Could not detect phone WiFi IP"
    echo "  Make sure phone is connected to WiFi"
    exit 1
fi

echo "[OK] Phone IP: $PHONE_IP"

# Connect wirelessly
echo "[...] Connecting wirelessly..."
adb connect "$PHONE_IP:5555"
sleep 1

# Verify
echo "[...] Verifying..."
adb devices

echo ""
echo "=== SUCCESS ==="
echo "Phone is now wireless! You can unplug USB."
echo ""
echo "To reconnect later:"
echo "  adb connect $PHONE_IP:5555"
echo ""
echo "To start scrcpy wirelessly:"
echo "  scrcpy --tcpip=$PHONE_IP:5555"
