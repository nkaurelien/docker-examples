#!/usr/bin/env bash
# POC S3 RustFS — smoke test de l'API S3 via AWS CLI.
# Prérequis : awscli. Aucune config globale requise (creds inline).
#   ./test-s3.sh
set -euo pipefail

ENDPOINT="${ENDPOINT:-http://localhost:9000}"
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID:-asone_poc_access}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY:-asone_poc_secret_change_me}"
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"
BUCKET="${BUCKET:-asone-attachments}"

s3() { aws --endpoint-url "$ENDPOINT" "$@"; }

echo "== endpoint: $ENDPOINT  bucket: $BUCKET =="
echo "1) mb (create bucket)";   s3 s3 mb "s3://$BUCKET" 2>/dev/null || echo "   (existe déjà)"
echo "2) cp (put object)";      printf 'hello rustfs %s\n' "$(date)" > /tmp/poc-rustfs.txt; s3 s3 cp /tmp/poc-rustfs.txt "s3://$BUCKET/poc.txt"
echo "3) ls (list)";            s3 s3 ls "s3://$BUCKET/"
echo "4) cp (get object)";      s3 s3 cp "s3://$BUCKET/poc.txt" /tmp/poc-rustfs-get.txt && echo "   contenu: $(cat /tmp/poc-rustfs-get.txt)"
echo "5) presign (URL signée)"; s3 s3 presign "s3://$BUCKET/poc.txt" || echo "   (presign non supporté)"
echo "6) rm (delete)";          s3 s3 rm "s3://$BUCKET/poc.txt"
echo "== OK =="
