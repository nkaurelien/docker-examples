# Let's Encrypt & ACME avec Traefik

## Qu'est-ce que Let's Encrypt ?

Let's Encrypt est une autorité de certification (CA) gratuite et automatisée qui fournit des certificats SSL/TLS pour sécuriser vos sites web en HTTPS.

## Qu'est-ce qu'ACME ?

**ACME** (Automatic Certificate Management Environment) est le protocole utilisé pour automatiser l'émission et le renouvellement des certificats. Traefik utilise ce protocole pour communiquer avec Let's Encrypt.

## Le fichier acme.json

### Rôle

Le fichier `acme.json` est la base de données locale où Traefik stocke :
- Les certificats SSL obtenus
- Les clés privées associées
- Les métadonnées (date d'expiration, domaine, etc.)

### Structure

```json
{
  "letsencrypt": {
    "Account": {
      "Email": "admin@example.com",
      "Registration": {
        "body": { ... },
        "uri": "https://acme-v02.api.letsencrypt.org/acme/acct/123456"
      },
      "PrivateKey": "base64-encoded-private-key...",
      "KeyType": "4096"
    },
    "Certificates": [
      {
        "domain": {
          "main": "example.com",
          "sans": ["www.example.com", "api.example.com"]
        },
        "certificate": "base64-encoded-certificate...",
        "key": "base64-encoded-private-key...",
        "Store": "default"
      }
    ]
  }
}
```

### Champs importants

| Champ | Description |
|-------|-------------|
| `Account.Email` | Email enregistré auprès de Let's Encrypt |
| `Account.PrivateKey` | Clé privée du compte ACME |
| `Certificates` | Liste des certificats obtenus |
| `domain.main` | Domaine principal |
| `domain.sans` | Subject Alternative Names (domaines supplémentaires) |
| `certificate` | Certificat public (base64) |
| `key` | Clé privée du certificat (base64) |

## Permissions du fichier

**CRITIQUE** : Le fichier doit avoir des permissions restrictives car il contient des clés privées.

```bash
# Créer le fichier avec les bonnes permissions
touch letsencrypt/acme.json
chmod 600 letsencrypt/acme.json
```

Traefik refuse de démarrer si les permissions sont trop ouvertes.

## Types de challenges ACME

### 1. HTTP Challenge (recommandé pour la plupart des cas)

```yaml
command:
  - "--certificatesresolvers.letsencrypt.acme.httpchallenge=true"
  - "--certificatesresolvers.letsencrypt.acme.httpchallenge.entrypoint=web"
```

**Fonctionnement** :
1. Traefik demande un certificat pour `example.com`
2. Let's Encrypt génère un token unique
3. Let's Encrypt fait une requête HTTP vers `http://example.com/.well-known/acme-challenge/<token>`
4. Si Traefik répond correctement, le certificat est émis

**Prérequis** :
- Port 80 accessible depuis Internet
- DNS pointant vers votre serveur

### 2. DNS Challenge (pour wildcards et serveurs non exposés)

```yaml
command:
  - "--certificatesresolvers.letsencrypt.acme.dnschallenge=true"
  - "--certificatesresolvers.letsencrypt.acme.dnschallenge.provider=cloudflare"
environment:
  - CF_API_EMAIL=your@email.com
  - CF_API_KEY=your-api-key
```

**Fonctionnement** :
1. Traefik crée un enregistrement DNS TXT `_acme-challenge.example.com`
2. Let's Encrypt vérifie cet enregistrement
3. Le certificat est émis

**Avantages** :
- Supporte les certificats wildcard (`*.example.com`)
- Fonctionne sans exposer le port 80

### 3. TLS Challenge

```yaml
command:
  - "--certificatesresolvers.letsencrypt.acme.tlschallenge=true"
```

Utilise le port 443 pour la validation.

## Environnement de staging

Pour les tests, utilisez le serveur staging pour éviter les limites de rate :

```yaml
command:
  - "--certificatesresolvers.letsencrypt.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory"
```

Les certificats staging ne sont pas valides pour les navigateurs mais permettent de tester la configuration.

## Configuration d'un service avec HTTPS

```yaml
services:
  my-app:
    labels:
      - "traefik.enable=true"
      # Router HTTPS
      - "traefik.http.routers.my-app.rule=Host(`app.example.com`)"
      - "traefik.http.routers.my-app.entrypoints=websecure"
      - "traefik.http.routers.my-app.tls.certresolver=letsencrypt"
```

## Certificat wildcard

```yaml
labels:
  - "traefik.http.routers.my-app.tls.certresolver=letsencrypt"
  - "traefik.http.routers.my-app.tls.domains[0].main=example.com"
  - "traefik.http.routers.my-app.tls.domains[0].sans=*.example.com"
```

## Renouvellement automatique

Traefik renouvelle automatiquement les certificats 30 jours avant expiration. Aucune action manuelle requise.

## Dépannage

### Vérifier le contenu d'acme.json

```bash
# Voir les domaines avec certificats
cat letsencrypt/acme.json | jq '.letsencrypt.Certificates[].domain'
```

### Erreurs communes

| Erreur | Solution |
|--------|----------|
| `permissions 0644 for acme.json are too open` | `chmod 600 letsencrypt/acme.json` |
| `too many registrations` | Attendre 1h, utiliser staging |
| `DNS problem: NXDOMAIN` | Vérifier la configuration DNS |
| `connection refused` | Port 80/443 bloqué par firewall |

### Forcer le renouvellement

```bash
# Supprimer le certificat et redémarrer
docker compose down
rm letsencrypt/acme.json
docker compose up -d
```

### Voir les logs ACME

```bash
docker compose logs traefik | grep -i acme
```

## Limites de Let's Encrypt

| Limite | Valeur |
|--------|--------|
| Certificats par domaine | 50/semaine |
| Domaines par certificat | 100 |
| Échecs de validation | 5/heure |
| Comptes par IP | 10/3 heures |

## Bonnes pratiques

1. **Toujours tester en staging** avant la production
2. **Sauvegarder acme.json** pour éviter de redemander des certificats
3. **Utiliser des wildcards** pour plusieurs sous-domaines
4. **Monitorer les expirations** même avec le renouvellement auto
5. **Ne jamais exposer acme.json** publiquement
