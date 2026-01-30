# IT-Tools

IT-Tools est un projet open source créé par **Corentin Thomasset** (Lyon, France), qui contient de nombreux outils pratiques pour les développeurs et administrateurs système, organisés en plusieurs catégories.

## 🌐 Liens

- **GitHub**: [https://github.com/CorentinTh/it-tools](https://github.com/CorentinTh/it-tools)
- **Version en ligne**: [https://it-tools.tech](https://it-tools.tech)
- **Image Docker**: `ghcr.io/corentinth/it-tools:latest`

## 🛠️ Fonctionnalités principales

### Outils réseau
- Calculer un sous-réseau IP
- Convertir une adresse IP (en binaire, par exemple)
- Obtenir des informations sur une adresse MAC
- Générer une nouvelle adresse MAC
- Générer des adresses IP locales en IPv6, non routables, pour votre réseau (conforme RFC4193)

### Autres catégories d'outils
- Encodage/Décodage (Base64, URL, JWT, etc.)
- Générateurs (UUID, Hash, Mots de passe, etc.)
- Convertisseurs (JSON, YAML, XML, etc.)
- Outils de texte (Diff, Regex tester, etc.)
- Outils de développement (QR Code, Color picker, etc.)

## 🚀 Démarrage rapide

### Lancer le service

```bash
docker-compose up -d
```

### Accéder à l'interface

Ouvrez votre navigateur à l'adresse : **[http://localhost:7474](http://localhost:7474)**

### Vérifier le statut

```bash
docker-compose ps
```

### Voir les logs

```bash
docker-compose logs -f it-tools
```

### Arrêter le service

```bash
docker-compose down
```

## 📋 Configuration

### Ports
- **7474** : Interface web IT-Tools (mappé sur le port 80 du conteneur)

### Politique de redémarrage
- `unless-stopped` : Le conteneur redémarre automatiquement sauf s'il est arrêté manuellement

## 🔧 Personnalisation

### Changer le port

Pour utiliser un port différent, modifiez la ligne `ports` dans `docker-compose.yml` :

```yaml
ports:
  - '8080:80'  # Utilise le port 8080 au lieu de 7474
```

### Utiliser avec un reverse proxy

Si vous utilisez un reverse proxy (Nginx, Traefik, etc.), vous pouvez exposer IT-Tools via un nom de domaine :

```yaml
services:
  it-tools:
    image: 'ghcr.io/corentinth/it-tools:latest'
    restart: unless-stopped
    container_name: it-tools
    networks:
      - proxy
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.it-tools.rule=Host(`tools.example.com`)"
      - "traefik.http.services.it-tools.loadbalancer.server.port=80"

networks:
  proxy:
    external: true
```

## 📊 Ressources système

IT-Tools est une application web légère qui nécessite peu de ressources :
- **RAM** : ~50-100 MB
- **CPU** : Minimal
- **Stockage** : ~100 MB (image Docker)

## 🔐 Sécurité

⚠️ **Important** : IT-Tools n'inclut pas d'authentification par défaut. Si vous l'exposez sur Internet, assurez-vous de :
- Utiliser un reverse proxy avec authentification (Basic Auth, OAuth, etc.)
- Limiter l'accès par IP si possible
- Utiliser HTTPS pour chiffrer les communications

## 🆘 Dépannage

### Le conteneur ne démarre pas

```bash
# Vérifier les logs
docker-compose logs it-tools

# Vérifier que le port 7474 n'est pas déjà utilisé
lsof -i :7474
```

### Mettre à jour vers la dernière version

```bash
docker-compose pull
docker-compose up -d
```

## 📚 Ressources supplémentaires

- [Documentation officielle](https://github.com/CorentinTh/it-tools#readme)
- [Contribuer au projet](https://github.com/CorentinTh/it-tools/blob/main/CONTRIBUTING.md)
- [Signaler un bug](https://github.com/CorentinTh/it-tools/issues)

## 📄 Licence

IT-Tools est distribué sous licence GNU GPL v3.0. Voir le [dépôt GitHub](https://github.com/CorentinTh/it-tools) pour plus de détails.
