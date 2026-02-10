# SSL Certificate Generators

Outils Docker pour générer des certificats SSL de développement. Trois approches complémentaires :

- **mkcert** : Certificats de développement approuvés localement (pas d'avertissement navigateur) — **recommandé**
- **omgwtfssl** : Génération rapide de certificats auto-signés (CA + certificat serveur)
- **openssl** : Génération directe avec la commande système openssl (toujours disponible)

## Comparaison

| Critère | mkcert | omgwtfssl | openssl |
|---------|--------|-----------|---------|
| **Type** | Certificats localement approuvés | Certificats auto-signés (CA séparée) | Certificat auto-signé |
| **Avertissement navigateur** | Non (après install CA) | Oui (sauf si CA installée) | Oui (sauf si cert installé) |
| **CA séparée** | Oui (`rootCA.pem`) | Oui (`ca.pem`) | Non (le cert = CA) |
| **Auto-trust** | `mkcert -install` | Manuel | Manuel |
| **Cas d'usage** | Développement local | CI/CD, tests, services internes | Environnements minimaux |
| **Taille image** | ~300MB (Go + build) | ~8MB (Alpine) | ~8MB (Alpine) |
| **GitHub stars** | ~51k | ~1k | N/A (built-in) |
| **Configuration** | Ligne de commande | Variables d'environnement | Variables d'environnement |

## Comment fonctionne la chaîne SSL/TLS

```
CA (Autorité de Certification)      ← Le "notaire"
 │
 └── signe ──→ Certificat serveur   ← L'identité du serveur
                 │
                 └── utilise ──→ Clé privée   ← Le secret du serveur
```

### Flux de génération

```
1.  CA_KEY + CA_SUBJECT + CA_EXPIRE
    ──→ CA_CERT (certificat racine auto-signé)

2.  SSL_KEY + SSL_SUBJECT + SSL_DNS + SSL_IP
    ──→ SSL_CSR (demande de signature)

3.  SSL_CSR + CA_KEY + CA_CERT + SSL_EXPIRE
    ──→ SSL_CERT (certificat serveur signé par la CA)
```

### Rôle de chaque fichier

| Fichier | Rôle | Qui l'utilise |
|---------|------|---------------|
| **CA Key** (`ca-key.pem`) | Clé privée de la CA. Sert à signer les certificats. | Uniquement le générateur |
| **CA Cert** (`ca.pem` / `rootCA.pem`) | Certificat public de la CA. À installer dans le trust store. | Navigateur / OS / Docker |
| **SSL Key** (`key.pem`) | Clé privée du serveur. Ne quitte jamais le serveur. | Nginx / Apache / service |
| **SSL Cert** (`cert.pem`) | Certificat public du serveur, signé par la CA. | Nginx / Apache / service |
| **SSL CSR** (`key.csr`) | Demande de signature. Fichier intermédiaire temporaire. | Uniquement pendant la génération |

### SAN (Subject Alternative Names)

Les navigateurs modernes vérifient les SAN, pas le CN :
- **SSL_DNS** : Noms DNS alternatifs → `*.example.com,example.com`
- **SSL_IP** : Adresses IP → `127.0.0.1,192.168.1.100`

## Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                  SSL Certificate Generators                     │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐        │
│  │   mkcert      │  │  omgwtfssl   │  │   openssl    │        │
│  │  (recommandé) │  │              │  │              │        │
│  │               │  │  - CA cert   │  │  - Self-     │        │
│  │  - Root CA    │  │  - CA key    │  │    signed    │        │
│  │  - Trusted    │  │  - Server    │  │    cert+key  │        │
│  │    cert+key   │  │    cert+key  │  │              │        │
│  └───────┬───────┘  └───────┬──────┘  └───────┬──────┘        │
│          │                  │                  │               │
│   ./certs/mkcert/    ./certs/omgwtfssl/  ./certs/openssl/     │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

## Démarrage Rapide

### mkcert - Certificats localement approuvés (recommandé)

```bash
# Générer des certificats pour localhost
docker compose --profile mkcert up

# Générer pour des domaines personnalisés
MKCERT_DOMAINS="myapp.local *.myapp.local localhost 127.0.0.1" \
  docker compose --profile mkcert up
```

Les certificats sont générés dans `./certs/mkcert/` :

| Fichier | Description |
|---------|-------------|
| `ca/rootCA.pem` | Certificat racine à installer sur le système |
| `ca/rootCA-key.pem` | Clé privée de la CA (ne pas partager) |
| `localhost+N.pem` | Certificat serveur |
| `localhost+N-key.pem` | Clé privée du serveur |

> **Important** : Le conteneur génère les certificats mais n'installe **pas** la CA sur l'hôte. Voir la section ci-dessous.

### omgwtfssl - Certificats auto-signés

```bash
# Générer des certificats avec les paramètres par défaut (localhost)
docker compose --profile omgwtfssl up

# Générer pour un domaine personnalisé
SSL_SUBJECT=myapp.local SSL_DNS=myapp.local,*.myapp.local \
  docker compose --profile omgwtfssl up
```

Les certificats sont générés dans `./certs/omgwtfssl/` :

| Fichier | Description |
|---------|-------------|
| `ca.pem` | Certificat de l'autorité de certification |
| `ca-key.pem` | Clé privée de la CA |
| `cert.pem` | Certificat serveur |
| `key.pem` | Clé privée du serveur |

### openssl - Certificat auto-signé simple

```bash
# Générer un certificat auto-signé pour localhost
docker compose --profile openssl up

# Générer pour un domaine personnalisé avec IP
SSL_SUBJECT=myapp.local SSL_DNS=myapp.local,*.myapp.local SSL_IP=192.168.1.100 \
  docker compose --profile openssl up
```

Les certificats sont générés dans `./certs/openssl/` :

| Fichier | Description |
|---------|-------------|
| `cert.pem` | Certificat auto-signé (fait office de CA) |
| `key.pem` | Clé privée du serveur |

> **Note** : Avec openssl, le certificat est directement auto-signé (pas de CA séparée). Pour le trust, il faut installer `cert.pem` lui-même.

## Installer la CA sur l'hôte

Le conteneur Docker ne peut pas modifier le trust store de la machine hôte. Un script `install-ca.sh` est fourni pour installer la CA générée sur votre système :

```bash
# 1. Générer les certificats
docker compose --profile mkcert up

# 2. Installer la CA sur l'hôte (macOS/Linux, nécessite sudo)
./install-ca.sh mkcert

# Fonctionne aussi avec omgwtfssl et openssl
./install-ca.sh omgwtfssl
./install-ca.sh openssl
```

Le script détecte automatiquement l'OS :

| OS | Méthode |
|----|---------|
| **macOS** | `security add-trusted-cert` (Keychain système) |
| **Debian/Ubuntu** | `update-ca-certificates` |
| **RHEL/Fedora** | `update-ca-trust` |
| **Windows** | Affiche la commande PowerShell à exécuter |

> **Firefox** : Firefox utilise son propre trust store. Importez manuellement la CA via Paramètres > Certificats > Importer.

## Utilisation avec d'autres services

### Nginx

```yaml
services:
  nginx:
    image: nginx:alpine
    volumes:
      - ./certs/omgwtfssl/cert.pem:/etc/nginx/ssl/cert.pem:ro
      - ./certs/omgwtfssl/key.pem:/etc/nginx/ssl/key.pem:ro
    ports:
      - "443:443"
```

```nginx
server {
    listen 443 ssl;
    ssl_certificate     /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
}
```

### Traefik

```yaml
services:
  traefik:
    volumes:
      - ./certs/mkcert:/certs:ro
    command:
      - --providers.file.filename=/etc/traefik/dynamic.yml

# dynamic.yml
tls:
  certificates:
    - certFile: /certs/localhost+N.pem
      keyFile: /certs/localhost+N-key.pem
```

### Docker Registry

```yaml
services:
  registry:
    image: registry:2
    environment:
      - REGISTRY_HTTP_TLS_CERTIFICATE=/certs/cert.pem
      - REGISTRY_HTTP_TLS_KEY=/certs/key.pem
    volumes:
      - ./certs/omgwtfssl/cert.pem:/certs/cert.pem:ro
      - ./certs/omgwtfssl/key.pem:/certs/key.pem:ro
```

### Ansible (tâche réutilisable)

Exemple de tâche Ansible partagée supportant les 3 générateurs :

```yaml
# tasks/generate-ssl-cert.yml
- name: Generate SSL certificate with mkcert
  command: >
    mkcert
    -cert-file {{ ssl_dir }}/{{ ssl_cert_file }}
    -key-file {{ ssl_dir }}/{{ ssl_key_file }}
    "*.{{ domain }}" "{{ domain }}" "{{ ssl_ip }}"
  environment:
    CAROOT: "{{ ssl_dir }}"
  when: ssl_generator == "mkcert"

- name: Generate SSL certificate with omgwtfssl (Docker)
  command: >
    docker run --rm
    -v {{ ssl_dir }}:/certs
    -e SSL_SUBJECT="*.{{ domain }}"
    -e SSL_DNS="*.{{ domain }},{{ domain }}"
    -e SSL_IP="{{ ssl_ip }}"
    -e SSL_CERT="{{ ssl_cert_file }}"
    -e SSL_KEY="{{ ssl_key_file }}"
    paulczar/omgwtfssl
  when: ssl_generator == "omgwtfssl"

- name: Generate SSL certificate with openssl
  command: >
    openssl req -x509 -nodes -days {{ ssl_expire_days }}
    -newkey rsa:2048
    -keyout {{ ssl_dir }}/{{ ssl_key_file }}
    -out {{ ssl_dir }}/{{ ssl_cert_file }}
    -subj "/CN=*.{{ domain }}"
    -addext "subjectAltName=DNS:*.{{ domain }},DNS:{{ domain }},IP:{{ ssl_ip }}"
  when: ssl_generator == "openssl"
```

## Configuration

### Variables omgwtfssl

| Variable | Défaut | Rôle |
|----------|--------|------|
| `CA_KEY` | `ca-key.pem` | Clé privée de la CA — sert à signer le certificat serveur |
| `CA_CERT` | `ca.pem` | Certificat public de la CA — à installer dans le trust store |
| `CA_SUBJECT` | `my-ca` | Nom de la CA (champ CN). Apparaît dans "Issued By" du navigateur |
| `CA_EXPIRE` | `3650` | Durée de validité de la CA en jours |
| `SSL_KEY` | `key.pem` | Clé privée du serveur — utilisée par Nginx pour le TLS |
| `SSL_CSR` | `key.csr` | Certificate Signing Request — fichier intermédiaire temporaire |
| `SSL_CERT` | `cert.pem` | Certificat serveur signé par la CA — présenté aux clients |
| `SSL_CONFIG` | `openssl.cnf` | Fichier de config OpenSSL généré automatiquement |
| `SSL_SIZE` | `2048` | Taille de la clé RSA (2048 standard, 4096 plus sécurisé) |
| `SSL_EXPIRE` | `365` | Durée de validité du certificat serveur en jours |
| `SSL_SUBJECT` | `localhost` | CN (Common Name) — le domaine principal |
| `SSL_DNS` | `localhost,*.localhost` | Noms DNS alternatifs (SAN), séparés par virgules |
| `SSL_IP` | `127.0.0.1` | Adresses IP alternatives (SAN), séparées par virgules |

### Variables mkcert

| Variable | Défaut | Description |
|----------|--------|-------------|
| `MKCERT_DOMAINS` | `localhost 127.0.0.1 ::1` | Domaines et IPs (séparés par des espaces) |

### Variables openssl

| Variable | Défaut | Description |
|----------|--------|-------------|
| `SSL_SUBJECT` | `localhost` | Domaine principal (CN) |
| `SSL_DNS` | `localhost,*.localhost` | Noms DNS alternatifs (SAN), séparés par virgules |
| `SSL_IP` | `127.0.0.1` | Adresses IP alternatives (SAN), séparées par virgules |
| `SSL_SIZE` | `2048` | Taille de la clé RSA en bits |
| `SSL_EXPIRE` | `365` | Validité du certificat en jours |
| `SSL_COUNTRY` | `FR` | Pays (champ C du sujet) |
| `SSL_STATE` | `Local` | État/Région (champ ST) |
| `SSL_CITY` | `Dev` | Ville (champ L) |
| `SSL_ORG` | `Development` | Organisation (champ O) |

## Sécurité

- Ne **jamais** partager les fichiers `*-key.pem` (clés privées)
- Le fichier `rootCA-key.pem` de mkcert donne un contrôle total sur les certificats de confiance locale
- Utiliser ces outils **uniquement en développement**, pas en production
- Ajouter `certs/` au `.gitignore` pour ne pas versionner les certificats

## Références

- [mkcert - GitHub](https://github.com/FiloSottile/mkcert) (~51k stars)
- [omgwtfssl - GitHub](https://github.com/paulczar/omgwtfssl)
- [omgwtfssl - Docker Hub](https://hub.docker.com/r/paulczar/omgwtfssl)
- [Let's Encrypt](https://letsencrypt.org/) (alternative production)
- [OpenSSL Documentation](https://www.openssl.org/docs/)