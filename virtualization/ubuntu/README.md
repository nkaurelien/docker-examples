# Ubuntu Desktop avec Docker

Ce projet permet d'exécuter Ubuntu Desktop dans un conteneur Docker en utilisant l'image [dockurr/ubuntu](https://github.com/dockur/ubuntu).

## Prérequis

- Docker et Docker Compose installés
- Support KVM activé sur votre système (Linux/macOS avec virtualisation)
- Au moins 4 Go de RAM disponible
- Au moins 32 Go d'espace disque

## Démarrage

### Lancer Ubuntu Desktop

```bash
docker compose up -d
```

### Suivre les logs

```bash
docker compose logs -f ubuntu
```

Le premier démarrage peut prendre 5-10 minutes.

## Accès à Ubuntu

### Option 1 : Interface Web (noVNC)

Ouvrez votre navigateur et accédez à :
```
http://localhost:8008
```

### Option 2 : VNC

Utilisez un client VNC :
```
localhost:5901
```

### Option 3 : SSH

```bash
ssh user@localhost -p 2222
```

**Identifiants par défaut** :
- Utilisateur : `ubuntu`
- Mot de passe : `ubuntu`

⚠️ **Changez le mot de passe après la première connexion !**

## Configuration

### Variables d'environnement

| Variable | Description | Valeur par défaut |
|----------|-------------|-------------------|
| `VERSION` | Version d'Ubuntu | `24.04` |
| `RAM_SIZE` | Quantité de RAM allouée | `4G` |
| `CPU_CORES` | Nombre de cœurs CPU | `2` |
| `DISK_SIZE` | Taille du disque virtuel | `32G` |

### Versions d'Ubuntu disponibles

- `24.04` - Ubuntu 24.04 LTS (Noble Numbat)
- `23.10` - Ubuntu 23.10 (Mantic Minotaur)
- `22.04` - Ubuntu 22.04 LTS (Jammy Jellyfish)
- `20.04` - Ubuntu 20.04 LTS (Focal Fossa)

## Partage de fichiers

Un dossier `shared` est monté dans le conteneur à `/shared`. Vous pouvez l'utiliser pour échanger des fichiers entre votre hôte et Ubuntu.

```bash
# Créer le dossier partagé
mkdir -p shared

# Copier un fichier dans le dossier partagé
cp mon-fichier.txt shared/
```

Le fichier sera accessible dans Ubuntu à `/shared/mon-fichier.txt`.

## Gestion

### Arrêter Ubuntu

```bash
docker compose stop
```

### Redémarrer Ubuntu

```bash
docker compose restart
```

### Supprimer le conteneur (conserver les données)

```bash
docker compose down
```

### Supprimer complètement (y compris les données)

```bash
docker compose down -v
```

## Installation de logiciels

Une fois connecté à Ubuntu, vous pouvez installer des logiciels avec apt :

```bash
# Mettre à jour les paquets
sudo apt update

# Installer des logiciels
sudo apt install -y vim git curl wget

# Installer des outils de développement
sudo apt install -y build-essential python3 nodejs npm
```

## Dépannage

### Le conteneur ne démarre pas

Vérifiez les logs :
```bash
docker compose logs ubuntu
```

### Impossible de se connecter via SSH

1. Attendez que le système soit complètement démarré
2. Vérifiez que le port 2222 n'est pas déjà utilisé :
   ```bash
   lsof -i :2222
   ```

## Ressources

- [Documentation officielle dockurr/ubuntu](https://github.com/dockur/ubuntu)
- [Docker Hub - dockurr/ubuntu](https://hub.docker.com/r/dockurr/ubuntu)
- [Documentation Ubuntu](https://ubuntu.com/desktop)
