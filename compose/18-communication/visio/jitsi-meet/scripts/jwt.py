#!/usr/bin/env python3
"""Jeton d'accès Jitsi (HS256) pour tester une salle — bibliothèque standard uniquement.

    python3 scripts/jwt.py <salle> [--name "Dr Martin"] [--moderator] [--minutes 120]

Lit JWT_APP_ID / JWT_APP_SECRET / PUBLIC_URL dans .env et affiche l'URL de la salle.
`context.user.id` est l'identifiant renvoyé par event_sync : mettez-y l'id de votre utilisateur.
"""

import argparse
import base64
import hashlib
import hmac
import json
import time
from pathlib import Path


def env(path=".env"):
    out = {}
    for line in Path(path).read_text().splitlines():
        if "=" in line and not line.lstrip().startswith("#"):
            key, value = line.split("=", 1)
            out[key.strip()] = value.strip()
    return out


def b64(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("room")
    parser.add_argument("--name", default="Test")
    parser.add_argument("--user-id", default="user-1")
    parser.add_argument("--moderator", action="store_true")
    parser.add_argument("--minutes", type=int, default=120)
    args = parser.parse_args()

    conf = env()
    now = int(time.time())
    payload = {
        "aud": "jitsi",
        "iss": conf["JWT_APP_ID"],
        "sub": "*",
        "room": args.room,
        "nbf": now - 60,
        "exp": now + args.minutes * 60,
        "context": {"user": {"id": args.user_id, "name": args.name, "moderator": args.moderator}},
    }
    header = b64(json.dumps({"alg": "HS256", "typ": "JWT"}).encode())
    body = b64(json.dumps(payload).encode())
    sig = hmac.new(conf["JWT_APP_SECRET"].encode(), f"{header}.{body}".encode(), hashlib.sha256).digest()
    print(f"{conf['PUBLIC_URL'].rstrip('/')}/{args.room}?jwt={header}.{body}.{b64(sig)}")


if __name__ == "__main__":
    main()
