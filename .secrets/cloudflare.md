# Cloudflare API Credentials & Configuration

- **Account ID File**: `.secrets/cloudflare-account-id`
- **API Key File**: `.secrets/cloudflare-api-key`

## Exemple d’utilisation

```sh
ACCOUNT_ID=$(cat .secrets/cloudflare-account-id)
API_KEY=$(cat .secrets/cloudflare-api-key)
curl -X GET "https://api.cloudflare.com/client/v4/accounts/${ACCOUNT_ID}/tokens/verify" \
     -H "Authorization: Bearer ${API_KEY}"
```
