---
tags: docker-compose, object-storage, objet, poc, rustfs, stockage
---

# RustFS — POC stockage objet S3

Candidat **drop-in MinIO** écrit en Rust (Apache 2.0), API S3 sur les mêmes ports que MinIO.

> POC local isolé — credentials factices à changer. Projet **jeune** : à évaluer avec prudence pour de la donnée de santé.

## Démarrage

```bash
cp .env.example .env
docker compose up -d
./test-s3.sh
```

⚠️ **Ports 9000/9001 = identiques à MinIO** → ne pas lancer `minio-s3/` en même temps.

Accès :
- **S3 API** : http://localhost:9000
- **Console** : http://localhost:9001 — login = `RUSTFS_ACCESS_KEY` / `RUSTFS_SECRET_KEY`

## Variables (`.env`)

| Variable | Rôle |
|---|---|
| `RUSTFS_ACCESS_KEY` / `RUSTFS_SECRET_KEY` | credentials root + login console |
| `RUSTFS_VOLUMES` | chemin(s) de stockage (`/data` ; multi-chemins pour erasure coding) |
| `RUSTFS_ADDRESS` / `RUSTFS_CONSOLE_ADDRESS` | binds S3 / console |
| `RUSTFS_CONSOLE_ENABLE` | active la console web |

## Grille d'évaluation (vs SeaweedFS / MinIO)

- [ ] Compat S3 réelle : multipart (gros attachments), presigned URLs, tags, `Content-Type`.
- [ ] Credentials/ACL par bucket (isolation compte applicatif) — RustFS gère-t-il des utilisateurs scopés comme le `s3.json` de SeaweedFS ?
- [ ] Chiffrement au repos (SSE) — supporté ?
- [ ] Erasure coding / durabilité (multi-volumes).
- [ ] **Maturité / stabilité en prod** (le point faible : projet récent, peu de retours santé).
- [ ] Migration data depuis MinIO (`rclone sync`).
- [ ] Empreinte ressources (argument Rust).

## Notes

- Doc : https://docs.rustfs.com/installation/docker/ · compose officiel : https://github.com/rustfs/rustfs/blob/main/docker-compose.yml
- Se veut compatible API MinIO/S3 → portage code quasi nul si compat confirmée.
- **Risque principal = maturité** : pour de la donnée médicale HDS, exiger des preuves de stabilité/durabilité avant prod.
