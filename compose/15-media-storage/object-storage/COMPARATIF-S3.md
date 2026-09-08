---
tags: cision, comparatif, docker-compose, objet, self-hosted, stockage
---

# Stockage objet S3 self-hosted — Comparatif & décision

> Doc de référence pour le remplacement de MinIO comme backend S3 des **attachments médicaux (HDS)** d'AsOne4Health.
> Statut : **évaluation** (POC en cours). Cible pressentie : **SeaweedFS**.
> Dernière MAJ : 2026-09-03.

---

## 1. Contexte & problème

MinIO Community Edition, backend S3 historique, n'est plus une cible tenable :

| Date | Événement |
|---|---|
| Mai 2025 | **Console admin retirée** de la CE (reste un simple « object browser »). Policies / réplication / lifecycle / IAM → **AIStor Enterprise** (~96 000 $/an). |
| 2025 | Licence **Apache 2.0 → AGPLv3** (copyleft fort). |
| **Fév. 2026** | Dépôt open source **archivé / « no longer maintained »** → **plus aucun patch, sécurité incluse**. |

**Conséquence HDS** : faire tourner un logiciel non maintenu pour stocker de la donnée de santé est une **impasse** (CVE non corrigées). → Migration nécessaire.

---

## 2. Solutions candidates

| Solution | Licence | Maturité | Modèle d'accès (OIDC/STS/préfixe) | Durabilité | Verdict |
|---|---|---|---|---|---|
| **SeaweedFS** | Apache 2.0 | Élevée (~2015) | ✅ OIDC + STS + bucket policies + droits par préfixe | Réplication + erasure coding | ✅ **Cible** |
| **RustFS** | Apache 2.0 | Jeune (2024+) | ✅ (annoncé) | À prouver | 🟡 Veille |
| MinIO CE | AGPLv3 | Élevée mais **archivée** | ✅ | Erasure coding | ❌ Non maintenu |
| **Garage** | AGPLv3 | Bonne | ❌ **pas d'OIDC, pas de préfixe, pas de versioning** | Réplication géo | ❌ Périmètre trop restreint |
| **Ceph RGW** | LGPL | Élevée | ✅ | CRUSH, très robuste | ❌ Surdimensionné / lourd à opérer |

---

## 3. Critère décisif : le modèle d'accès

Pour AsOne4Health, le facteur différenciant est le **modèle d'autorisation**, car **Keycloak (OIDC) est déjà en place** :

- **OIDC + STS** : le backend peut obtenir des **credentials S3 temporaires** via échange de jeton Keycloak, au lieu de secrets statiques (`accessKey/secretKey` en dur). → meilleure posture sécurité + auditabilité HDS.
- **Droits par préfixe / bucket** : isolation fine (ex. un préfixe par patient/tenant), scopée au compte applicatif.

**SeaweedFS, RustFS, MinIO et Ceph** cochent ces cases. **Garage non** (clé/bucket uniquement) → éliminé malgré sa légèreté.

---

## 4. Recommandation

1. **SeaweedFS = cible prod.** Mature, maintenu, licence permissive (Apache 2.0), IAM complet (STS, bucket policies, OIDC), réplication + erasure coding. Aucun vendor lock. Avis indépendant convergent (S. Robert : « meilleur compromis »).
   - **Réserve à lever** : compat S3 pas 100% AWS → valider **multipart** (gros attachments) et **presigned URLs** contre l'usage réel (cf. grille §6).
   - **Édition (OSS vs Enterprise)** : l'**OIDC/STS pour l'accès S3** (creds temporaires app via Keycloak) est **open source** → notre besoin est couvert sans licence. En revanche l'**OIDC login de l'Admin UI est Enterprise** (non bloquant : `admin`/password). Features de résilience avancées (customizable erasure coding, self-healing, recovery window) = Enterprise (gratuit < 25 TB dev/test, licence prod) → arbitrer selon volume/durabilité.
2. **RustFS = veille.** Techniquement séduisant (drop-in MinIO, Rust, léger, migration triviale car mêmes ports 9000/9001), mais **trop jeune** pour de la donnée de santé aujourd'hui. Réévaluer dans 6-12 mois.
3. **Garage / Ceph écartés** (périmètre / complexité).

---

## 5. Intégration avec l'existant AsOne4Health

- **Auth** : SeaweedFS S3 + **OIDC Keycloak** (realm `asone4health`) + STS → credentials temporaires pour le backend. À tester (axe fort du POC).
- **Chiffrement** : la spec **006** (field-level AES-GCM + Vault) est **côté application**, indépendante du backend S3. SeaweedFS ajoute le chiffrement volume / SSE-C comme défense en profondeur.
- **Code backend** : client S3 (boto3) → idéalement seul l'endpoint + les creds changent (compat S3).
- **IaC** : le rôle Ansible `minio` (WIP utilisateur, non commité) deviendra `seaweedfs`.
- **Migration data** : `rclone sync` (ou `mc mirror`) MinIO → SeaweedFS, en dry-run d'abord.

---

## 6. Grille d'évaluation (POC)

- [ ] Compat S3 : **multipart upload** (gros attachments), **presigned URLs**, tags, `Content-Type`.
- [ ] **OIDC + STS Keycloak** : obtention de credentials temporaires depuis un jeton Keycloak.
- [ ] **Droits par préfixe / bucket** (isolation compte applicatif) — SeaweedFS `s3.json` (identities scopées) + policies.
- [ ] **Chiffrement au repos** (volume / SSE-C).
- [ ] **Durabilité** : réplication + erasure coding (multi-volumes).
- [ ] **Migration** : `rclone sync` MinIO → candidat (dry-run).
- [ ] **Portage code** : endpoint + creds seulement.
- [ ] Empreinte ressources.

---

## 7. POC (ce dossier)

| Dossier | Techno | S3 | Console/Admin | Lancer |
|---|---|---|---|---|
| `seaweedfs/` | SeaweedFS | 8333 | Admin UI 23646 | `cd seaweedfs && cp .env.example .env && docker compose up -d && ./test-s3.sh` |
| `rustfs/` | RustFS | 9000 | Console 9001 | `cd rustfs && cp .env.example .env && docker compose up -d && ./test-s3.sh` |
| `minio-s3/` | MinIO (réf.) | 9000 | 9001 | existant |

⚠️ RustFS et MinIO partagent 9000/9001 → ne pas lancer en parallèle.

Voir [`PROMPT.md`](PROMPT.md) pour le brief de reprise détaillé.

---

## 8. Références

- MinIO — console retirée / archivage :
  - [Blocks & Files (06/2025)](https://www.blocksandfiles.com/ai-ml/2025/06/19/minio-users-complain-after-admin-ui-removed-from-community-edition/1610856)
  - [Cloudian](https://cloudian.com/blog/minios-ui-removal-leaves-organizations-searching-for-alternatives/) · [Bizety (12/2025)](https://bizety.com/2025/12/06/minio-in-maintenance-mode-open-source-alternatives/) · [Vonng](https://blog.vonng.com/en/db/minio-is-dead/)
- Comparatif & docs S3 (Stéphane Robert) :
  - [Comparatif S3 auto-hébergés](https://blog.stephane-robert.info/docs/services/stockage/comparatif-s3/) · [SeaweedFS](https://blog.stephane-robert.info/docs/services/stockage/seaweedfs/) · [RustFS](https://blog.stephane-robert.info/docs/services/stockage/rustfs/) · [Garage](https://blog.stephane-robert.info/docs/services/stockage/garage/)
- Officiel :
  - SeaweedFS : <https://github.com/seaweedfs/seaweedfs/wiki> · RustFS : <https://docs.rustfs.com/>
