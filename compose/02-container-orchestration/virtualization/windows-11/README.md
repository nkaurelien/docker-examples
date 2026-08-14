# Windows 11 avec Docker

Ce projet permet d'exécuter Windows 11 dans un conteneur Docker en utilisant l'image [dockurr/windows](https://github.com/dockur/windows).

## Prérequis

- Docker et Docker Compose installés
- Support KVM activé sur votre système (Linux/macOS avec virtualisation)
- Au moins 4 Go de RAM disponible
- Au moins 64 Go d'espace disque

### Vérifier le support KVM

Sur Linux :
```bash
# Vérifier si KVM est disponible
ls -l /dev/kvm

# Vérifier si votre CPU supporte la virtualisation
egrep -c '(vmx|svm)' /proc/cpuinfo
# Si le résultat est > 0, la virtualisation est supportée
```

Sur macOS :
```bash
# Docker Desktop pour Mac utilise HVF (Hypervisor Framework)
# Assurez-vous que Docker Desktop est configuré pour utiliser la virtualisation
```

## Démarrage

### Lancer Windows 11

```bash
docker compose up -d
```

### Suivre les logs

```bash
docker compose logs -f windows
```

Le premier démarrage peut prendre 10-15 minutes car Windows doit être téléchargé et installé.

## Accès à Windows

### Option 1 : Interface Web (noVNC)

Ouvrez votre navigateur et accédez à :
```
http://localhost:8006
```

### Option 2 : Bureau à distance (RDP)

Utilisez un client RDP comme :
- **Windows** : Connexion Bureau à distance (mstsc.exe)
- **macOS** : Microsoft Remote Desktop
- **Linux** : Remmina, rdesktop, ou xfreerdp

Connectez-vous à :
```
localhost:3389
```

## Configuration

### Variables d'environnement

Vous pouvez personnaliser les paramètres dans le fichier `compose.yml` :

| Variable | Description | Valeur par défaut |
|----------|-------------|-------------------|
| `VERSION` | Version de Windows (11, 10, 8, 7, vista, xp) | `11` |
| `LANGUAGE` | Langue de l'installation Windows | `French` |
| `REGION` | Région/Langue du système | `fr-FR` |
| `KEYBOARD` | Disposition du clavier | `fr-FR` |
| `RAM_SIZE` | Quantité de RAM allouée | `4G` |
| `CPU_CORES` | Nombre de cœurs CPU | `2` |
| `DISK_SIZE` | Taille du disque virtuel | `64G` |
| `USERNAME` | Nom d'utilisateur du compte Windows | `Docker` |
| `PASSWORD` | Mot de passe du compte Windows | `admin` |

### Exemple de configuration personnalisée

```yaml
environment:
  VERSION: "11"
  LANGUAGE: "French"
  REGION: "fr-FR"
  KEYBOARD: "fr-FR"
  RAM_SIZE: "8G"
  CPU_CORES: "4"
  DISK_SIZE: "128G"
  USERNAME: "MonUtilisateur"
  PASSWORD: "MonMotDePasse123"
```

### Langues disponibles

#### Variable LANGUAGE (langue d'installation)

La variable `LANGUAGE` détermine la langue de l'installation de Windows. Valeurs disponibles :

| Langue | Valeur LANGUAGE |
|--------|----------------|
| Français | `French` |
| Anglais | `English` |
| Allemand | `German` |
| Espagnol | `Spanish` |
| Italien | `Italian` |
| Portugais | `Portuguese` |
| Néerlandais | `Dutch` |
| Russe | `Russian` |
| Polonais | `Polish` |
| Ukrainien | `Ukrainian` |
| Chinois | `Chinese` |
| Japonais | `Japanese` |
| Coréen | `Korean` |
| Arabe | `Arabic` |
| Bulgare | `Bulgarian` |
| Croate | `Croatian` |
| Tchèque | `Czech` |
| Danois | `Danish` |
| Estonien | `Estonian` |
| Finnois | `Finnish` |
| Grec | `Greek` |
| Hébreu | `Hebrew` |
| Hongrois | `Hungarian` |
| Letton | `Latvian` |
| Lituanien | `Lithuanian` |
| Norvégien | `Norwegian` |
| Roumain | `Romanian` |
| Serbe | `Serbian` |
| Slovaque | `Slovak` |
| Slovène | `Slovenian` |
| Suédois | `Swedish` |
| Thaï | `Thai` |
| Turc | `Turkish` |

#### Variables REGION et KEYBOARD (configuration système)

Voici quelques exemples de configurations courantes :

| Langue | LANGUAGE | REGION | KEYBOARD |
|--------|----------|--------|----------|
| Français | `French` | `fr-FR` | `fr-FR` |
| Anglais (US) | `English` | `en-US` | `en-US` |
| Anglais (UK) | `English` | `en-GB` | `en-GB` |
| Allemand | `German` | `de-DE` | `de-DE` |
| Espagnol | `Spanish` | `es-ES` | `es-ES` |
| Italien | `Italian` | `it-IT` | `it-IT` |
| Portugais (BR) | `Portuguese` | `pt-BR` | `pt-BR` |
| Japonais | `Japanese` | `ja-JP` | `ja-JP` |
| Chinois | `Chinese` | `zh-CN` | `zh-CN` |
| Russe | `Russian` | `ru-RU` | `ru-RU` |

**Note** : Vous pouvez mélanger les configurations. Par exemple :
- `LANGUAGE="English"` + `REGION="fr-FR"` + `KEYBOARD="fr-FR"` : Windows en anglais avec paramètres régionaux français
- `LANGUAGE="French"` + `KEYBOARD="en-US"` : Windows en français avec clavier américain

## Gestion

### Arrêter Windows

```bash
docker compose stop
```

### Redémarrer Windows

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

## Persistance des données

Les données Windows sont stockées dans un volume Docker nommé `windows_data`. Cela signifie que vos fichiers et configurations seront conservés même si vous supprimez le conteneur.

### Sauvegarder les données

```bash
# Créer une sauvegarde du volume
docker run --rm -v windows_data:/data -v $(pwd):/backup alpine tar czf /backup/windows-backup.tar.gz -C /data .
```

### Restaurer les données

```bash
# Restaurer depuis une sauvegarde
docker run --rm -v windows_data:/data -v $(pwd):/backup alpine tar xzf /backup/windows-backup.tar.gz -C /data
```

## Dépannage

### Le conteneur ne démarre pas

1. Vérifiez que KVM est disponible :
   ```bash
   ls -l /dev/kvm
   ```

2. Vérifiez les logs :
   ```bash
   docker compose logs windows
   ```

### Performance lente

1. Augmentez la RAM et les CPU dans `compose.yml`
2. Assurez-vous que votre système a suffisamment de ressources disponibles

### Impossible de se connecter via RDP

1. Attendez que Windows soit complètement démarré (vérifiez via noVNC)
2. Vérifiez que le port 3389 n'est pas déjà utilisé :
   ```bash
   lsof -i :3389
   ```

## Versions de Windows disponibles

Vous pouvez changer la version de Windows en modifiant la variable `VERSION` :

- `11` - Windows 11
- `10` - Windows 10
- `8` - Windows 8.1
- `7` - Windows 7
- `vista` - Windows Vista
- `xp` - Windows XP

## Ressources

- [Documentation officielle dockurr/windows](https://github.com/dockur/windows)
- [Docker Hub - dockurr/windows](https://hub.docker.com/r/dockurr/windows)
- [README complet sur GitHub](https://raw.githubusercontent.com/dockur/windows/refs/heads/master/readme.md)

## Licence

Ce projet utilise l'image Docker dockurr/windows. Veuillez consulter leur licence pour plus d'informations.

**Note** : Vous devez posséder une licence Windows valide pour utiliser Windows dans un conteneur.
