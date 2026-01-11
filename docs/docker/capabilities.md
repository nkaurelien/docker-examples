# Docker Capabilities & Security

Guide des capabilities Linux et options de sécurité Docker pour les conteneurs nécessitant des privilèges élevés.

## Privileged vs Capabilities

### Mode Privileged

```yaml
services:
  app:
    privileged: true
```

Le mode `privileged: true` donne au conteneur tous les privilèges root de l'hôte. C'est l'option la moins sécurisée mais parfois nécessaire.

### Mode Capabilities (Recommandé)

```yaml
services:
  app:
    cap_add:
      - SYS_ADMIN
      - NET_ADMIN
    cap_drop:
      - ALL
```

Les capabilities permettent de donner uniquement les privilèges nécessaires.

## Capabilities Courantes

| Capability | Description | Cas d'usage |
|------------|-------------|-------------|
| `SYS_ADMIN` | Administration système (mount, namespaces) | NeuVector, security tools |
| `NET_ADMIN` | Configuration réseau (iptables, interfaces) | Traefik, firewalls, VPN |
| `SYS_PTRACE` | Traçage de processus | Debugging, security monitoring |
| `IPC_LOCK` | Verrouillage mémoire (mlock) | Databases, security tools |
| `NET_RAW` | Sockets raw (ping, ICMP) | Network diagnostics |
| `SYS_TIME` | Modification horloge système | NTP servers |
| `SYS_NICE` | Priorité des processus | Scheduling, real-time apps |
| `CHOWN` | Changer propriétaire fichiers | File management |
| `DAC_OVERRIDE` | Ignorer permissions fichiers | Backup tools |
| `SETUID/SETGID` | Changer UID/GID | Init systems |
| `AUDIT_WRITE` | Écrire logs audit | Logging, compliance |

## Security Options

### AppArmor

```yaml
services:
  app:
    security_opt:
      - apparmor:unconfined    # Désactive AppArmor
      # - apparmor:docker-default  # Profil par défaut
```

### SELinux

```yaml
services:
  app:
    security_opt:
      - label:disable          # Désactive SELinux labeling
      # - label:type:container_t  # Label spécifique
```

### Seccomp

```yaml
services:
  app:
    security_opt:
      - seccomp:unconfined     # Désactive seccomp
      # - seccomp:profile.json  # Profil personnalisé
```

## Exemples Complets

### Application Security (NeuVector style)

```yaml
services:
  security-tool:
    image: security/tool:latest
    pid: host
    cap_add:
      - SYS_ADMIN
      - NET_ADMIN
      - SYS_PTRACE
      - IPC_LOCK
    security_opt:
      - label:disable
      - apparmor:unconfined
      - seccomp:unconfined
    volumes:
      - /proc:/host/proc:ro
      - /sys/fs/cgroup:/host/cgroup:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
```

### Network Tool (Traefik style)

```yaml
services:
  proxy:
    image: traefik:latest
    cap_add:
      - NET_BIND_SERVICE    # Bind ports < 1024
    cap_drop:
      - ALL
    ports:
      - "80:80"
      - "443:443"
```

### Database avec mémoire verrouillée

```yaml
services:
  database:
    image: postgres:latest
    cap_add:
      - IPC_LOCK
    cap_drop:
      - ALL
```

## Options PID et Network

### PID Namespace

```yaml
services:
  app:
    pid: host              # Partage le namespace PID avec l'hôte
```

Permet de voir tous les processus de l'hôte. Nécessaire pour les outils de monitoring.

### Network Mode

```yaml
services:
  app:
    network_mode: host     # Utilise le réseau de l'hôte directement
```

## Volumes Système Courants

| Volume | Description | Accès |
|--------|-------------|-------|
| `/var/run/docker.sock` | Socket Docker API | `:ro` recommandé |
| `/proc` | Infos processus | `:ro` |
| `/sys/fs/cgroup` | Control groups | `:ro` |
| `/lib/modules` | Modules kernel | `:ro` |
| `/etc/localtime` | Timezone hôte | `:ro` |

## Bonnes Pratiques

1. **Principe du moindre privilège** : Utilisez `cap_drop: ALL` puis ajoutez seulement les capabilities nécessaires

2. **Évitez privileged** : Préférez les capabilities spécifiques quand possible

3. **Volumes read-only** : Montez les volumes système en `:ro`

4. **User non-root** : Utilisez `user: 1000:1000` quand possible

5. **Seccomp profiles** : Créez des profils seccomp personnalisés pour les apps sensibles

## Commandes Utiles

```bash
# Lister les capabilities d'un conteneur
docker inspect --format='{{.HostConfig.CapAdd}}' container_name

# Voir les capabilities effectives
docker exec container_name cat /proc/1/status | grep Cap

# Décoder les capabilities
capsh --decode=00000000a80425fb
```

## Références

- [Docker Security Documentation](https://docs.docker.com/engine/security/)
- [Linux Capabilities Manual](https://man7.org/linux/man-pages/man7/capabilities.7.html)
- [Docker Compose Security Options](https://docs.docker.com/compose/compose-file/05-services/#cap_add)
