# Homepage

Homepage is a modern, fully customizable, highly performant dashboard for self-hosted services and application portals.

## Usage

```bash
docker compose up -d
```

---

## ⚖️ Le Panorama des Application Dashboards

### 1. Comparatif : Homepage vs Homarr vs Heimdall

| Dashboard | Approche & Points Forts | Configuration |
| :--- | :--- | :--- |
| **Homepage** *(Actuel)* | **100% Déclaratif & GitOps** : Configuré par YAML, zéro base de données, widgets Docker et Kubernetes natifs. | Fichiers YAML (`services.yaml`, `settings.yaml`) |
| **Homarr** | **Modulaire & Visuel** : Système en grille dynamique avec glisser-déposer (*drag-and-drop*) et personnalisation visuelle. | Interface Web interactive (+ DB SQLite) |
| **Heimdall** | **Lanceur d'applications épuré** : Solution classique (PHP/Laravel), simple mur d'icônes avec liens directs. | Interface Web simplifiée |

### 2. Autres options notables

- **Dashy** : Très personnalisable (thèmes, widgets, checks de statut), config YAML, idéal si tu aimes tweaker l’UI dans tous les sens.
- **Glance** : Plus orienté « startpage » légère avec quelques widgets, très rapide, moins « dashboard complet ».
- **Homer / Flame / SUI** : Plutôt des pages de liens statiques, minimalistes, sans beaucoup de widgets.


