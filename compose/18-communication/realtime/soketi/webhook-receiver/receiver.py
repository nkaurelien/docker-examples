"""Récepteur de webhooks Soketi (stdlib) : vérifie X-Pusher-Signature et journalise connecté / déconnecté."""

import hashlib
import hmac
import json
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

KEY = os.environ["SOKETI_APP_KEY"]
SECRET = os.environ["SOKETI_APP_SECRET"].encode()
PORT = int(os.environ.get("PORT", "8000"))
LABELS = {"channel_occupied": "connecté", "channel_vacated": "déconnecté"}


class Handler(BaseHTTPRequestHandler):
    def do_POST(self):
        body = self.rfile.read(int(self.headers.get("Content-Length", 0)))
        expected = hmac.new(SECRET, body, hashlib.sha256).hexdigest()
        signature = self.headers.get("X-Pusher-Signature", "")
        if self.headers.get("X-Pusher-Key") != KEY or not hmac.compare_digest(expected, signature):
            self.send_response(401)
            self.end_headers()
            print("webhook rejeté : signature invalide", flush=True)
            return
        for event in json.loads(body).get("events", []):
            channel = event.get("channel", "")
            user = channel.rsplit(".", 1)[-1]
            print(f"{LABELS.get(event.get('name'), event.get('name'))} : utilisateur {user} ({channel})", flush=True)
        self.send_response(200)
        self.end_headers()

    def do_GET(self):
        self.send_response(200 if self.path == "/health" else 404)
        self.end_headers()

    def log_message(self, *args):
        pass


if __name__ == "__main__":
    print(f"récepteur de webhooks Soketi sur :{PORT}", flush=True)
    ThreadingHTTPServer(("0.0.0.0", PORT), Handler).serve_forever()
