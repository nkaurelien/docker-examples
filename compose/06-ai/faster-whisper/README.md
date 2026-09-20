# Faster-Whisper (LinuxServer.io) — STT Wyoming Server

Stack Docker Compose pour exécuter le serveur **Faster-Whisper** avec protocole **Wyoming** (optimisé CPU via CTranslate2 et quantification `int8`).

---

## 🎯 Caractéristiques

- **Image** : `lscr.io/linuxserver/faster-whisper:latest`
- **Protocole** : Wyoming (Port TCP `10300`)
- **Intégration** : Compatible nativement avec **Home Assistant** (intégration Wyoming), Rhasspy, et tout client STT Wyoming.
- **Optimisation CPU** : Utilise les modèles `int8` (ex: `base-int8`, `small-int8`) pour une vitesse maximale sur processeur x86 sans carte graphique dédiée.

---

## 🚀 Démarrage

```bash
# S'assurer que le réseau externe existe
docker network create homelab-network || true

# Lancer le conteneur
docker compose up -d
```

## ⚙️ Modèles Recommandés (CPU Acemagic K1 Mini)

| Modèle | Taille RAM requise | Vitesse relative | Qualité |
| :--- | :--- | :--- | :--- |
| `tiny-int8` | ~150 Mo | Ultra-rapide (instantané) | Basique |
| `base-int8` (Défaut) | ~250 Mo | Très rapide (~0.5s par phrase) | Bonne |
| `small-int8` | ~500 Mo | Équilibré (~1s) | Excellente |
| `medium-int8` | ~1.5 Go | Modéré (~2s) | Haute précision |
