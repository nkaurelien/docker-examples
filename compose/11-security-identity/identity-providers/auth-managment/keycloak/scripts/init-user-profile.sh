#!/bin/sh
# =============================================================================
# Keycloak User Profile Initialization
# =============================================================================
# Configures custom User Profile attributes after Keycloak starts.
# Required because Keycloak 24+ doesn't support userProfile in realm JSON.
#
# Environment variables:
#   KEYCLOAK_URL            - Keycloak base URL (default: http://keycloak:8080)
#   KEYCLOAK_REALM          - Realm name (default: my-realm)
#   KEYCLOAK_ADMIN          - Admin username (default: admin)
#   KEYCLOAK_ADMIN_PASSWORD - Admin password
# =============================================================================

set -e

KEYCLOAK_URL="${KEYCLOAK_URL:-http://keycloak:8080}"
REALM="${KEYCLOAK_REALM:-my-realm}"
ADMIN_USER="${KEYCLOAK_ADMIN:-admin}"
ADMIN_PASSWORD="${KEYCLOAK_ADMIN_PASSWORD:-admin}"

echo "=== Keycloak User Profile Initialization ==="
echo "URL:   ${KEYCLOAK_URL}"
echo "Realm: ${REALM}"

# Wait for Keycloak
echo "Waiting for Keycloak..."
sleep 10
ATTEMPTS=0
while [ $ATTEMPTS -lt 30 ]; do
  if curl -sf "${KEYCLOAK_URL}/health/ready" > /dev/null 2>&1; then
    echo "Keycloak is ready."
    break
  fi
  ATTEMPTS=$((ATTEMPTS + 1))
  sleep 5
done

# Get admin token
echo "Getting admin token..."
TOKEN_RESPONSE=$(curl -sf -X POST "${KEYCLOAK_URL}/realms/master/protocol/openid-connect/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "grant_type=password" \
  -d "client_id=admin-cli" \
  -d "username=${ADMIN_USER}" \
  -d "password=${ADMIN_PASSWORD}")

ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | sed -n 's/.*"access_token":"\([^"]*\)".*/\1/p')

if [ -z "$ACCESS_TOKEN" ]; then
  echo "ERROR: Failed to get admin token"
  exit 1
fi
echo "Token obtained."

# Configure User Profile
echo "Configuring User Profile..."
RESULT=$(curl -s -w "\n%{http_code}" -X PUT \
  "${KEYCLOAK_URL}/admin/realms/${REALM}/users/profile" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "attributes": [
      {
        "name": "username",
        "displayName": "${username}",
        "validations": {"length": {"min": 3, "max": 255}},
        "permissions": {"view": ["admin", "user"], "edit": ["admin", "user"]},
        "multivalued": false
      },
      {
        "name": "email",
        "displayName": "${email}",
        "validations": {"email": {}, "length": {"max": 255}},
        "required": {"roles": ["user"]},
        "permissions": {"view": ["admin", "user"], "edit": ["admin", "user"]},
        "multivalued": false
      },
      {
        "name": "firstName",
        "displayName": "${firstName}",
        "validations": {"length": {"max": 255}},
        "required": {"roles": ["user"]},
        "permissions": {"view": ["admin", "user"], "edit": ["admin", "user"]},
        "multivalued": false
      },
      {
        "name": "lastName",
        "displayName": "${lastName}",
        "validations": {"length": {"max": 255}},
        "required": {"roles": ["user"]},
        "permissions": {"view": ["admin", "user"], "edit": ["admin", "user"]},
        "multivalued": false
      },
      {
        "name": "external_user_id",
        "displayName": "External User ID",
        "permissions": {"view": ["admin"], "edit": ["admin"]},
        "multivalued": false
      },
      {
        "name": "user_type",
        "displayName": "User Type",
        "permissions": {"view": ["admin"], "edit": ["admin"]},
        "multivalued": false
      },
      {
        "name": "phoneNumber",
        "displayName": "Phone Number",
        "permissions": {"view": ["admin", "user"], "edit": ["admin", "user"]},
        "multivalued": false
      }
    ],
    "groups": [
      {
        "name": "user-metadata",
        "displayHeader": "User metadata",
        "displayDescription": "Custom user attributes"
      }
    ]
  }')

STATUS_CODE=$(echo "$RESULT" | tail -n1)

if [ "$STATUS_CODE" = "200" ] || [ "$STATUS_CODE" = "204" ]; then
  echo "SUCCESS: User Profile configured (status: ${STATUS_CODE})"
else
  echo "WARNING: User Profile returned status ${STATUS_CODE}"
fi

echo "=== Initialization complete ==="
