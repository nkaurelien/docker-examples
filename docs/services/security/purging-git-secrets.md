---
tags: git, security, secrets, git-filter-branch, devsecops, cleanup
---

# Guide de Purge et de Nettoyage des Secrets dans l'Historique Git

Ce document décrit la procédure complète et éprouvée pour identifier, assainir et purger définitivement des secrets ou données sensibles (mots de passe, clés d'API, adresses e-mail) accidentellement committés dans l'historique d'un dépôt Git.

---

## 🎯 Contexte & Objectif

Lors du développement d'infrastructures IaC ou de stacks Docker, des clés secrètes ou informations personnelles peuvent s'infiltrer dans des révisions historiques. Supprimer simplement le fichier ou le texte dans un nouveau commit **ne suffit pas** : Git conserve l'intégralité des versions antérieures dans sa base d'objets.

L'objectif est d'effectuer une réécriture propre et exhaustive de l'historique Git tout en préservant l'intégrité de la structure des commits.

---

## 🔍 Étape 1 : Diagnostic et Localisation des Fuites

### 1. Lister les fichiers modifiés dans l'historique sous un dossier sensible
```bash
git log --all --full-history --name-only -- ".secrets/" | grep -E "^\.secrets/" | sort -u
```

### 2. Rechercher des motifs de secrets spécifiques (Regex / String matching)
```bash
# Rechercher les commits contenant une chaîne spécifique (ex: email ou mot de passe)
git log -S "admin@kamitbrains.fr" --oneline
git log -S "F0rg3j0#2026!" --oneline
```

---

## 🛡️ Étape 2 : Sauvegarde de Sécurité (Obligatoire)

Avant toute opération de réécriture d'historique, créez toujours une branche ou une copie locale de secours :

```bash
# Créer une branche de sauvegarde locale
git branch backup-main-before-purge

# Optionnel : Faire un clone miroir complet du dépôt
git clone --mirror file://. ../docker-examples-backup.git
```

---

## 🧹 Étape 3 : Assainissement avec Script `tree-filter`

Nous utilisons `git filter-branch` avec un script Python (`/tmp/sanitize_tree.py`) exécuté à chaque commit réécrit.

### 1. Écriture du script d'assainissement (`/tmp/sanitize_tree.py`)

```python
import os
import glob
import re

SECRETS_DIR = ".secrets"

# Table de remplacement Regex (Motif -> Valeur assainie)
REPLACEMENTS = [
    (r"admin@kamitbrains\.fr", ".secrets/admin-login"),
    (r"nkaurelien@gmail\.com", ".secrets/user-nkaurelien-login"),
    (r"etombe_ndedi@hotmail\.fr", ".secrets/user-etombe-login"),
    (r"kamitbrains_admin", ".secrets/forgejo-admin-login"),
    # Mots de passe & Clés secrètes
    (r"F0rg3j0#2026!S3cur3P@ssw0rd!X9", "[REDACTED]"),
    (r"ErUg0#2026!S3cur3P@ssw0rd!X9", "[REDACTED]"),
    (r"H3dg3D0c#2026!S3cur3P@ssw0rd!X9", "[REDACTED]"),
    (r"G!itchT!p2026S3cur3P@ssw0rd!X9", "[REDACTED]"),
    (r"Jupyter2026S3cur3Tok3n!X9", "[REDACTED]"),
]

if os.path.exists(SECRETS_DIR):
    for filepath in glob.glob(os.path.join(SECRETS_DIR, "*.md")):
        try:
            with open(filepath, "r", encoding="utf-8") as f:
                content = f.read()
            new_content = content
            for pattern, repl in REPLACEMENTS:
                new_content = re.sub(pattern, repl, new_content)
            if new_content != content:
                with open(filepath, "w", encoding="utf-8") as f:
                    f.write(new_content)
        except Exception:
            pass
```

### 2. Exécution du filtrage sur l'ensemble des révisions (`HEAD`)

```bash
FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch -f --tree-filter 'python3 /tmp/sanitize_tree.py' HEAD
```

---

## 🗑️ Étape 4 : Purge Complète des Objets Obsolètes & Reflog

`git filter-branch` conserve des copies de sauvegarde dans `refs/original/`. Tant que ces références existent, les anciens secrets restent présents dans l'annuaire d'objets Git local.

### 1. Supprimer les références de sauvegarde
```bash
# Supprimer les références originelles créées par filter-branch
git update-ref -d refs/original/refs/heads/main
rm -rf .git/refs/original/
```

### 2. Expirer le reflog et purger la mémoire d'objets orphelins (Garbage Collection)
```bash
# Expirer immédiatement le reflog
git reflog expire --expire=now --all

# Forcer la collecte des déchets et la compression agressive
git gc --prune=now --aggressive
```

---

## 🚀 Étape 5 : Force-Push vers le Dépôt Distant (GitHub)

Une fois l'historique local assaini et vérifié avec `git log -S`, mettez à jour le dépôt distant :

```bash
# Force push vers la branche main distante
git push origin main --force
```

> [!WARNING]
> Le `--force-push` réécrit l'historique sur le serveur distants. Tous les autres collaborateurs du dépôt devront ré-effectuer un clone propre ou effectuer `git reset --hard origin/main`.

### Nettoyage post-vérification
```bash
# Supprimer la branche de backup une fois le succès confirmé
git branch -D backup-main-before-purge
rm -f /tmp/sanitize_tree.py
```

---

## 🛡️ Bonnes Pratiques Préventives

1. **Règles `.gitignore` strictes** :
   ```gitignore
   # Exclure tous les fichiers du dossier .secrets sauf la documentation markdown
   .secrets/*
   !.secrets/*.md
   *.csv
   *.pem
   *.key
   ```
2. **Scans automatisés avec TruffleHog / Gitleaks / Snyk** :
   ```bash
   trufflehog git file://. --only-verified
   ```
3. **Fichiers de passpass séparés** : Toujours stocker les valeurs sensibles brutes dans des fichiers non versionnés dans `.secrets/<service>-password` et utiliser la fonction Ansible `lookup('file', ...)` ou des variables d'environnement Docker `.env`.

---

## 📚 Ressources

- [Documentation officielle Git filter-branch](https://git-scm.com/docs/git-filter-branch)
- [Alternative moderne : git-filter-repo](https://github.com/newren/git-filter-repo)
- [Guide GitHub : Removing sensitive data from a repository](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
