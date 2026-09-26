#!/bin/bash
# Init script executed by the init-ldap container

LDAP_HOST="openldap"
# The base DN and password are provided via environment variables in docker-compose.yml
ADMIN_DN="cn=admin,${LDAP_BASE_DN}"
CONFIG_DN="cn=admin,cn=config"

echo "1. Creating Organizational Units (OUs)..."
ldapadd -x -H ldap://$LDAP_HOST -w "$LDAP_ADMIN_PASSWORD" -D "$ADMIN_DN" << EOF
dn: ou=devops,${LDAP_BASE_DN}
objectClass: organizationalUnit
ou: devops

dn: ou=appdev,${LDAP_BASE_DN}
objectClass: organizationalUnit
ou: appdev
EOF

echo "2. Generating SSHA password hashes..."
AURELIEN_HASH=$(slappasswd -s "Aurelien@123")
IDRISS_HASH=$(slappasswd -s "Idriss@123")
MICHEL_HASH=$(slappasswd -s "Michel@123")

echo "3. Creating User Accounts..."
ldapadd -x -H ldap://$LDAP_HOST -w "$LDAP_ADMIN_PASSWORD" -D "$ADMIN_DN" << EOF
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
ldapadd -x -H ldap://$LDAP_HOST -w "$LDAP_ADMIN_PASSWORD" -D "$ADMIN_DN" << EOF
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
ldapadd -x -H ldap://$LDAP_HOST -w "$LDAP_ADMIN_PASSWORD" -D "$ADMIN_DN" << EOF
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
ldapmodify -x -H ldap://$LDAP_HOST -w "$LDAP_ADMIN_PASSWORD" -D "$CONFIG_DN" << EOF
dn: olcDatabase={1}mdb,cn=config
changetype: modify
add: olcAccess
olcAccess: {2}to * by dn="cn=aurelien,ou=devops,${LDAP_BASE_DN}" read
EOF

echo "Initialization complete!"
