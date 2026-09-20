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
git log -S "$(cat /tmp/motif-recherche)" --oneline

# Ne jamais écrire le secret recherché directement dans la ligne de commande :
# il serait enregistré dans l'historique du shell (~/.zsh_history, ~/.bash_history).
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

### 1. Construction de la table de remplacement

`git filter-repo` attend un fichier de motifs, à raison d'une règle par ligne :

```text
literal:<valeur-a-purger>==>[REDACTED]
regex:[\w.-]+@exemple\.test==>.secrets/admin-login
```

> [!CAUTION]
> **Ce fichier est un inventaire complet de vos secrets en clair.**
> C'est le piège principal de toute la procédure, et il se referme sans bruit : on
> rédige la table, on purge, puis on documente la méthode « pour la prochaine fois »
> en y recopiant la table — et le commit de documentation réintroduit dans
> l'historique exactement ce que la purge venait d'en retirer.
>
> Règles non négociables :
> - Le fichier vit dans `/tmp`, **jamais** dans l'arborescence du dépôt.
> - Il est détruit dès la purge terminée (`shred -u` plutôt que `rm`).
> - La documentation décrit la **méthode**, jamais les **valeurs**.
> - Si le dépôt publie un site (MkDocs, GitHub Pages), vérifier que la page générée
>   ne contient pas non plus ces valeurs : le HTML publié est un canal d'exposition
>   distinct de l'historique Git, et indexable par les moteurs de recherche.

Génération de la table à partir des fichiers de secrets non versionnés, sans jamais
recopier une valeur à la main :

```bash
# Les valeurs proviennent de .secrets/, ignoré par git
for f in .secrets/*-password .secrets/*-token; do
  printf 'literal:%s==>[REDACTED]\n' "$(cat "$f")"
done > /tmp/purge-rules.txt
chmod 600 /tmp/purge-rules.txt
```

### 2. Exécution du filtrage sur l'ensemble des révisions (`HEAD`)

`git filter-branch` est officiellement déconseillé par Git (lent, et sujet à des
corruptions silencieuses). L'outil recommandé est **`git-filter-repo`** :

```bash
# Sur TOUTES les références, pas seulement HEAD :
# une branche oubliée (gh-pages, une branche de feature) conserverait le secret.
git filter-repo --replace-text /tmp/purge-rules.txt --force
```

> `git filter-repo` retire le remote `origin` après réécriture, volontairement, pour
> éviter un `push` réflexe. Il faut le rétablir explicitement à l'étape 5.

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

# Détruire la table de motifs — elle contient les secrets en clair
shred -u /tmp/purge-rules.txt

# Le clone miroir de sauvegarde contient ENCORE les secrets : le détruire aussi
rm -rf ../docker-examples-backup.git
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
