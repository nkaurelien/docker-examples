# Fedora Workstation avec Docker

Ce projet permet d'exécuter Fedora Workstation dans un conteneur Docker en utilisant l'image [dockurr/fedora](https://github.com/dockur/fedora).

## Prérequis

- Docker et Docker Compose installés
- Support KVM activé sur votre système (Linux/macOS avec virtualisation)
- Au moins 4 Go de RAM disponible
- Au moins 32 Go d'espace disque

## Démarrage

### Lancer Fedora Workstation

```bash
docker compose up -d
```

### Suivre les logs

```bash
docker compose logs -f fedora
```

Le premier démarrage peut prendre 5-10 minutes.

## Accès à Fedora

### Option 1 : Interface Web (noVNC)

Ouvrez votre navigateur et accédez à :
```
http://localhost:8009
```

### Option 2 : VNC

Utilisez un client VNC :
```
localhost:5902
```

### Option 3 : SSH

```bash
ssh user@localhost -p 2223
```

**Identifiants par défaut** :
- Utilisateur : `fedora`
- Mot de passe : `fedora`

⚠️ **Changez le mot de passe après la première connexion !**

## Configuration

### Variables d'environnement

| Variable | Description | Valeur par défaut |
|----------|-------------|-------------------|
| `VERSION` | Version de Fedora | `40` |
| `RAM_SIZE` | Quantité de RAM allouée | `4G` |
| `CPU_CORES` | Nombre de cœurs CPU | `2` |
| `DISK_SIZE` | Taille du disque virtuel | `32G` |

### Versions de Fedora disponibles

- `40` - Fedora 40 (dernière version stable)
- `39` - Fedora 39
- `38` - Fedora 38

## Partage de fichiers

Un dossier `shared` est monté dans le conteneur à `/shared`. Vous pouvez l'utiliser pour échanger des fichiers entre votre hôte et Fedora.

```bash
# Créer le dossier partagé
mkdir -p shared

# Copier un fichier dans le dossier partagé
cp mon-fichier.txt shared/
```

Le fichier sera accessible dans Fedora à `/shared/mon-fichier.txt`.

## Gestion

### Arrêter Fedora

```bash
docker compose stop
```

### Redémarrer Fedora

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

Une fois connecté à Fedora, vous pouvez installer des logiciels avec dnf :

```bash
# Mettre à jour les paquets
sudo dnf update -y

# Installer des logiciels
sudo dnf install -y vim git curl wget

# Installer des outils de développement
sudo dnf groupinstall -y "Development Tools"
sudo dnf install -y python3 nodejs npm

# Installer des logiciels avec Flatpak (préinstallé sur Fedora)
flatpak install flathub org.mozilla.firefox
```

## Environnement de bureau

Fedora Workstation utilise GNOME comme environnement de bureau par défaut. Vous pouvez personnaliser l'interface via les paramètres système.

### Extensions GNOME utiles

```bash
# Installer GNOME Tweaks
sudo dnf install -y gnome-tweaks

# Installer des extensions
sudo dnf install -y gnome-shell-extension-appindicator
```

## Dépannage

### Le conteneur ne démarre pas

Vérifiez les logs :
```bash
docker compose logs fedora
```

### Performance lente

1. Augmentez la RAM et les CPU dans `compose.yml`
2. Assurez-vous que KVM est bien activé :
   ```bash
   ls -l /dev/kvm
   ```

### Impossible de se connecter via SSH

1. Attendez que le système soit complètement démarré
2. Vérifiez que le port 2223 n'est pas déjà utilisé :
   ```bash
   lsof -i :2223
   ```

## Ressources

- [Documentation officielle dockurr/fedora](https://github.com/dockur/fedora)
- [Docker Hub - dockurr/fedora](https://hub.docker.com/r/dockurr/fedora)
- [Documentation Fedora](https://docs.fedoraproject.org/)
- [Fedora Magazine](https://fedoramagazine.org/)
