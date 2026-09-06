# PROMPT — Évaluation stockage objet S3 (remplacement MinIO)

Brief de reprise pour continuer le dev/éval depuis une autre machine ou session.

## Mission

MinIO Community Edition se dégrade (console web retirée, bascule vers AIStor payant, licence AGPL). Objectif : choisir une **alternative S3-compatible self-hosted** pour les **attachments médicaux (HDS)** d'AsOne4Health, puis remplacer le rôle Ansible `minio` par la techno retenue.

Contrainte clé : donnée de **santé** → maturité, durabilité (réplication/erasure coding), chiffrement au repos, et compat S3 réelle priment sur la nouveauté.

## Ce dossier (`15-media-storage/object-storage/`)

Un sous-dossier POC par techno :

| Dossier | Techno | S3 API | Console/Admin | État |
|---|---|---|---|---|
| `minio-s3/` | MinIO (référence actuelle) | 9000 | 9001 | existant |
| `seaweedfs/` | **SeaweedFS** | **8333** | Admin UI **23646** | POC créé, non lancé |
| `rustfs/` | **RustFS** (drop-in MinIO, Rust) | **9000** | Console **9001** | POC créé, non lancé |
| `using-s3fs-volume/` | montage s3fs | — | — | existant |

⚠️ **RustFS et MinIO partagent 9000/9001** → ne pas les lancer simultanément. SeaweedFS (8333/9333/23646) n'entre pas en conflit.

## Lancer / tester

```bash
# SeaweedFS
cd seaweedfs && cp .env.example .env && docker compose up -d && ./test-s3.sh
#   Admin UI: http://localhost:23646  (admin / Admin.poc.2026)

# RustFS
cd rustfs && cp .env.example .env && docker compose up -d && ./test-s3.sh
#   Console:  http://localhost:9001

# arrêt + purge
docker compose down -v
```

`test-s3.sh` = smoke test AWS CLI (mb/cp/ls/get/presign/rm). `rclone` marche aussi (type s3, provider Other).

## Grille d'évaluation (à remplir pour trancher)

- [ ] Compat S3 sur l'usage réel : **multipart** (gros attachments), **presigned URLs**, tags, `Content-Type`.
- [ ] **Credentials/ACL par bucket** (isolation compte applicatif backend). SeaweedFS : `config/s3.json` (identities scopées). RustFS : à vérifier.
- [ ] **OIDC + STS Keycloak** (axe différenciant, Keycloak déjà en place) : `AssumeRoleWithWebIdentity` depuis un jeton Keycloak → creds S3 temporaires + droits par préfixe (détail : `seaweedfs/README.md` §OIDC/STS, décision D3 de `research.md`).
- [ ] **Chiffrement au repos** (SSE / volume encryption) vs stratégie 006 (field-level Vault, côté app).
- [ ] **Durabilité** : réplication / erasure coding (multi-volumes).
- [ ] **Maturité prod** (critère HDS décisif).
- [ ] **Migration data** depuis MinIO (`rclone sync` / `mc mirror`).
- [ ] **Portage code backend** : client S3/boto3 → idéalement juste endpoint + creds.
- [ ] Empreinte ressources.

## Recommandation courante

- **SeaweedFS = candidat prod** (mature depuis ~2015, réplication/erasure coding, ACL par bucket, communauté active). Point d'attention : compat S3 pas 100% AWS → valider multipart + presign contre l'usage réel.
- **RustFS = veille** (drop-in MinIO séduisant, Rust, léger) mais **trop jeune** pour porter de la donnée de santé en prod aujourd'hui. Réévaluer dans 6-12 mois.
- Décision non figée : ce POC sert à confirmer/infirmer via la grille ci-dessus.

## Suite (next steps)

1. Lancer les 2 POC, dérouler `test-s3.sh` + tester multipart (gros fichier) et presigned URL.
2. Vérifier ACL par bucket sur RustFS (SeaweedFS OK via s3.json).
3. Tester `rclone sync` MinIO → candidat (dry-run) pour valider la migration.
4. Trancher, puis créer une spec (speckit) de migration + transformer le rôle Ansible `minio` en `seaweedfs` (ou `rustfs`).

## Contexte repo asone4health

- WIP MinIO de l'utilisateur (rôle ansible `minio` + compose) **non commité sur develop** — à préserver, ne pas écraser.
- Stratégie attachments : avatars en base64 dans `photo`, gros fichiers → objet S3.
- Chiffrement : spec 006 (field-level AES-GCM + Vault) est **côté app**, indépendante du backend S3.
