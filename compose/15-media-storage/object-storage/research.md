---
tags: attachments, backend, docker-compose, hds, research, self-hosted
---

# Research — Backend S3 self-hosted pour les attachments HDS

Format décisionnel (Décision / Justification / Alternatives). Complète [`COMPARATIF-S3.md`](COMPARATIF-S3.md) (état/tableaux) et [`PROMPT.md`](PROMPT.md) (reprise). Statut : évaluation, POC en cours (2026-09-03).

---

## D1 — Abandonner MinIO Community Edition

- **Décision** : ne pas rester sur MinIO CE ; migrer vers une alternative S3-compatible maintenue.
- **Justification** : console admin retirée (mai 2025), licence AGPLv3, **dépôt archivé / non maintenu depuis fév. 2026** → plus de correctifs de sécurité. Inacceptable pour de la donnée de santé (HDS).
- **Alternatives considérées** :
  - *Rester sur MinIO CE* : rejeté (logiciel mort, risque CVE).
  - *MinIO AIStor Enterprise* : rejeté (~96 000 $/an, vendor lock).
  - *Fork communautaire MinIO* : rejeté pour l'instant (jeune, même risque maturité que RustFS).

## D2 — Solution cible : SeaweedFS

- **Décision** : **SeaweedFS** comme cible prod, sous réserve de validation S3 (D5) au POC.
- **Justification** : mature (~2015), maintenu, Apache 2.0, IAM complet (STS, bucket policies, OIDC), droits par préfixe, réplication + erasure coding, aucun vendor lock. Avis indépendant convergent (Stéphane Robert : « meilleur compromis »).
- **Alternatives considérées** :
  - *RustFS* : gardé en **veille** — drop-in MinIO séduisant (Rust, léger, migration triviale car mêmes ports 9000/9001) mais **trop jeune** pour du HDS ; réévaluer 6-12 mois. Plan B si SeaweedFS échoue sur la compat S3.
  - *Garage* : rejeté — pas d'OIDC, pas de droits par préfixe, pas de versioning.
  - *Ceph RGW* : rejeté — surdimensionné, lourd à opérer pour ce besoin.

## D3 — Modèle d'accès : OIDC + STS Keycloak (vs credentials statiques)

- **Décision** : viser des **credentials S3 temporaires via STS `AssumeRoleWithWebIdentity`** adossés à **Keycloak** (realm `asone4health`), avec **droits par préfixe** ; conserver des credentials statiques (`s3.json`) en fallback pour les jobs hors contexte OIDC (backups, migration).
- **Justification** : Keycloak est déjà en place. Les creds temporaires + le scoping par préfixe réduisent la surface (pas de secret long-terme en clair) et améliorent l'auditabilité HDS. C'est le critère différenciant du comparatif.
- **Alternatives considérées** :
  - *Credentials statiques uniquement (`s3.json`)* : acceptable pour démarrer, mais secret long-terme à gérer/roter ; retenu seulement en fallback.
  - *Un bucket par tenant sans préfixe* : plus simple mais multiplie les buckets ; le scoping par préfixe est plus souple.
- **Édition OSS vs Enterprise** (vérifié) : l'**OIDC/STS pour l'accès S3** (`AssumeRoleWithWebIdentity`) est **open source** (Advanced IAM par défaut) → notre besoin app est couvert sans licence. En revanche l'**OIDC login de l'Admin UI est Enterprise** (non bloquant : `admin`/password). Certaines features de résilience (customizable EC, self-healing, recovery window) sont aussi Enterprise (gratuit < 25 TB dev/test, licence prod) → à arbitrer selon volume/durabilité.
- **À valider (POC)** : forme exacte de la config IAM/STS SeaweedFS (version-dépendante), mapping des claims Keycloak (`realm_access.roles`) → policy, TTL des creds.

## D4 — Chiffrement au repos

- **Décision** : s'appuyer d'abord sur la spec **006** (field-level AES-GCM + Vault, **côté application**) ; activer en complément le chiffrement volume / SSE-C de SeaweedFS (défense en profondeur).
- **Justification** : le chiffrement applicatif est indépendant du backend S3 et déjà cadré (006). Le chiffrement stockage ajoute une couche sans être le seul rempart.
- **Alternatives considérées** :
  - *Chiffrement backend seul* : rejeté (dépend du backend, moins de contrôle que le field-level).

## D5 — Compatibilité S3 (réserve bloquante)

- **Décision** : valider au POC, sur l'usage réel, **multipart upload** (gros attachments), **presigned URLs**, tags et `Content-Type` avant d'acter SeaweedFS.
- **Justification** : la compat S3 de SeaweedFS est bonne mais **pas 100% AWS** ; ces fonctions sont utilisées par l'upload d'attachments. Si l'une échoue → reconsidérer RustFS (D2).
- **Méthode** : `test-s3.sh` + test multipart sur un gros fichier + génération/consommation d'une presigned URL.

## D6 — Stratégie de migration

- **Décision** : migration data via **`rclone sync`** (dry-run d'abord) MinIO → cible ; transformer le rôle Ansible `minio` en `seaweedfs`.
- **Justification** : les deux sont S3-compatibles → migration standard, portage code quasi nul (endpoint + creds).
- **Alternatives considérées** :
  - *`mc mirror`* : possible mais `mc` (client MinIO) suit le sort de MinIO ; `rclone` est neutre et pérenne.

---

## Questions ouvertes

- Config OIDC/STS SeaweedFS exacte (version) — à confirmer sur la [doc officielle](https://github.com/seaweedfs/seaweedfs/wiki).
- Erasure coding : nombre de volumes / topologie cible pour la durabilité HDS.
- Coût opérationnel SeaweedFS (master/volume/filer) vs MinIO mono-binaire.

## Références

Voir [`COMPARATIF-S3.md` §8](COMPARATIF-S3.md#8-références).
