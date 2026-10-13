---
tags: communication, visio, jitsi, webrtc, turn, coturn, jwt
---

# Jitsi Meet auto-hébergé

Visioconférence Jitsi en Docker Compose, prête pour être intégrée en iframe dans une application :

- accès **par jeton JWT** signé par votre backend, sans invités anonymes ;
- **événements de salle** (création, entrées, sorties, fermeture) envoyés à votre backend (`event_sync`) ;
- relais **TURN** optionnel (coturn local, ou service géré) pour les réseaux qui bloquent l'UDP ;
- reverse proxy avec règle `frame-ancestors` (`nginx/meet.conf.example`).

```bash
make setup          # .env + secrets générés
# éditer .env : PUBLIC_URL, JVB_ADVERTISE_IPS, JWT_APP_ID
make up
make token ROOM=salle-test NAME="Dr Test" MOD=1   # URL de test
```

Documentation complète : [`docs/services/communication/jitsi-meet.md`](../../../../docs/services/communication/jitsi-meet.md).
