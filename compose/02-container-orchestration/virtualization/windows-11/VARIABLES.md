# Variables d'environnement disponibles

Ce document liste toutes les variables d'environnement disponibles pour configurer le conteneur Windows Docker.

Source : [Documentation officielle dockurr/windows](https://github.com/dockur/windows)

## Variables principales

### VERSION
Spécifie la version de Windows à installer.

**Valeur par défaut** : `"11"`

**Valeurs possibles** :

| Valeur | Version | Taille |
|--------|---------|--------|
| `11` | Windows 11 Pro | 7.2 GB |
| `11l` | Windows 11 LTSC | 4.7 GB |
| `11e` | Windows 11 Enterprise | 6.6 GB |
| `10` | Windows 10 Pro | 5.7 GB |
| `10l` | Windows 10 LTSC | 4.6 GB |
| `10e` | Windows 10 Enterprise | 5.2 GB |
| `8e` | Windows 8.1 Enterprise | 3.7 GB |
| `7u` | Windows 7 Ultimate | 3.1 GB |
| `vu` | Windows Vista Ultimate | 3.0 GB |
| `xp` | Windows XP Professional | 0.6 GB |
| `2k` | Windows 2000 Professional | 0.4 GB |
| `2025` | Windows Server 2025 | 6.7 GB |
| `2022` | Windows Server 2022 | 6.0 GB |
| `2019` | Windows Server 2019 | 5.3 GB |
| `2016` | Windows Server 2016 | 6.5 GB |
| `2012` | Windows Server 2012 | 4.3 GB |
| `2008` | Windows Server 2008 | 3.0 GB |
| `2003` | Windows Server 2003 | 0.6 GB |

Vous pouvez également fournir un lien direct vers un fichier `.iso` personnalisé.

### LANGUAGE
Définit la langue de l'installation de Windows.

**Valeur par défaut** : `"English"`

**Valeurs possibles** :
- `Arabic` 🇦🇪
- `Bulgarian` 🇧🇬
- `Chinese` 🇨🇳
- `Croatian` 🇭🇷
- `Czech` 🇨🇿
- `Danish` 🇩🇰
- `Dutch` 🇳🇱
- `English` 🇬🇧
- `Estonian` 🇪🇪
- `Finnish` 🇫🇮
- `French` 🇫🇷
- `German` 🇩🇪
- `Greek` 🇬🇷
- `Hebrew` 🇮🇱
- `Hungarian` 🇭🇺
- `Italian` 🇮🇹
- `Japanese` 🇯🇵
- `Korean` 🇰🇷
- `Latvian` 🇱🇻
- `Lithuanian` 🇱🇹
- `Norwegian` 🇳🇴
- `Polish` 🇵🇱
- `Portuguese` 🇵🇹
- `Romanian` 🇷🇴
- `Russian` 🇷🇺
- `Serbian` 🇷🇸
- `Slovak` 🇸🇰
- `Slovenian` 🇸🇮
- `Spanish` 🇪🇸
- `Swedish` 🇸🇪
- `Thai` 🇹🇭
- `Turkish` 🇹🇷
- `Ukrainian` 🇺🇦

### REGION
Définit les paramètres régionaux et le format de date/heure.

**Valeur par défaut** : `"en-US"`

**Exemples** : `"fr-FR"`, `"de-DE"`, `"es-ES"`, `"ja-JP"`, etc.

### KEYBOARD
Définit la disposition du clavier par défaut.

**Valeur par défaut** : `"en-US"`

**Exemples** : `"fr-FR"`, `"de-DE"`, `"es-ES"`, `"ja-JP"`, etc.

## Ressources système

### DISK_SIZE
Définit la taille du disque dur virtuel.

**Valeur par défaut** : `"64G"`

**Exemples** : `"128G"`, `"256G"`, `"512G"`, `"1T"`

**Note** : Peut être utilisé pour redimensionner un disque existant sans perte de données. Vous devrez ensuite [étendre manuellement la partition](https://learn.microsoft.com/en-us/windows-server/storage/disk-management/extend-a-basic-volume?tabs=disk-management).

### RAM_SIZE
Quantité de RAM allouée à la machine virtuelle.

**Valeur par défaut** : `"4G"`

**Exemples** : `"2G"`, `"8G"`, `"16G"`, `"32G"`

### CPU_CORES
Nombre de cœurs CPU alloués à la machine virtuelle.

**Valeur par défaut** : `"2"`

**Exemples** : `"1"`, `"4"`, `"8"`, `"16"`

## Compte utilisateur

### USERNAME
Nom d'utilisateur du compte créé lors de l'installation.

**Valeur par défaut** : `"Docker"`

**Exemple** : `"MonUtilisateur"`

### PASSWORD
Mot de passe du compte créé lors de l'installation.

**Valeur par défaut** : `"admin"`

**Exemple** : `"MonMotDePasse123"`

⚠️ **Important** : Changez le mot de passe par défaut pour des raisons de sécurité !

## Options avancées

### MANUAL
Définir sur `"Y"` pour ignorer l'installation automatique et la faire manuellement.

**Valeur par défaut** : `"N"`

**Valeurs possibles** : `"Y"`, `"N"`

### DHCP
Activer pour obtenir une adresse IP du serveur DHCP de votre routeur.

**Valeur par défaut** : `"N"`

**Valeurs possibles** : `"Y"`, `"N"`

### DISK2_SIZE
Taille d'un second disque virtuel.

**Exemples** : `"32G"`, `"64G"`, `"128G"`

**Note** : Supporte également `DISK3_SIZE`, `DISK4_SIZE`, etc.

### ARGUMENTS
Passer des arguments personnalisés en ligne de commande à QEMU.

**Exemple** : `"-device usb-host,vendorid=0x1234"`

## Exemple de configuration complète

```yaml
services:
  windows:
    image: dockurr/windows
    container_name: windows-11
    environment:
      # Version de Windows
      VERSION: "11"
      
      # Langue et région
      LANGUAGE: "French"
      REGION: "fr-FR"
      KEYBOARD: "fr-FR"
      
      # Ressources
      RAM_SIZE: "8G"
      CPU_CORES: "4"
      DISK_SIZE: "128G"
      
      # Compte utilisateur
      USERNAME: "MonUtilisateur"
      PASSWORD: "MotDePasseSecurise123!"
      
      # Options avancées
      DHCP: "Y"
      
    devices:
      - /dev/kvm
      - /dev/net/tun
    cap_add:
      - NET_ADMIN
    ports:
      - 8006:8006
      - 3389:3389/tcp
      - 3389:3389/udp
    volumes:
      - windows_data:/storage
      - ./shared:/shared
    restart: unless-stopped
    stop_grace_period: 2m

volumes:
  windows_data:
    driver: local
```

## Ressources

- [Documentation officielle](https://github.com/dockur/windows)
- [README complet](https://raw.githubusercontent.com/dockur/windows/refs/heads/master/readme.md)
- [Docker Hub](https://hub.docker.com/r/dockurr/windows)
