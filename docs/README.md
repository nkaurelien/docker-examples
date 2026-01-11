# Documentation MkDocs

Ce dossier contient la documentation du projet, générée avec [MkDocs Material](https://squidfunk.github.io/mkdocs-material/).

## Prérequis

- Python 3.8+
- pip

## Installation

```bash
# Avec uv (recommandé)
uv pip install -r requirements-docs.txt

# Ou avec pip
pip install -r requirements-docs.txt
```

## Lancer la documentation en local

```bash
# Depuis la racine du projet
mkdocs serve
```

La documentation sera accessible sur [http://127.0.0.1:8000](http://127.0.0.1:8000).

### Options utiles

```bash
# Changer le port
mkdocs serve -a 127.0.0.1:8080

# Rechargement automatique strict (arrête sur erreurs)
mkdocs serve --strict

# Mode verbeux
mkdocs serve -v
```

## Construire la documentation

```bash
# Génère le site statique dans ./site/
mkdocs build
```

## Structure

```
docs/
├── index.md                    # Page d'accueil
├── getting-started/            # Guide de démarrage
├── docker/                     # Concepts Docker
├── services/                   # Documentation des services
│   ├── api-management/
│   ├── auth/
│   ├── databases/
│   ├── mail/
│   ├── monitoring/
│   ├── orchestration/
│   ├── security/
│   └── surveillance/
└── reference/                  # Références techniques
```

## Configuration

La configuration MkDocs se trouve dans `mkdocs.yml` à la racine du projet.
