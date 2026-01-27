# Virtualisation avec Docker

Ce dossier contient des exemples de virtualisation de différents systèmes d'exploitation avec Docker, utilisant les images de [Dockur](https://github.com/dockur).

## 📋 Systèmes d'exploitation disponibles

| OS | Version | Port Web | Port VNC/RDP | Dossier |
|----|---------|----------|--------------|---------|
| 🪟 Windows 11 | 11 | 8006 | 3389 (RDP) | [windows-11](./windows-11/) |
| 🍎 macOS | Ventura | 8007 | 5900 (VNC) | [macos](./macos/) |
| 🐧 Ubuntu | 24.04 LTS | 8008 | 5901 (VNC) | [ubuntu](./ubuntu/) |
| 🎩 Fedora | 40 | 8009 | 5902 (VNC) | [fedora](./fedora/) |

## 🚀 Démarrage rapide

Chaque projet peut être lancé indépendamment :

```bash
# Windows 11
cd windows-11
docker compose up -d

# macOS
cd macos
docker compose up -d

# Ubuntu
cd ubuntu
docker compose up -d

# Fedora
cd fedora
docker compose up -d
```

## 🌐 Accès aux systèmes

Tous les systèmes sont accessibles via :

1. **Interface Web (noVNC)** - Accessible depuis votre navigateur
2. **VNC/RDP** - Connexion avec un client natif
3. **SSH** (Ubuntu et Fedora uniquement)

### Ports d'accès

| Système | Interface Web | VNC/RDP | SSH |
|---------|---------------|---------|-----|
| Windows 11 | http://localhost:8006 | localhost:3389 (RDP) | - |
| macOS | http://localhost:8007 | localhost:5900 (VNC) | - |
| Ubuntu | http://localhost:8008 | localhost:5901 (VNC) | localhost:2222 |
| Fedora | http://localhost:8009 | localhost:5902 (VNC) | localhost:2223 |

## ⚙️ Configuration

Chaque système peut être configuré via des variables d'environnement :

### Variables communes

| Variable | Description | Valeur par défaut |
|----------|-------------|-------------------|
| `VERSION` | Version du système | Varie selon l'OS |
| `RAM_SIZE` | Quantité de RAM | `4G` |
| `CPU_CORES` | Nombre de cœurs CPU | `2` |
| `DISK_SIZE` | Taille du disque | `32G` ou `64G` |

### Variables spécifiques à Windows

| Variable | Description | Valeur par défaut |
|----------|-------------|-------------------|
| `REGION` | Région/Langue | `fr-FR` |
| `KEYBOARD` | Disposition du clavier | `fr-FR` |

## 📦 Prérequis

### Tous les systèmes

- Docker et Docker Compose installés
- Support KVM activé (Linux/macOS)
- Au moins 4 Go de RAM disponible
- Au moins 32-64 Go d'espace disque

### Vérifier le support KVM (Linux)

```bash
# Vérifier si KVM est disponible
ls -l /dev/kvm

# Vérifier si votre CPU supporte la virtualisation
egrep -c '(vmx|svm)' /proc/cpuinfo
# Si le résultat est > 0, la virtualisation est supportée
```

### macOS

Docker Desktop pour Mac utilise HVF (Hypervisor Framework). Assurez-vous que Docker Desktop est configuré pour utiliser la virtualisation.

## 🎯 Cas d'usage

### Développement multi-plateforme

Testez vos applications sur différents systèmes d'exploitation sans avoir besoin de machines physiques ou de dual-boot.

```bash
# Tester sur Windows
cd windows-11 && docker compose up -d

# Tester sur Ubuntu
cd ubuntu && docker compose up -d
```

### Environnement de test isolé

Créez des environnements de test jetables pour vos expérimentations.

```bash
# Lancer un environnement de test
docker compose up -d

# Faire vos tests...

# Supprimer complètement l'environnement
docker compose down -v
```

### Formation et démonstration

Utilisez ces environnements pour des formations ou des démonstrations sans impacter votre système principal.

## 🔧 Gestion

### Commandes communes

```bash
# Démarrer un système
docker compose up -d

# Voir les logs
docker compose logs -f

# Arrêter un système
docker compose stop

# Redémarrer un système
docker compose restart

# Supprimer le conteneur (conserver les données)
docker compose down

# Supprimer complètement (y compris les données)
docker compose down -v
```

### Voir tous les conteneurs en cours d'exécution

```bash
docker ps
```

### Arrêter tous les systèmes

```bash
# Depuis le dossier virtualization
for dir in windows-11 macos ubuntu fedora; do
  (cd $dir && docker compose down)
done
```

## 💾 Persistance des données

Tous les systèmes utilisent des volumes Docker pour persister les données. Vos fichiers et configurations seront conservés même si vous supprimez le conteneur (avec `docker compose down`).

Pour supprimer complètement les données, utilisez :

```bash
docker compose down -v
```

## 🔒 Sécurité

### Identifiants par défaut

| Système | Utilisateur | Mot de passe |
|---------|-------------|--------------|
| Ubuntu | `ubuntu` | `ubuntu` |
| Fedora | `fedora` | `fedora` |
| Windows | - | Configuré lors de l'installation |
| macOS | - | Configuré lors de l'installation |

⚠️ **Important** : Changez les mots de passe par défaut après la première connexion !

### Bonnes pratiques

1. Changez les mots de passe par défaut
2. N'exposez pas ces conteneurs directement sur Internet
3. Utilisez un VPN ou un tunnel SSH pour l'accès à distance
4. Mettez à jour régulièrement les systèmes

## 📊 Ressources système recommandées

| Système | RAM minimale | RAM recommandée | Disque |
|---------|--------------|-----------------|--------|
| Windows 11 | 4 Go | 8 Go | 64 Go |
| macOS | 4 Go | 8 Go | 64 Go |
| Ubuntu | 2 Go | 4 Go | 32 Go |
| Fedora | 2 Go | 4 Go | 32 Go |

## 🐛 Dépannage

### Le conteneur ne démarre pas

1. Vérifiez que KVM est disponible :
   ```bash
   ls -l /dev/kvm
   ```

2. Vérifiez les logs :
   ```bash
   docker compose logs
   ```

3. Vérifiez que les ports ne sont pas déjà utilisés :
   ```bash
   lsof -i :8006  # Remplacez par le port concerné
   ```

### Performance lente

1. Augmentez la RAM et les CPU dans le fichier `compose.yml`
2. Assurez-vous que votre système a suffisamment de ressources disponibles
3. Fermez les applications inutiles sur votre système hôte

### Impossible de se connecter

1. Attendez que le système soit complètement démarré (vérifiez les logs)
2. Vérifiez que les ports sont correctement mappés
3. Essayez l'interface web si VNC/RDP ne fonctionne pas

## 📚 Ressources

- [Dockur - Windows](https://github.com/dockur/windows)
- [Dockur - macOS](https://github.com/dockur/macos)
- [Dockur - Ubuntu](https://github.com/dockur/ubuntu)
- [Dockur - Fedora](https://github.com/dockur/fedora)
- [Documentation Docker](https://docs.docker.com/)
- [Documentation Docker Compose](https://docs.docker.com/compose/)

## 📝 Licence

Ces projets utilisent des images Docker de Dockur. Veuillez consulter leurs licences respectives.

**Notes importantes** :
- Vous devez posséder une licence Windows valide pour utiliser Windows
- L'utilisation de macOS est soumise aux conditions de licence d'Apple
- Ubuntu et Fedora sont des systèmes open source et gratuits

## 🤝 Contribution

N'hésitez pas à améliorer ces configurations ou à ajouter d'autres systèmes d'exploitation !

## 📧 Support

Pour des questions spécifiques à chaque système, consultez le README dans le dossier correspondant.
