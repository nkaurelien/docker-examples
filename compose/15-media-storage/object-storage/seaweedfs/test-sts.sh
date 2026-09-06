#!/usr/bin/env bash
# POC STS/OIDC — flux complet : JWT Keycloak → AssumeRoleWithWebIdentity → S3.
# Prérequis : awscli + jq. Variables (voir STS-KEYCLOAK.md) :
#   KC_USER / KC_PASS (compte de test KC), CLIENT_SECRET (si client confidentiel),
#   MKCERT_CA (rootCA.pem mkcert pour le TLS local).
set -euo pipefail

# charge le .env local (secrets POC : client secret, user/pass, MKCERT_CA) si présent
_D="$(cd "$(dirname "$0")" && pwd)"
[ -f "$_D/.env" ] && { set -a; . "$_D/.env"; set +a; }

KC="${KC:-https://connect.asone4health.kamitbrains.local}"
REALM="${REALM:-asone4health}"
CLIENT_ID="${CLIENT_ID:-seaweedfs-s3}"
CLIENT_SECRET="${CLIENT_SECRET:-}"
KC_USER="${KC_USER:?exporter KC_USER (compte de test Keycloak)}"
KC_PASS="${KC_PASS:?exporter KC_PASS}"
S3_ENDPOINT="${S3_ENDPOINT:-http://localhost:8333}"
ROLE_ARN="${ROLE_ARN:-arn:aws:iam::role/S3AttachmentsWriteRole}"
BUCKET="${BUCKET:-asone-attachments}"

echo "1) JWT Keycloak (realm=$REALM client=$CLIENT_ID user=$KC_USER)"
JWT=$(curl -sS ${MKCERT_CA:+--cacert "$MKCERT_CA"} \
  -X POST "$KC/realms/$REALM/protocol/openid-connect/token" \
  -d client_id="$CLIENT_ID" ${CLIENT_SECRET:+-d client_secret="$CLIENT_SECRET"} \
  -d grant_type=password -d username="$KC_USER" -d password="$KC_PASS" \
  -d scope=openid | jq -r .access_token)
[ -n "$JWT" ] && [ "$JWT" != "null" ] || { echo "❌ pas de JWT (client/user/realm ?)"; exit 1; }
echo "   ✅ JWT (len=${#JWT})"

echo "2) AssumeRoleWithWebIdentity → $ROLE_ARN"
CREDS=$(aws sts assume-role-with-web-identity \
  --role-arn "$ROLE_ARN" --role-session-name "poc-$(date +%s)" \
  --web-identity-token "$JWT" \
  --endpoint-url "$S3_ENDPOINT" --region us-east-1 --output json)
export AWS_ACCESS_KEY_ID=$(echo "$CREDS" | jq -r .Credentials.AccessKeyId)
export AWS_SECRET_ACCESS_KEY=$(echo "$CREDS" | jq -r .Credentials.SecretAccessKey)
export AWS_SESSION_TOKEN=$(echo "$CREDS" | jq -r .Credentials.SessionToken)
echo "   ✅ creds temporaires ${AWS_ACCESS_KEY_ID:0:8}… (sessionToken len=${#AWS_SESSION_TOKEN})"

s3() { aws --endpoint-url "$S3_ENDPOINT" --region us-east-1 "$@"; }
echo "3) S3 avec creds STS (bucket autorisé $BUCKET)"
s3 s3 mb "s3://$BUCKET" 2>/dev/null || echo "   (bucket existe)"
printf 'sts ok %s\n' "$(date)" > /tmp/poc-sts.txt
s3 s3 cp /tmp/poc-sts.txt "s3://$BUCKET/sts.txt"
s3 s3 ls "s3://$BUCKET/"

echo "4) isolation : écriture hors périmètre doit ÉCHOUER"
if s3 s3 mb "s3://bucket-interdit" 2>&1 | grep -qi "denied\|forbidden\|AccessDenied"; then
  echo "   ✅ refus attendu (policy scopée)"
else
  echo "   ⚠️ pas de refus — vérifier la policy préfixe"
fi
echo "== OK =="
