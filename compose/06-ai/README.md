# Ollama & SSH Tunnel setups

Ce répertoire contient des configurations Docker Compose pour faire tourner **Ollama** (moteur d'exécution de LLM en local) ou pour exploiter un **Tunnel SSH conteneurisé** permettant de se connecter de façon transparente à une instance Ollama distante (par exemple hébergée sur un serveur équipé de GPU puissant comme un NVIDIA DGX), sans exposer publiquement de ports sensibles.

## Structure des projets de ce dossier

* **[`ollama-local/`](file:///Volumes/X9%20Pro/Workspaces/nkaurelien/docker-examples/compose/06-ai/ollama-local/)** : Déploiement d'Ollama en local avec support optionnel pour l'accélération matérielle NVIDIA GPU (CUDA).
* **[`dgx-ollama-tunnel/`](file:///Volumes/X9%20Pro/Workspaces/nkaurelien/docker-examples/compose/06-ai/dgx-ollama-tunnel/)** : Tunnel SSH conteneurisé automatique pour encapsuler l'accès à un Ollama distant.
* **[`open-webui/`](file:///Volumes/X9%20Pro/Workspaces/nkaurelien/docker-examples/compose/06-ai/open-webui/)** : Interface utilisateur web pour interagir avec Ollama.
* **[`jupyter/`](file:///Volumes/X9%20Pro/Workspaces/nkaurelien/docker-examples/compose/06-ai/jupyter/)** : Notebooks pour la Data Science et le prototypage.
