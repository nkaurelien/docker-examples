#!/bin/bash
# Init script executed by the init-ldap container using Docker Secrets

LDAP_HOST="openldap"
ADMIN_DN="cn=admin,${LDAP_BASE_DN}"
CONFIG_DN="cn=admin,cn=config"

# Read passwords from mounted Docker Compose secrets (/run/secrets/*)
SECRETS_DIR="/run/secrets"
read_secret() {
  local value
  value=$(cat "${SECRETS_DIR}/$1" 2>/dev/null)
  if [ -z "$value" ]; then
    echo "ERROR: secret '$1' is missing or empty in ${SECRETS_DIR}" >&2
    exit 1
  fi
  printf '%s' "$value"
}
ADMIN_PASSWORD=$(read_secret ldap_admin_password) || exit 1
CONFIG_PASSWORD=$(read_secret ldap_config_password) || exit 1
AURELIEN_RAW=$(read_secret user_aurelien_password) || exit 1
IDRISS_RAW=$(read_secret user_idriss_password) || exit 1
MICHEL_RAW=$(read_secret user_michel_password) || exit 1

# Run an ldap command, treating "already exists" results as success so re-runs are idempotent
# (68 = entry already exists, 20 = attribute/value already exists)
FAILED=0
ldap() {
  "$@"
  local rc=$?
  case $rc in
    0|20|68) ;;
    *) FAILED=1 ;;
  esac
}

echo "1. Creating Organizational Units (OUs)..."
ldap ldapadd -c -x -H ldap://$LDAP_HOST -w "$ADMIN_PASSWORD" -D "$ADMIN_DN" << EOF
dn: ou=devops,${LDAP_BASE_DN}
objectClass: organizationalUnit
ou: devops

dn: ou=appdev,${LDAP_BASE_DN}
objectClass: organizationalUnit
ou: appdev
EOF

echo "2. Generating SSHA password hashes from secrets..."
AURELIEN_HASH=$(slappasswd -s "$AURELIEN_RAW")
IDRISS_HASH=$(slappasswd -s "$IDRISS_RAW")
MICHEL_HASH=$(slappasswd -s "$MICHEL_RAW")

echo "3. Creating User Accounts..."
ldap ldapadd -c -x -H ldap://$LDAP_HOST -w "$ADMIN_PASSWORD" -D "$ADMIN_DN" << EOF
dn: cn=aurelien,ou=devops,${LDAP_BASE_DN}
objectClass: inetOrgPerson
cn: aurelien
sn: Nkumbe
uid: nkaurelien
userPassword: $AURELIEN_HASH

dn: cn=idriss,ou=appdev,${LDAP_BASE_DN}
objectClass: inetOrgPerson
cn: idriss
sn: Ngouen
uid: nnid
userPassword: $IDRISS_HASH

dn: cn=michel,ou=appdev,${LDAP_BASE_DN}
objectClass: inetOrgPerson
cn: michel
sn: Tchokouani
uid: edmich
userPassword: $MICHEL_HASH
EOF

echo "4. Configuring memberOf overlay for groupOfNames/member..."
# osixia defaults the overlay to groupOfUniqueNames/uniqueMember; must run before groups are created
ldap ldapmodify -c -x -H ldap://$LDAP_HOST -w "$CONFIG_PASSWORD" -D "$CONFIG_DN" << EOF
dn: olcOverlay={0}memberof,olcDatabase={1}mdb,cn=config
changetype: modify
replace: olcMemberOfGroupOC
olcMemberOfGroupOC: groupOfNames
-
replace: olcMemberOfMemberAD
olcMemberOfMemberAD: member
EOF

echo "5. Creating Groups (memberOf is maintained automatically by the overlay)..."
ldap ldapadd -c -x -H ldap://$LDAP_HOST -w "$ADMIN_PASSWORD" -D "$ADMIN_DN" << EOF
dn: cn=appdev-team,${LDAP_BASE_DN}
objectClass: top
objectClass: groupOfNames
cn: appdev-team
description: App Development Team
member: cn=aurelien,ou=devops,${LDAP_BASE_DN}
member: cn=idriss,ou=appdev,${LDAP_BASE_DN}

dn: cn=devops-team,${LDAP_BASE_DN}
objectClass: top
objectClass: groupOfNames
cn: devops-team
description: DevOps Team
member: cn=aurelien,ou=devops,${LDAP_BASE_DN}
member: cn=michel,ou=appdev,${LDAP_BASE_DN}
EOF

echo "6. Granting Read Access to user aurelien..."
ldap ldapmodify -c -x -H ldap://$LDAP_HOST -w "$CONFIG_PASSWORD" -D "$CONFIG_DN" << EOF
dn: olcDatabase={1}mdb,cn=config
changetype: modify
add: olcAccess
olcAccess: {2}to * by dn="cn=aurelien,ou=devops,${LDAP_BASE_DN}" read
EOF

echo "7. Enabling and Configuring PPolicy Overlay..."
# Load ppolicy module into cn=module{0},cn=config
ldap ldapmodify -c -x -H ldap://$LDAP_HOST -w "$CONFIG_PASSWORD" -D "$CONFIG_DN" << EOF
dn: cn=module{0},cn=config
changetype: modify
add: olcModuleLoad
olcModuleLoad: ppolicy
EOF

# Attach ppolicy overlay to the mdb database (skipped if already attached: slapd returns 80, not 68)
if ldapsearch -x -LLL -H ldap://$LDAP_HOST -w "$CONFIG_PASSWORD" -D "$CONFIG_DN" \
    -b "olcDatabase={1}mdb,cn=config" -s one "(objectClass=olcPPolicyConfig)" dn | grep -q '^dn:'; then
  echo "ppolicy overlay already attached, skipping."
else
ldap ldapadd -c -x -H ldap://$LDAP_HOST -w "$CONFIG_PASSWORD" -D "$CONFIG_DN" << EOF
dn: olcOverlay=ppolicy,olcDatabase={1}mdb,cn=config
objectClass: olcOverlayConfig
objectClass: olcPPolicyConfig
olcOverlay: ppolicy
olcPPolicyDefault: cn=default,ou=policies,${LDAP_BASE_DN}
olcPPolicyUseLockout: TRUE
olcPPolicyHashCleartext: TRUE
EOF
fi

echo "8. Creating Default Password Policy..."
# Create ou=policies container
ldap ldapadd -c -x -H ldap://$LDAP_HOST -w "$ADMIN_PASSWORD" -D "$ADMIN_DN" << EOF
dn: ou=policies,${LDAP_BASE_DN}
objectClass: organizationalUnit
ou: policies
EOF

# Define default security policy (min length 8 enforced via pwdCheckQuality, lockout after 5 failures for 15 mins)
ldap ldapadd -c -x -H ldap://$LDAP_HOST -w "$ADMIN_PASSWORD" -D "$ADMIN_DN" << EOF
dn: cn=default,ou=policies,${LDAP_BASE_DN}
objectClass: top
objectClass: device
objectClass: pwdPolicy
cn: default
pwdAttribute: userPassword
pwdCheckQuality: 1
pwdMinLength: 8
pwdMaxFailure: 5
pwdLockout: TRUE
pwdLockoutDuration: 900
pwdFailureCountInterval: 900
pwdMustChange: FALSE
pwdAllowUserChange: TRUE
pwdSafeModify: FALSE
EOF

if [ "$FAILED" -ne 0 ]; then
  echo "Initialization finished with errors; check the output above." >&2
  exit 1
fi
echo "Initialization complete!"
