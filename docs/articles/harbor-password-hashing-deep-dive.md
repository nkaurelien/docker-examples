# Demystifying Harbor Password Hashing & Authentication: PBKDF2, PostgreSQL Salts, and Migration Traps

*By nkaurelien — Technical Deep-Dive & Incident Post-Mortem*

---

## Executive Summary

When managing enterprise artifact registries like **goharbor/harbor**, administrators frequently encounter subtle authentication pitfalls during password rotation, schema upgrades, or cluster migrations. A common symptom is receiving `401 Unauthorized` / `"Invalid user name or password"` even after updating configuration files (`harbor.yml` or Helm `--set harborAdminPassword=...`).

This article explores the internal Go architecture of Harbor core authentication, how PostgreSQL user tables evolve across versions, why simple SQL `UPDATE` queries fail, and how to safely manage or reset Harbor credentials.

---

## 1. How Harbor Stores & Verifies Passwords

Unlike simpler applications that rely on plain SHA-256 or MD5 hashes, Harbor uses a salted Key Derivation Function: **PBKDF2-HMAC-SHA256**.

### The `harbor_user` Schema

In Harbor’s PostgreSQL `registry` database, credentials are stored in the `harbor_user` table:

```sql
SELECT user_id, username, password, salt, password_version FROM harbor_user WHERE user_id = 1;
```

Sample output from a modern Harbor instance:

| `user_id` | `username` | `password` (Hex String) | `salt` (Random 32-char ASCII) | `password_version` |
| :--- | :--- | :--- | :--- | :--- |
| `1` | `admin` | `872ee3a8b41b9bc42b5b7cc5b85b7b8f` | `Uzl97ZzBps67Q1etRoDZXVwEyAYoiI39` | `sha256` |

### Key Derivation Details

- **Algorithm**: `PBKDF2` using `HMAC-SHA256`
- **Iterations**: `4096`
- **Derived Key Length**: `16 bytes` (rendered as `32 hexadecimal characters`)

In Python notation:
```python
import hashlib

salt = "Uzl97ZzBps67Q1etRoDZXVwEyAYoiI39"
password = "1Q2f316jbcXE2drG94z0qlE4"

derived_hash = hashlib.pbkdf2_hmac('sha256', password.encode(), salt.encode(), 4096, 16).hex()
# Result: '872ee3a8b41b9bc42b5b7cc5b85b7b8f'
```

---

## 2. The Configuration Override Trap: Why `harbor.yml` Changes Are Ignored

A common mistake is editing `harbor_admin_password` in `harbor.yml` or passing `--set harborAdminPassword=...` to Helm and expecting existing Harbor deployments to pick up the new password upon restart.

### Go Core Initialization Logic (`core/main.go`)

Upon container startup, `harbor-core` executes an initialization check:

```go
if user.PasswordVersion != "" && user.Password != "" {
    log.Infof("User id: %d already has its encrypted password.", user.UserID)
    log.Warningf("Admin password from config (HARBOR_ADMIN_PASSWORD) ignored: password already exists in database.")
} else {
    // Encrypt HARBOR_ADMIN_PASSWORD and save to PostgreSQL
    EncryptAndSaveAdminPassword(configAdminPassword)
    log.Infof("User id: %d updated its encrypted password successfully.", user.UserID)
}
```

> **Key Takeaway**: If `harbor_user` already contains a non-empty `password` or `password_version`, Harbor **deliberately ignores** the environment variable `HARBOR_ADMIN_PASSWORD`.

---

## 3. The SQL Reset Procedure: The Right Way

Attempting a naive SQL update such as `UPDATE harbor_user SET password = 'my_raw_password'` fails because Harbor compares incoming plaintext passwords against stored PBKDF2 hashes.

To force Harbor core to re-read and re-encrypt the configured `HARBOR_ADMIN_PASSWORD` from your deployment files, you must **clear the password fields entirely**:

### Docker Compose Reset Procedure

```bash
# 1. Clear salt, password, and password_version in PostgreSQL
docker exec harbor-db psql -U postgres -d registry -c "UPDATE harbor_user SET salt='', password='', password_version='' WHERE user_id = 1;"

# 2. Clear Redis authentication lock cache
docker exec redis redis-cli flushall

# 3. Restart Harbor Core to trigger re-encryption
cd /opt/harbor && docker compose restart core
```

### Kubernetes (K3s / Helm) Reset Procedure

```bash
# 1. Clear database credentials in the database pod
kubectl exec -n code-management harbor-database-0 -- psql -U postgres -d registry -c "UPDATE harbor_user SET salt='', password='', password_version='' WHERE user_id = 1;"

# 2. Rollout restart harbor-core
kubectl rollout restart deployment harbor-core -n code-management
```

When `harbor-core` boots up, it detects `password == ''`, logs `"User id: 1 updated its encrypted password successfully."`, and writes the new PBKDF2 hash to the database.

---

## 4. Conclusion & Best Practices

1. **Never commit passwords to Git repositories**: Use gitignored local files (`.secrets/harbor-admin-password`) or external vaults (HashiCorp Vault / Infisical).
2. **Use API for runtime password changes**: Use `PUT /api/v2.0/users/1/password` for programmatic updates.
3. **Understand the cache layer**: Always flush Redis (`redis-cli flushall`) after resetting database credentials to remove lingering brute-force lockouts.
