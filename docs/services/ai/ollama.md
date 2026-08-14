# Ollama & SSH Tunnel setups

Ce guide détaille le déploiement d'Ollama et l'accès à distance sécurisé via un tunnel SSH conteneurisé.

## 1. Déploiement Local d'Ollama (`ollama-local`)

Pour exécuter Ollama localement en mode CPU ou avec l'accélération matérielle NVIDIA GPU (CUDA), utilisez la configuration suivante :

```yaml
version: '3.8'

services:
  ollama:
    image: ollama/ollama:latest
    container_name: ollama-local
    restart: unless-stopped
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama
    # Activer l'accélération GPU Nvidia (requiert nvidia-container-toolkit sur l'hôte)
    # deploy:
    #   resources:
    #     reservations:
    #       devices:
    #         - driver: nvidia
    #           count: all
    #           capabilities: [gpu]

volumes:
  ollama_data:
    name: ollama_local_data
```

---

## 2. Exploitation d'un Tunnel SSH conteneurisé (`dgx-ollama-tunnel`)

Plutôt que d'exposer publiquement le port API `11434` de votre serveur de calcul GPU (ex: NVIDIA DGX) ou d'initier un tunnel SSH manuel, vous pouvez encapsuler le tunnel SSH persistant dans un conteneur léger. 

Ce service maintient le tunnel chiffré ouvert et se reconnecte automatiquement en tâche de fond.

### Configuration du Tunnel (`compose.yml`)

```yaml
name: dgx-ollama-tunnel

services:
  dgx-ollama-tunnel:
    image: alpine:latest
    container_name: dgx-ollama-tunnel
    restart: always
    ports:
      # Publie le port 11500 sur localhost uniquement (sécurisé)
      - "127.0.0.1:11500:11434"
    entrypoint: >
      sh -c "apk add --no-cache openssh-client sshpass &&
      sshpass -p \"$$OLLAMA_SSH_PASSWORD\"
      ssh -N -L 0.0.0.0:11434:localhost:11434
      -o StrictHostKeyChecking=no -o ServerAliveInterval=30 -o ServerAliveCountMax=3
      -p $$OLLAMA_SSH_PORT $$OLLAMA_SSH_USER@$$OLLAMA_SSH_HOST"
    environment:
      OLLAMA_SSH_HOST: ${OLLAMA_SSH_HOST:-90.92.253.107}
      OLLAMA_SSH_PORT: ${OLLAMA_SSH_PORT:-2224}
      OLLAMA_SSH_USER: ${OLLAMA_SSH_USER:-aurelien}
      OLLAMA_SSH_PASSWORD: ${OLLAMA_SSH_PASSWORD:?OLLAMA_SSH_PASSWORD requis (voir .env)}
    healthcheck:
      test: ["CMD", "sh", "-c", "wget -qO- http://localhost:11434/api/tags >/dev/null 2>&1 || exit 1"]
      interval: 30s
      timeout: 5s
      retries: 5
      start_period: 20s
```

### Avantages de cette approche :
1. **Zéro configuration SSH sur l'hôte** : Tout est encapsulé dans le conteneur `alpine`.
2. **Auto-healing** : En cas de coupure réseau, Docker relance le conteneur qui ré-établit la session SSH.
3. **Sécurité locale** : Le port `11500` est publié sur `127.0.0.1`, évitant ainsi d'exposer l'API Ollama distante aux autres machines de votre réseau local.
4. **Intégration transparente** : Vos outils (comme `open-webui` ou votre application Next.js locale en développement) interrogent `http://127.0.0.1:11500` comme s'il s'agissait d'un serveur local.
