#!/usr/bin/env python3
"""Phone Event Daemon — runs in Termux, streams state changes over TCP.
Polls dumpsys window/power/notification every 500ms (~300ms total).
Broadcasts only CHANGES to connected clients as JSONL."""

import subprocess, socket, json, time, threading, re

HOST = '0.0.0.0'
PORT = 9876
POLL_INTERVAL = 0.5

class PhoneMonitor:
    def __init__(self):
        self.state = {"app": "", "screen": "", "notif_count": 0}
        self.clients = []
        self.lock = threading.Lock()

    def _run(self, cmd, timeout=2):
        try:
            r = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=timeout)
            return r.stdout
        except:
            return ""

    def get_current_app(self):
        out = self._run("dumpsys window | grep mCurrentFocus")
        m = re.search(r'(\S+/\S+)', out)
        return m.group(1) if m else ""

    def get_screen_state(self):
        out = self._run("dumpsys power | grep 'Display Power'")
        return "ON" if "state=ON" in out else "OFF"

    def get_notif_count(self):
        out = self._run("dumpsys notification --noredact | grep -c 'NotificationRecord('")
        try:
            return int(out.strip())
        except:
            return 0

    def poll(self):
        app = self.get_current_app()
        screen = self.get_screen_state()
        ncount = self.get_notif_count()

        changed = {}
        if app != self.state["app"]:
            changed["app"] = app
            self.state["app"] = app
        if screen != self.state["screen"]:
            changed["screen"] = screen
            self.state["screen"] = screen
        if ncount != self.state["notif_count"]:
            changed["notif_count"] = ncount
            self.state["notif_count"] = ncount
        return changed

    def broadcast(self, event):
        msg = (json.dumps(event) + "\n").encode()
        with self.lock:
            dead = []
            for c in self.clients:
                try:
                    c.sendall(msg)
                except:
                    dead.append(c)
            for c in dead:
                self.clients.remove(c)

    def run_server(self):
        srv = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        srv.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        srv.bind((HOST, PORT))
        srv.listen(5)
        srv.settimeout(1.0)
        print(f"Event daemon listening on {HOST}:{PORT}")
        while True:
            try:
                client, addr = srv.accept()
                with self.lock:
                    self.clients.append(client)
                # Send current full state
                state_msg = {"type": "state", **self.state, "ts": time.time()}
                client.sendall((json.dumps(state_msg) + "\n").encode())
                print(f"Client connected: {addr}")
            except socket.timeout:
                pass

    def run(self):
        threading.Thread(target=self.run_server, daemon=True).start()
        print("Polling started...")
        while True:
            try:
                changed = self.poll()
                if changed:
                    changed["type"] = "change"
                    changed["ts"] = time.time()
                    self.broadcast(changed)
                    for k, v in changed.items():
                        if k not in ("type", "ts"):
                            print(f"  {k}: {v}")
            except Exception as e:
                print(f"Poll error: {e}")
            time.sleep(POLL_INTERVAL)

if __name__ == "__main__":
    PhoneMonitor().run()
