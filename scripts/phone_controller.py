#!/usr/bin/env python3
"""
PhoneAgent — AI Phone Controller
Controls Android phone via ADB from PC.
PC = Brain, Phone = Hands + Eyes.
"""

import subprocess
import xml.etree.ElementTree as ET
import time
import json
import re
import os
from datetime import datetime

LOG_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "logs")


class PhoneController:
    """Controls Android phone via ADB from PC"""

    def __init__(self, device_ip=None):
        self.device = f"-s {device_ip}:5555" if device_ip else ""
        self.action_log = []

    def _adb(self, cmd):
        """Run ADB command and return output"""
        full_cmd = f"adb {self.device} {cmd}"
        result = subprocess.run(full_cmd, shell=True, capture_output=True, text=True)
        return result.stdout.strip()

    def _log_action(self, action, details=""):
        entry = {
            "timestamp": datetime.now().isoformat(),
            "action": action,
            "details": details
        }
        self.action_log.append(entry)

    # === INPUT ACTIONS ===

    def tap(self, x, y):
        """Tap at coordinates"""
        self._adb(f"shell input tap {x} {y}")
        self._log_action("tap", f"{x},{y}")
        time.sleep(0.5)

    def type_text(self, text):
        """Type text (escapes special chars)"""
        escaped = text.replace(" ", "%s").replace("'", "\\'").replace("&", "\\&")
        self._adb(f"shell input text '{escaped}'")
        self._log_action("type", text)
        time.sleep(0.3)

    def swipe(self, x1, y1, x2, y2, duration=300):
        """Swipe gesture"""
        self._adb(f"shell input swipe {x1} {y1} {x2} {y2} {duration}")
        self._log_action("swipe", f"{x1},{y1} → {x2},{y2}")
        time.sleep(0.5)

    def scroll_up(self):
        self.swipe(540, 1500, 540, 500)

    def scroll_down(self):
        self.swipe(540, 500, 540, 1500)

    def press_home(self):
        self._adb("shell input keyevent 3")
        self._log_action("press", "HOME")

    def press_back(self):
        self._adb("shell input keyevent 4")
        self._log_action("press", "BACK")

    def press_enter(self):
        self._adb("shell input keyevent 66")
        self._log_action("press", "ENTER")

    def press_recent_apps(self):
        self._adb("shell input keyevent 187")
        self._log_action("press", "RECENT_APPS")

    def clear_text(self, char_count=50):
        """Clear text field by selecting all and deleting"""
        self._adb("shell input keyevent 29 --longpress")  # CTRL+A select all
        time.sleep(0.2)
        self._adb("shell input keyevent 67")  # DELETE
        self._log_action("clear_text", f"{char_count} chars")

    # === APP CONTROL ===

    def launch_app(self, package, activity=""):
        """Launch an app by package name"""
        if activity:
            self._adb(f"shell am start -n {package}/{activity}")
        else:
            self._adb(f"shell monkey -p {package} 1")
        self._log_action("launch", package)
        time.sleep(3)

    def close_app(self, package):
        """Force stop an app"""
        self._adb(f"shell am force-stop {package}")
        self._log_action("close", package)

    def get_current_app(self):
        """Get currently focused app package"""
        output = self._adb("shell dumpsys window | grep -E 'mCurrentFocus'")
        match = re.search(r'(\S+)/(\S+)', output)
        if match:
            return match.group(1)
        return None

    def is_screen_on(self):
        """Check if screen is on"""
        output = self._adb("shell dumpsys power | grep 'Display Power'")
        return "ON" in output

    def wake_screen(self):
        """Wake up screen"""
        if not self.is_screen_on():
            self._adb("shell input keyevent 26")  # POWER
            time.sleep(1)

    # === SCREEN READING ===

    def get_screen_text(self):
        """Dump UI tree and extract all text elements"""
        self._adb("shell uiautomator dump /sdcard/ui.xml")
        self._adb("pull /sdcard/ui.xml /tmp/ui.xml")

        try:
            tree = ET.parse("/tmp/ui.xml")
        except ET.ParseError:
            return []

        root = tree.getroot()
        elements = []

        for node in root.iter("node"):
            text = node.get("text", "")
            desc = node.get("content-desc", "")
            bounds = node.get("bounds", "")
            clickable = node.get("clickable", "false")
            class_name = node.get("class", "")
            resource_id = node.get("resource-id", "")

            if text or desc:
                # Parse bounds "[x1,y1][x2,y2]"
                coords = self._parse_bounds(bounds)
                elements.append({
                    "text": text,
                    "description": desc,
                    "bounds": bounds,
                    "center": coords,
                    "clickable": clickable == "true",
                    "class": class_name,
                    "resource_id": resource_id
                })

        return elements

    def get_screen_summary(self):
        """Get a concise summary of what's on screen — for LLM consumption"""
        elements = self.get_screen_text()
        lines = []
        for el in elements:
            label = el["text"] or el["description"]
            click = " [CLICKABLE]" if el["clickable"] else ""
            cx, cy = el["center"] if el["center"] else (0, 0)
            lines.append(f"  ({cx},{cy}) {label}{click}")
        return "\n".join(lines)

    def screenshot(self, local_path="/tmp/screen.png"):
        """Take screenshot and pull to PC"""
        self._adb("shell screencap /sdcard/screen.png")
        self._adb("pull /sdcard/screen.png " + local_path)
        self._log_action("screenshot", local_path)
        return local_path

    # === SMART ACTIONS ===

    def find_and_tap(self, target_text):
        """Find element by text and tap its center"""
        elements = self.get_screen_text()
        for el in elements:
            if target_text.lower() in el["text"].lower() or target_text.lower() in el["description"].lower():
                cx, cy = el["center"]
                if cx and cy:
                    self.tap(cx, cy)
                    self._log_action("find_and_tap", target_text)
                    return True
        return False

    def wait_for_element(self, text, timeout=10):
        """Wait until element with text appears on screen"""
        start = time.time()
        while time.time() - start < timeout:
            elements = self.get_screen_text()
            for el in elements:
                if text.lower() in el["text"].lower():
                    return True
            time.sleep(1)
        return False

    def find_element(self, text):
        """Find element by text, return its info or None"""
        elements = self.get_screen_text()
        for el in elements:
            if text.lower() in el["text"].lower() or text.lower() in el["description"].lower():
                return el
        return None

    # === NOTIFICATIONS ===

    def get_notifications(self):
        """Get current notifications"""
        output = self._adb("shell dumpsys notification --noredact")
        return output

    def open_notification_bar(self):
        """Pull down notification bar"""
        self.swipe(540, 0, 540, 1000, 200)
        time.sleep(1)

    def close_notification_bar(self):
        """Close notification bar"""
        self.swipe(540, 1000, 540, 0, 200)
        time.sleep(0.5)

    # === DEVICE INFO ===

    def get_battery_level(self):
        """Get battery percentage"""
        output = self._adb("shell dumpsys battery | grep level")
        match = re.search(r'level: (\d+)', output)
        return int(match.group(1)) if match else None

    def get_wifi_ip(self):
        """Get phone's WiFi IP address"""
        output = self._adb("shell ip addr show wlan0")
        match = re.search(r'inet (\d+\.\d+\.\d+\.\d+)', output)
        return match.group(1) if match else None

    def get_device_info(self):
        """Get basic device info"""
        model = self._adb("shell getprop ro.product.model")
        android_ver = self._adb("shell getprop ro.build.version.release")
        return {"model": model, "android": android_ver}

    # === HELPERS ===

    @staticmethod
    def _parse_bounds(bounds_str):
        """Parse '[x1,y1][x2,y2]' into center (cx, cy)"""
        match = re.match(r'\[(\d+),(\d+)\]\[(\d+),(\d+)\]', bounds_str)
        if match:
            x1, y1, x2, y2 = map(int, match.groups())
            return ((x1 + x2) // 2, (y1 + y2) // 2)
        return (0, 0)

    def save_log(self, filename=None):
        """Save action log to file"""
        if not filename:
            filename = os.path.join(LOG_DIR, f"{datetime.now().strftime('%Y-%m-%d')}.json")
        os.makedirs(os.path.dirname(filename), exist_ok=True)
        with open(filename, "a") as f:
            for entry in self.action_log:
                f.write(json.dumps(entry) + "\n")
        self.action_log = []


# === COMMON APP PACKAGES ===
APPS = {
    "linkedin": "com.linkedin.android",
    "instagram": "com.instagram.android",
    "whatsapp": "com.whatsapp",
    "telegram": "org.telegram.messenger",
    "messenger": "com.facebook.orca",
    "chrome": "com.android.chrome",
    "settings": "com.android.settings",
    "camera": "com.sec.android.app.camera",
    "youtube": "com.google.android.youtube",
    "gmail": "com.google.android.gm",
    "maps": "com.google.android.apps.maps",
    "play_store": "com.android.vending",
}


if __name__ == "__main__":
    phone = PhoneController()

    # Quick status check
    info = phone.get_device_info()
    if info["model"]:
        print(f"Connected: {info['model']} (Android {info['android']})")
        print(f"Battery: {phone.get_battery_level()}%")
        print(f"WiFi IP: {phone.get_wifi_ip()}")
        print(f"Screen ON: {phone.is_screen_on()}")
        print(f"Current app: {phone.get_current_app()}")
        print(f"\nScreen elements:")
        print(phone.get_screen_summary())
    else:
        print("No device connected. Run: adb devices")
