# Tunnel SSH conteneurisé pour Ollama

Ce projet fournit une solution clé en main pour encapsuler un tunnel SSH persistant et automatique à l'intérieur d'un conteneur léger Alpine. 

Il permet à vos applications ou à votre environnement de développement local de consommer les ressources d'une instance **Ollama** s'exécutant sur un serveur distant équipé de GPU performants (ex: un serveur NVIDIA DGX), sans ouvrir le port API `11434` sur l'internet public.

```
+------------------+                   +--------------------+
| Machine Locale   |                   | Serveur Distant    |
|                  |                   | (ex: DGX Spark)    |
|   App local      |                   |                    |
|   (yarn dev, ...)|                   |                    |
|        |         |                   |                    |
|        v         |                   |                    |
|   127.0.0.1:11500|                   |                    |
|        |         |                   |                    |
|        v         |    SSH Tunnel     |                    |
| [Docker Tunnel]  |==================>| [SSH daemon]       |
|  (port 11434)    |                   |       |            |
|                  |                   |       v            |
|                  |                   |   localhost:11434  |
|                  |                   |   [Ollama Engine]  |
+------------------+                   +--------------------+
```

## Démarrage rapide

1. Créez un fichier `.env` à partir du modèle :
   ```bash
   cp .env.example .env
   ```

2. Renseignez vos informations de connexion SSH dans le fichier `.env` (notamment `OLLAMA_SSH_PASSWORD`).

3. Lancez le tunnel en tâche de fond :
   ```bash
   docker compose up -d
   ```

4. Testez la connectivité depuis votre machine hôte :
   ```bash
   curl http://127.0.0.1:11500/api/tags
   ```

Toutes vos requêtes locales vers `http://127.0.0.1:11500` seront alors transmises de manière chiffrée et sécurisée à l'Ollama distant.
