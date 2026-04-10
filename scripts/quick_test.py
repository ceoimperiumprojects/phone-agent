#!/usr/bin/env python3
"""
Quick test — plug in phone and run this to verify everything works.
"""

from phone_controller import PhoneController, APPS
import sys

def main():
    phone = PhoneController()

    print("=" * 50)
    print("  PhoneAgent — Quick Test")
    print("=" * 50)

    # 1. Device check
    info = phone.get_device_info()
    if not info["model"]:
        print("\n[FAIL] No device connected!")
        print("  1. Plug in USB cable")
        print("  2. Accept USB debugging prompt on phone")
        print("  3. Run: adb devices")
        sys.exit(1)

    print(f"\n[OK] Device: {info['model']} (Android {info['android']})")
    print(f"[OK] Battery: {phone.get_battery_level()}%")
    print(f"[OK] WiFi IP: {phone.get_wifi_ip()}")

    # 2. Screen check
    phone.wake_screen()
    print(f"[OK] Screen is ON")

    # 3. UI tree check
    elements = phone.get_screen_text()
    print(f"[OK] UI tree: {len(elements)} elements found")

    if elements:
        print("\n--- Screen Content ---")
        for el in elements[:15]:
            label = el["text"] or el["description"]
            cx, cy = el["center"]
            click = " [TAP]" if el["clickable"] else ""
            print(f"  ({cx:4d},{cy:4d}) {label[:60]}{click}")
        if len(elements) > 15:
            print(f"  ... and {len(elements) - 15} more elements")

    # 4. Screenshot test
    path = phone.screenshot()
    print(f"\n[OK] Screenshot saved: {path}")

    # 5. Current app
    current = phone.get_current_app()
    print(f"[OK] Current app: {current}")

    print("\n" + "=" * 50)
    print("  ALL TESTS PASSED — Phone is ready!")
    print("=" * 50)
    print("\nNext steps:")
    print("  1. scrcpy          # see phone on PC")
    print("  2. python3 phone_controller.py  # interactive test")
    print(f"  3. WiFi ADB: adb tcpip 5555 && adb connect {phone.get_wifi_ip()}:5555")


if __name__ == "__main__":
    main()
