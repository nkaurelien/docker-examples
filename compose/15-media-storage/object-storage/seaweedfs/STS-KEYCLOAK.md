# POC STS/OIDC SeaweedFS ↔ Keycloak (local kamitbrains)

Valide le flux : **JWT Keycloak → `AssumeRoleWithWebIdentity` → credentials S3 temporaires + droits par préfixe**, contre le Keycloak local `https://connect.asone4health.kamitbrains.local`.

## ✅ Déjà configuré (03/09/2026)

Côté **Keycloak local** (réalisé + validé) :
- Client **`seaweedfs-s3`** créé dans le realm `asone4health` (confidential, ROPC activé). Secret dans le `.env` (gitignoré).
- Compte de test **`seaweedfs-poc`** / `AsoneTest.2026`, rôle realm **`doctor`**.
- **JWT ROPC validé** : `iss = https://connect.asone4health.kamitbrains.local/realms/asone4health`, `azp=seaweedfs-s3`, `realm_access.roles=[doctor,…]`. Le realm local n'a **pas** de `frontendUrl` divergent (iss correct).

Côté **POC** (fichiers prêts) : `config/iam.json`, `docker-compose.sts.yml`, `test-sts.sh`, `.env` (valeurs réelles), `config/rootCA.pem` (CA mkcert copié).

**Reste à faire par toi** : démarrer Docker + `brew install awscli jq`, puis lancer (Étapes 3-4). Les Étapes 1-2 ci-dessous sont documentées pour reproductibilité / autre realm.

## Prérequis

- **Docker actif** (Docker Desktop / Colima / OrbStack démarré).
- **`awscli` + `jq`** (`brew install awscli jq`).
- **CA mkcert** : `MKCERT_CA=$(mkcert -CAROOT)/rootCA.pem` (ou copier ce fichier dans `config/rootCA.pem`).
- **IP LAN de kamitbrains** (défaut `192.168.0.195`) → `KEYCLOAK_HOST_IP`.
- **Accès admin** au Keycloak local pour créer le client + un compte de test.

## Étape 1 — Client Keycloak `seaweedfs-s3`

Dans le realm **`asone4health`** (KC local ; utiliser `asone4health-sandbox` si tu préfères isoler — ajuste alors `iam.json` et `REALM`) :

- **Client ID** : `seaweedfs-s3`
- **Access Type** : confidential (récupérer le secret) — ou public pour le POC
- **Direct Access Grants (ROPC)** : ON (permet au `test-sts.sh` d'obtenir un JWT via user/password)
- Un **compte de test** avec le rôle realm `doctor` (le mapping `iam.json` route `doctor` → `S3AttachmentsWriteRole`).

> Le mapper realm-roles doit émettre `realm_access.roles` (déjà en place côté prod ; vérifier sur le realm local — sinon le `defaultRole` de `iam.json` couvre quand même le POC).

## Étape 2 — Ajuster `config/iam.json`

- `providers[].config.issuer` / `jwksUri` : doivent matcher **exactement** l'issuer du realm (`.../realms/asone4health`). ⚠️ Vérifier que le realm local n'a **pas** de `frontendUrl` divergent (cf. incident prod `iss=www`).
- `roleMapping` : `defaultRole` = `S3AttachmentsWriteRole` (POC). La règle `claim: realm_access.roles / value: doctor` suppose que SeaweedFS lit les claims imbriqués — **à valider** ; sinon s'appuyer sur `defaultRole` ou un mapper KC exposant un claim plat.
- `signingKey` : régénérer (`openssl rand -base64 32`) pour autre chose qu'un POC.

## Étape 3 — Lancer (mode STS)

```bash
export KEYCLOAK_HOST_IP=192.168.0.195
export MKCERT_CA="$(mkcert -CAROOT)/rootCA.pem"
docker compose -f docker-compose.yml -f docker-compose.sts.yml up -d
docker compose logs -f s3     # vérifier le chargement de l'IAM/OIDC
```

## Étape 4 — Tester

```bash
export KC_USER='<compte-test>' KC_PASS='<mdp>'
export CLIENT_SECRET='<secret seaweedfs-s3 si confidentiel>'
export MKCERT_CA="$(mkcert -CAROOT)/rootCA.pem"
./test-sts.sh
```

Le script : obtient le JWT (ROPC), appelle `AssumeRoleWithWebIdentity`, puis lit/écrit dans `asone-attachments` avec les creds temporaires, et vérifie qu'une écriture **hors périmètre est refusée**.

## Points à valider / pièges

- **Flag IAM** : `-iam.config` (vu aussi `-s3.iam.config` selon versions) — vérifier dans les logs `weed s3`.
- **`iss` exact** : le JWT doit porter `iss = https://connect.asone4health.kamitbrains.local/realms/asone4health` (pas de `frontendUrl` divergent côté realm local).
- **TLS mkcert** : si le JWKS échoue en TLS, vérifier que `SSL_CERT_FILE` pointe bien le rootCA mkcert monté.
- **Résolution DNS** : le conteneur `s3` doit résoudre `connect.asone4health.kamitbrains.local` → `extra_hosts` (IP kamitbrains).
- **Claim de rôle imbriqué** : si `realm_access.roles` n'est pas exploité par le roleMapping, utiliser `defaultRole`.
