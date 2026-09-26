# OpenLDAP + phpLDAPadmin

This stack provides an **OpenLDAP** directory server alongside **phpLDAPadmin**, a web-based GUI for managing LDAP entries.

## Quick Start

1. Start the stack:
   ```bash
   cp .env.example .env
   cp -r .secrets.example .secrets
   docker compose up -d
   ```

2. Access **phpLDAPadmin**:
   - URL: `http://localhost:8088`

   > ⚠️ **Note:** phpLDAPadmin requires the full **Login DN**, not just a username.

   - **Admin Login:**
     - **Login DN:** `cn=admin,dc=kamitbrains,dc=local` (or your configured `LDAP_BASE_DN`)
     - **Password:** `password`
   - **User Login (e.g. Aurelien):**
     - **Login DN:** `cn=aurelien,ou=devops,dc=kamitbrains,dc=local`
     - **Password:** `Aurelien@123`
     *(In services querying via `uid` like Nextcloud, Keycloak, etc., use `nkaurelien`).*

## Auto-initialization

When you launch `docker compose up -d`, a temporary `init-ldap` container is automatically started.
It waits for OpenLDAP to be healthy and then runs `scripts/init.sh` to automatically populate the database with:

1. **OUs**: `ou=devops` and `ou=appdev`.
2. **Users**: `nkaurelien` (devops), `idriss` (appdev) and `michel` (appdev).
3. **Groups**: `appdev-team` and `devops-team`.
4. **MemberOf**: Associates users with these groups.
5. **ACLs**: Grants read access to the user `nkaurelien`.

### Verifying access
You can verify that the user `nkaurelien` has access by running an LDAP search from your host (if you have ldap-utils installed) or from inside the container:
```bash
docker exec -it openldap ldapsearch -x -D "cn=aurelien,ou=devops,dc=kamitbrains,dc=local" -w Aurelien@123 -b "dc=kamitbrains,dc=local"
```

## Directory Structure & LDAP Objects

```text
dc=kamitbrains,dc=local (Domain Root / Base DN)
 │
 ├── cn=appdev-team        [groupOfNames]
 ├── cn=devops-team        [groupOfNames]
 │
 ├── ou=devops             [organizationalUnit]
 │    └── cn=aurelien      [inetOrgPerson] (uid: nkaurelien)
 │
 └── ou=appdev             [organizationalUnit]
      ├── cn=idriss        [inetOrgPerson] (uid: nnid)
      └── cn=michel        [inetOrgPerson] (uid: edmich)
```

### Key LDAP Concepts:
- **`dcObject` / `organization`**: The root of your directory tree (Base DN).
- **`organizationalUnit` (OU)**: Folder-like container used to organize entries logically.
- **`inetOrgPerson`**: Standard object class representing a human user (supports `cn`, `sn`, `uid`, `mail`, `userPassword`).
- **`groupOfNames`**: Group containing references to its members (`member: <full DN>`).
- **`memberOf`**: Reverse-membership attribute assigned to users for quick group-based access control checks.

## Security & Hardening

### 1. Password Hashing ({SSHA})
Passwords are **never stored in cleartext**. The bootstrap script dynamically hashes user passwords with `slappasswd` using salted SHA-1 (`{SSHA}`) before inserting them into the LDAP directory:
- Generated value format: `{SSHA}hSJamTTdc8MudXG9O2Bw5pq6uifvPrdC`
- Password verification is performed by matching the salt and hash, keeping cleartext credentials confidential.

### 2. Privilege Separation (Dual Secret Architecture)
Two distinct administrator passwords are configured via **Docker Compose Secrets**:
- **`ldap_admin_password`** (`cn=admin,dc=kamitbrains,dc=local`): Directory administrator (manages users, OUs, and groups).
- **`ldap_config_password`** (`cn=admin,cn=config`): Low-level OpenLDAP engine administrator (schemas, modules, ACLs).

This prevents directory data managers from modifying the server's runtime configuration.

### 3. Password Policy Overlay (`ppolicy`) & Brute-force Protection
The OpenLDAP **`ppolicy`** overlay is enabled and enforced globally (`cn=default,ou=policies,dc=kamitbrains,dc=local`):
- **Minimum Password Length (`pwdMinLength`)**: 8 characters.
- **Account Lockout (`pwdLockout`)**: Enabled (`TRUE`).
- **Max Failed Attempts (`pwdMaxFailure`)**: 5 failed login attempts.
- **Lockout Duration (`pwdLockoutDuration`)**: 900 seconds (15 minutes).
- **Auto-Hashing (`olcPPolicyHashCleartext`)**: Automatically converts cleartext password modifications to secure hashes.
