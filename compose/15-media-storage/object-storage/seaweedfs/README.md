---
tags: distributed-storage, docker-compose, objet, poc, seaweedfs, stockage
---

# SeaweedFS — POC stockage objet S3

Expérimentation en vue de remplacer **MinIO Community Edition** (console retirée / bascule AIStor payant) par une alternative S3-compatible pour les **attachments médicaux** d'AsOne4Health.

> POC local isolé — **pas** de données réelles, credentials factices à changer avant tout usage sérieux.

## Architecture

| Service | Rôle | Port hôte |
|---|---|---|
| `master` | métadonnées cluster, allocation volumes | 9333 (UI), 19333 (gRPC) |
| `volume` | stockage physique des chunks | 8080, 18080 |
| `filer`  | arborescence fichiers + métadonnées | 8888, 18888 |
| `s3`     | **passerelle S3** (le cœur du remplacement MinIO) | 8333 |
| `admin`  | Admin UI (`weed admin`) | 23646 |
| `prometheus` | métriques (profile `monitoring`) | 9091 |

## Démarrage

```bash
cp .env.example .env          # ajuste ADMIN_PASSWORD au besoin
docker compose up -d          # cluster + S3 + admin
docker compose --profile monitoring up -d   # + Prometheus
docker compose logs -f s3     # suivre la passerelle S3
```

Accès :
- **Master UI** : http://localhost:9333
- **Admin UI** : http://localhost:23646 — `admin` / `Admin.poc.2026` (ou `$ADMIN_PASSWORD`)
- **S3 API** : http://localhost:8333 — credentials dans [`config/s3.json`](config/s3.json)
- **Prometheus** : http://localhost:9091

## Tester l'API S3

```bash
./test-s3.sh          # mb / cp / ls / get / presign / rm via AWS CLI
```

Ou manuellement :
```bash
export AWS_ACCESS_KEY_ID=asone_poc_access
export AWS_SECRET_ACCESS_KEY=asone_poc_secret_change_me
aws --endpoint-url http://localhost:8333 s3 ls
```

`rclone` fonctionne aussi (remote type `s3`, provider `Other`, endpoint `http://localhost:8333`).

## Credentials & ACL (`config/s3.json`)

- `asone-poc-admin` : accès complet (Admin) — pour l'exploration.
- `asone-app` : accès **scopé au bucket `asone-attachments`** (Read/Write/List/Tagging) — modèle du compte applicatif backend.

Modifier ce fichier puis `docker compose restart s3`.

## Grille d'évaluation (vs MinIO)

- [ ] Compat S3 sur l'usage réel : multipart upload (gros attachments), presigned URLs, `Content-Type`, tags.
- [ ] ACL/credentials par bucket (isolation compte applicatif).
- [ ] **OIDC + STS Keycloak** : `AssumeRoleWithWebIdentity` depuis un jeton Keycloak → credentials S3 **temporaires** + droits **par préfixe** (voir section dédiée ci-dessous).
- [ ] Chiffrement au repos (volume encryption / SSE-C) vs stratégie 006 (field-level Vault, côté app).
- [ ] Réplication / erasure coding (durabilité HDS).
- [ ] Migration data depuis MinIO (`rclone sync` / `mc mirror`).
- [ ] Portage du code backend (client S3/boto3 : idéalement zéro changement, juste endpoint + creds).
- [ ] Empreinte ressources vs MinIO.
- [ ] Admin UI : santé cluster, volumes, buckets.

## Intégration OIDC/STS Keycloak (axe différenciant)

AsOne4Health a **déjà Keycloak** (realm `asone4health`). Plutôt que des credentials S3 statiques (`config/s3.json`), SeaweedFS peut délivrer des **credentials temporaires** via **STS** à partir d'un jeton OIDC Keycloak → meilleure posture sécurité + auditabilité HDS + droits **par préfixe**.

### Principe / flux

```
Backend (a un JWT Keycloak realm asone4health)
   │  1. AssumeRoleWithWebIdentity(WebIdentityToken = JWT Keycloak)
   ▼
SeaweedFS S3 (endpoint STS)  ──valide le JWT via JWKS Keycloak──▶ Keycloak
   │  2. mappe claims (realm_access.roles / groups) → policy SeaweedFS
   ▼
Credentials S3 TEMPORAIRES (accessKey/secretKey/sessionToken, TTL court)
   │  3. appels S3 scopés (bucket + préfixe autorisés par la policy)
   ▼
asone-attachments/<tenant>/…
```

### Configuration indicative

SeaweedFS expose une **IAM avec identity providers OIDC + policies** (au-delà du `s3.json` statique). Schéma cible :

1. **Provider OIDC** pointant sur Keycloak :
   - issuer : `https://connect.asone4health.fr/realms/asone4health`
   - JWKS : `…/protocol/openid-connect/certs`
2. **Policies** SeaweedFS accordant `s3:GetObject/PutObject/ListBucket` **restreintes par préfixe** (ex. `asone-attachments/${claim}/*`).
3. **Mapping claims → rôle/policy** : à partir de `realm_access.roles` (le mapper `roles` qu'on a corrigé côté KC) ou d'un claim dédié.
4. Endpoint **STS** `AssumeRoleWithWebIdentity` : le backend échange son JWT Keycloak contre des creds S3 temporaires.

> ⚠️ La forme exacte de la config IAM/STS **dépend de la version** de SeaweedFS — à valider contre la [doc officielle](https://github.com/seaweedfs/seaweedfs/wiki) pendant le POC (fichier IAM, format des policies, activation de l'endpoint STS). Ne pas considérer le schéma ci-dessus comme figé.

### Édition : ce qui est OSS vs Enterprise ⚠️

| Fonction | Édition |
|---|---|
| **OIDC/STS pour l'accès S3** (`AssumeRoleWithWebIdentity` — creds temporaires app via JWT Keycloak) | ✅ **Open source** (Advanced IAM activé par défaut) |
| Credentials statiques + ACL par bucket (`s3.json`) | ✅ Open source |
| Réplication | ✅ Open source |
| **OIDC login de l'Admin UI** (`weed admin`) | 🏢 **Enterprise** — pour le POC/prod, utiliser `admin` + password (non bloquant) |
| Customizable erasure coding, self-healing, EC vacuum/repair, recovery window (restauration de suppressions) | 🏢 Enterprise (gratuit < 25 TB dev/test ; licence en prod) |

→ **Notre besoin (OIDC/STS S3 pour le backend) est couvert en OSS.** Seul l'OIDC *de l'admin UI* est Enterprise, ce qui n'est pas bloquant. À arbitrer selon volume/durabilité : certaines features de résilience avancée sont Enterprise.

### À tester (POC)

- [ ] Configurer Keycloak comme provider OIDC de SeaweedFS S3.
- [ ] `AssumeRoleWithWebIdentity` avec un vrai JWT Keycloak (compte doctor/app) → obtention de creds temporaires.
- [ ] Vérifier l'isolation **par préfixe** (un token ne peut lire/écrire que son préfixe).
- [ ] Expiration/rotation des creds temporaires (TTL).
- [ ] Fallback creds statiques (`s3.json`) pour les jobs sans contexte OIDC (backups, migration).

## Notes

- Flags `weed admin` : auth (`-adminUser`/`-adminPassword`) et reverse proxy sous-répertoire (`-urlPrefix=/seaweedfs`) — cf. [wiki Admin-UI](https://github.com/seaweedfs/seaweedfs/wiki/Admin-UI).
- Compat S3 de SeaweedFS bonne mais **pas 100%** de l'API AWS — d'où la grille ci-dessus contre l'usage réel.
- **RustFS** (drop-in MinIO en Rust) est l'autre candidat, mais trop jeune pour de la prod santé aujourd'hui → veille.
