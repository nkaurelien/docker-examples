#!/usr/bin/env bash
# Genere .env pour compose.encrypted.yml (cle maitre KMS + mot de passe root).
# N'ecrase jamais un .env existant : remplacer la cle maitre rendrait
# illisibles les objets deja chiffres par l'instance en place.
set -euo pipefail
cd "$(dirname "$0")"

if [ -f .env ]; then
  echo "⚠  .env existe deja — non modifie."
  grep -q '^MINIO_KMS_KEY=' .env \
    && echo "   MINIO_KMS_KEY est deja renseigne, rien a faire." \
    || echo "   MINIO_KMS_KEY manque : l'ajouter a la main avec"
  grep -q '^MINIO_KMS_KEY=' .env || echo "   head -c 32 /dev/urandom | base64"
  exit 0
fi

# 32 octets = 256 bits, la taille attendue par MinIO. base64 -> 44 caracteres.
KMS_KEY=$(head -c 32 /dev/urandom | base64)
ROOT_PASSWORD=$(head -c 24 /dev/urandom | base64 | tr -d '\n=+/')

sed -e "s|^MINIO_KMS_KEY=.*|MINIO_KMS_KEY=${KMS_KEY}|" \
    -e "s|^MINIO_ROOT_PASSWORD=.*|MINIO_ROOT_PASSWORD=${ROOT_PASSWORD}|" \
    .env.example > .env
chmod 600 .env

echo "✅ .env cree (chmod 600)"
echo "   cle maitre : 32 octets, $(printf %s "$KMS_KEY" | wc -c | tr -d ' ') caracteres base64"
echo ""
echo "⚠  SAUVEGARDER .env HORS DE CE DOSSIER."
echo "   Perdre MINIO_KMS_KEY = objets et configuration IAM illisibles,"
echo "   definitivement. MinIO ne permet pas de rotation en place."
