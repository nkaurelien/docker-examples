# Passbolt Team Password Manager

- **Public URL**: `https://passwords.kamitbrains.fr`
- **Database Engine**: PostgreSQL 16 Alpine (`postgres:16-alpine`)
- **Admin Login File**: `.secrets/passbolt-admin-login`
- **Admin Password File**: `.secrets/passbolt-admin-password`
- **DB Password File**: `.secrets/passbolt-db-password`
- **GPG Passphrase File**: `.secrets/passbolt-passphrase`

## Activation Link & Logs

To retrieve the initial activation link at any time:

1. **Via Arcane UI**: Open [https://arcane.kamitbrains.fr](https://arcane.kamitbrains.fr), navigate to **Conteneurs > passbolt-init > Journaux**.
2. **Via Docker CLI**:
   ```bash
   docker logs passbolt-init
   ```
