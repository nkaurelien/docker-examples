# Role Ansible : Faster-Whisper (Wyoming STT Server)

Ce rôle déploie le conteneur `lscr.io/linuxserver/faster-whisper` sur le serveur avec :
- Exécution Docker Compose
- Intégration Systemd pour le démarrage automatique au boot
- Volume persistant pour les modèles IA téléchargés (`/config`)

---

## ⚙️ Variables du Rôle (`defaults/main.yml`)

```yaml
faster_whisper_image: "lscr.io/linuxserver/faster-whisper:latest"
faster_whisper_compose_dir: "/opt/faster-whisper"
faster_whisper_port: 10300
faster_whisper_model: "base-int8"    # Options: tiny-int8, base-int8, small-int8, medium-int8
faster_whisper_beam: 1
faster_whisper_lang: "auto"
```

## 🚀 Utilisation dans un Playbook

```yaml
- hosts: homelab_servers
  become: true
  roles:
    - role: faster-whisper
```
