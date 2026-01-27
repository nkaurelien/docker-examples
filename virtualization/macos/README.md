# macOS avec Docker

Ce projet permet d'exécuter macOS dans un conteneur Docker en utilisant l'image [dockurr/macos](https://github.com/dockur/macos).

## Prérequis

- Docker et Docker Compose installés
- Support KVM activé sur votre système (Linux)
- Au moins 4 Go de RAM disponible
- Au moins 64 Go d'espace disque

## Démarrage

### Lancer macOS

```bash
docker compose up -d
```

### Suivre les logs

```bash
docker compose logs -f macos
```

Le premier démarrage peut prendre 15-20 minutes car macOS doit être téléchargé et installé.

## Accès à macOS

### Option 1 : Interface Web (noVNC)

Ouvrez votre navigateur et accédez à :
```
http://localhost:8007
```

### Option 2 : VNC

Utilisez un client VNC comme :
- **macOS** : Screen Sharing (intégré)
- **Linux** : Remmina, TigerVNC
- **Windows** : TightVNC, RealVNC

Connectez-vous à :
```
localhost:5900
```

## Configuration

### Variables d'environnement

| Variable | Description | Valeur par défaut |
|----------|-------------|-------------------|
| `VERSION` | Version de macOS | `ventura` |
| `RAM_SIZE` | Quantité de RAM allouée | `4G` |
| `CPU_CORES` | Nombre de cœurs CPU | `2` |
| `DISK_SIZE` | Taille du disque virtuel | `64G` |

### Versions de macOS disponibles

- `ventura` - macOS 13 Ventura
- `monterey` - macOS 12 Monterey
- `big-sur` - macOS 11 Big Sur
- `catalina` - macOS 10.15 Catalina
- `mojave` - macOS 10.14 Mojave
- `high-sierra` - macOS 10.13 High Sierra

## Gestion

### Arrêter macOS

```bash
docker compose stop
```

### Redémarrer macOS

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

## Ressources

- [Documentation officielle dockurr/macos](https://github.com/dockur/macos)
- [Docker Hub - dockurr/macos](https://hub.docker.com/r/dockurr/macos)

## Licence

**Note** : L'utilisation de macOS est soumise aux conditions de licence d'Apple. Assurez-vous de respecter les termes de la licence Apple.
