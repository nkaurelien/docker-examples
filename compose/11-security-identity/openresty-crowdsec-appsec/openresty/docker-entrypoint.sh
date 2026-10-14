#!/bin/sh
# Génère la config du bouncer CrowdSec à partir de l'environnement puis lance OpenResty.
set -eu

: "${CROWDSEC_BOUNCER_KEY:?CROWDSEC_BOUNCER_KEY manquant}"
: "${CROWDSEC_LAPI_URL:=http://crowdsec:8080}"
: "${CROWDSEC_APPSEC_URL:=http://crowdsec:7422}"

CONF=/etc/crowdsec/bouncers/crowdsec-openresty-bouncer.conf
umask 077
cat > "$CONF" <<CONF
ENABLED=true
API_URL=${CROWDSEC_LAPI_URL}
API_KEY=${CROWDSEC_BOUNCER_KEY}
MODE=stream
UPDATE_FREQUENCY=10
REQUEST_TIMEOUT=3000
BOUNCING_ON_TYPE=all
FALLBACK_REMEDIATION=ban
BAN_TEMPLATE_PATH=/var/lib/crowdsec/lua/templates/ban.html
CAPTCHA_TEMPLATE_PATH=/var/lib/crowdsec/lua/templates/captcha.html
APPSEC_URL=${CROWDSEC_APPSEC_URL}
APPSEC_FAILURE_ACTION=passthrough
CONF

exec "$@"
