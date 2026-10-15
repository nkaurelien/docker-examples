"""Publie un événement de test sur Soketi avec le SDK Python `pusher` (comme le ferait un backend).

Usage : python publish.py [canal] [message]
"""

import os
import sys
import uuid

import pusher

channel = sys.argv[1] if len(sys.argv) > 1 else "demo-user.42"
message = sys.argv[2] if len(sys.argv) > 2 else "Nouveau rendez-vous"

client = pusher.Pusher(
    app_id=os.environ["SOKETI_APP_ID"],  # numérique, sinon ValueError: Invalid app id
    key=os.environ["SOKETI_APP_KEY"],
    secret=os.environ["SOKETI_APP_SECRET"],
    host=os.environ.get("SOKETI_HOST", "127.0.0.1"),
    port=int(os.environ.get("SOKETI_PORT", "6001")),
    ssl=False,
)

# En production, l'événement ne porte qu'une référence : le client relit le contenu par l'API.
payload = {
    "id": str(uuid.uuid4()),
    "type": "appointment.created",
    "priority": 3,
    "actions": [{"action": "view", "code": "appointment.open", "params": {"appointment_id": "a-123"}}],
    "demo_text": message,
}
client.trigger(channel, "notification.created", payload)
print(f"publié sur {channel} : {payload['id']}")
