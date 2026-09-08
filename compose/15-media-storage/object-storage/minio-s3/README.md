---
tags: docker-compose, minio, object-storage, s3, storage
---

# MinIO S3

Stockage objet compatible S3.

| Fichier | Usage |
| --- | --- |
| `compose.yml` | version simple, sans chiffrement |
| `compose.encrypted.yml` | **chiffrement au repos** (SSE-KMS) + provisioning du bucket |

## Démarrage

```console
docker network create minio_network
cp .env.example .env      # puis renseigner MINIO_ROOT_PASSWORD
docker compose up -d
```

Console web : http://localhost:9001 · API S3 : http://localhost:9000

## Version chiffrée

```console
docker network create minio_network
./generate-kms-key.sh     # crée .env avec une clé maître valide
docker compose -f compose.encrypted.yml up -d
docker compose -f compose.encrypted.yml logs mc-init
```

Les logs de `mc-init` affichent la règle de chiffrement du bucket, puis la
preuve : un objet écrit **sans header SSE** ressort chiffré.

### Comment ça marche

MinIO utilise un chiffrement par enveloppe. La clé maître (`MINIO_KMS_SECRET_KEY`)
ne chiffre pas les objets directement : elle sert à dériver une *data key*
unique par objet, dont seule la version chiffrée est stockée dans les métadonnées.

Trois réglages, complémentaires :

| Réglage | Effet |
| --- | --- |
| `MINIO_KMS_SECRET_KEY` | active le KMS. Format imposé : `<nom>:<32 octets en base64>` |
| `MINIO_KMS_AUTO_ENCRYPTION=on` | chiffre aussi les uploads sans header SSE. Sans lui, un client peut écrire en clair |
| `mc encrypt set sse-kms` | règle par défaut du bucket, lisible via `mc encrypt info` — c'est ce qui rend le chiffrement *vérifiable*, pas seulement configuré |

La clé se génère avec la commande de la documentation MinIO :

```console
head -c 32 /dev/urandom | base64
```

32 octets, soit 256 bits : c'est la taille attendue, pas un choix arbitraire.
En base64 cela donne toujours 44 caractères — un bon contrôle rapide.

### Vérifier

```console
docker compose -f compose.encrypted.yml exec minio mc encrypt info local/demo-bucket
docker compose -f compose.encrypted.yml exec minio mc stat local/demo-bucket/<objet>
```

`mc stat` d'un objet chiffré affiche ses métadonnées SSE. Un objet écrit avant
l'activation du chiffrement n'en aura pas : **le chiffrement n'est pas
rétroactif**. Pour reprendre des données existantes, il faut les réécrire une
fois la règle en place.

### Limites à connaître

- **Perdre la clé maître = perdre les données.** Elle chiffre aussi la
  configuration IAM (utilisateurs, policies) une fois le KMS actif. Sauvegarder
  `.env` ailleurs. `generate-kms-key.sh` refuse d'écraser un `.env` existant
  pour cette raison.
- **Pas de rotation en place.** Changer la clé rend illisibles les objets déjà
  chiffrés ; MinIO ne les re-chiffre pas. Une vraie rotation impose de migrer
  vers [KES](https://github.com/minio/minio/blob/master/docs/kms/README.md),
  qui gère plusieurs clés et un backend externe (Vault, AWS-KMS).
- **Une seule clé.** Le KMS interne n'accepte qu'une paire `nom:clé`. Pour
  cloisonner plusieurs environnements avec des clés distinctes, il faut KES ou
  une instance par environnement.
- **La clé est visible via `docker inspect`.** Elle est passée en variable
  d'environnement : quiconque a accès au socket Docker y a accès. C'est inhérent
  au KMS interne.

## Notes

Le healthcheck de `compose.encrypted.yml` utilise `mc ready local` plutôt que
`curl` : `curl` n'est plus présent dans les images MinIO récentes, alors que
`mc` y est embarqué avec un alias `local` prédéfini.
