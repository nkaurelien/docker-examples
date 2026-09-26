#!/bin/bash
# Init script executed by the init-ldap container using Docker Secrets

LDAP_HOST="openldap"
ADMIN_DN="cn=admin,${LDAP_BASE_DN}"
CONFIG_DN="cn=admin,cn=config"

# Read passwords from mounted Docker Compose secrets (/run/secrets/*)
SECRETS_DIR="/run/secrets"
ADMIN_PASSWORD=$(cat "${SECRETS_DIR}/ldap_admin_password")
CONFIG_PASSWORD=$(cat "${SECRETS_DIR}/ldap_config_password")
AURELIEN_RAW=$(cat "${SECRETS_DIR}/user_aurelien_password")
IDRISS_RAW=$(cat "${SECRETS_DIR}/user_idriss_password")
MICHEL_RAW=$(cat "${SECRETS_DIR}/user_michel_password")

echo "1. Creating Organizational Units (OUs)..."
ldapadd -x -H ldap://$LDAP_HOST -w "$ADMIN_PASSWORD" -D "$ADMIN_DN" << EOF
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
ldapadd -x -H ldap://$LDAP_HOST -w "$ADMIN_PASSWORD" -D "$ADMIN_DN" << EOF
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

echo "4. Creating Groups..."
ldapadd -x -H ldap://$LDAP_HOST -w "$ADMIN_PASSWORD" -D "$ADMIN_DN" << EOF
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

echo "5. Modifying MemberOf Attributes..."
ldapadd -x -H ldap://$LDAP_HOST -w "$ADMIN_PASSWORD" -D "$ADMIN_DN" << EOF
dn: cn=aurelien,ou=devops,${LDAP_BASE_DN}
changetype: modify
add: memberOf
memberOf: cn=devops-team,${LDAP_BASE_DN}

dn: cn=michel,ou=appdev,${LDAP_BASE_DN}
changetype: modify
add: memberOf
memberOf: cn=appdev-team,${LDAP_BASE_DN}

dn: cn=idriss,ou=appdev,${LDAP_BASE_DN}
changetype: modify
add: memberOf
memberOf: cn=devops-team,${LDAP_BASE_DN}
EOF

echo "6. Granting Read Access to user aurelien..."
ldapmodify -x -H ldap://$LDAP_HOST -w "$CONFIG_PASSWORD" -D "$CONFIG_DN" << EOF
dn: olcDatabase={1}mdb,cn=config
changetype: modify
add: olcAccess
olcAccess: {2}to * by dn="cn=aurelien,ou=devops,${LDAP_BASE_DN}" read
EOF

echo "7. Enabling and Configuring PPolicy Overlay..."
# Load ppolicy module into cn=module{0},cn=config
ldapmodify -x -H ldap://$LDAP_HOST -w "$CONFIG_PASSWORD" -D "$CONFIG_DN" << EOF
dn: cn=module{0},cn=config
changetype: modify
add: olcModuleLoad
olcModuleLoad: ppolicy
EOF

# Attach ppolicy overlay to the mdb database
ldapadd -x -H ldap://$LDAP_HOST -w "$CONFIG_PASSWORD" -D "$CONFIG_DN" << EOF
dn: olcOverlay=ppolicy,olcDatabase={1}mdb,cn=config
objectClass: olcOverlayConfig
objectClass: olcPPolicyConfig
olcOverlay: ppolicy
olcPPolicyDefault: cn=default,ou=policies,${LDAP_BASE_DN}
olcPPolicyUseLockout: TRUE
olcPPolicyHashCleartext: TRUE
EOF

echo "8. Creating Default Password Policy..."
# Create ou=policies container
ldapadd -x -H ldap://$LDAP_HOST -w "$ADMIN_PASSWORD" -D "$ADMIN_DN" << EOF
dn: ou=policies,${LDAP_BASE_DN}
objectClass: organizationalUnit
ou: policies
EOF

# Define default security policy (min length 8, lockout after 5 failures for 15 mins)
ldapadd -x -H ldap://$LDAP_HOST -w "$ADMIN_PASSWORD" -D "$ADMIN_DN" << EOF
dn: cn=default,ou=policies,${LDAP_BASE_DN}
objectClass: top
objectClass: device
objectClass: pwdPolicy
cn: default
pwdAttribute: userPassword
pwdMinLength: 8
pwdMaxFailure: 5
pwdLockout: TRUE
pwdLockoutDuration: 900
pwdFailureCountInterval: 900
pwdMustChange: FALSE
pwdAllowUserChange: TRUE
pwdSafeModify: FALSE
EOF

echo "Initialization complete!"
