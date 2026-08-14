# Ollama Local

Déploiement d'une instance **Ollama** s'exécutant localement sur votre machine sous forme de conteneur Docker.

## Configuration requise
- Docker Engine installé.
- Si vous souhaitez exploiter l'accélération GPU sur Linux (fortement recommandé pour les performances des LLM) :
  - Un GPU NVIDIA.
  - Le [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) configuré et actif sur l'hôte.

## Démarrage rapide

1. Démarrez l'instance :
   ```bash
   docker compose up -d
   ```

2. Téléchargez et exécutez un modèle (ex: Llama 3) :
   ```bash
   docker exec -it ollama-local ollama run llama3
   ```

3. Testez l'API locale :
   ```bash
   curl http://localhost:11434/api/tags
   ```

## Support GPU NVIDIA
Si votre machine hôte dispose d'un GPU et que le toolkit NVIDIA est installé, décommentez le bloc `deploy` dans le fichier [`compose.yml`](file:///Volumes/X9%20Pro/Workspaces/nkaurelien/docker-examples/compose/06-ai/ollama-local/compose.yml) avant de lancer `docker compose up -d`.
