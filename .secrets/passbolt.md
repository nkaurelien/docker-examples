# Passbolt Team Password Manager

- **Public URL**: `https://passwords.kamitbrains.fr`
- **Database Engine**: PostgreSQL 16 Alpine (`postgres:16-alpine`)
- **Admin Email**: `admin@kamitbrains.fr`

## Activation Link & Logs

To retrieve the initial activation link at any time:

1. **Via Arcane UI**: Open [https://arcane.kamitbrains.fr](https://arcane.kamitbrains.fr), navigate to **Conteneurs > passbolt-init > Journaux**.
2. **Via Docker CLI**:
   ```bash
   docker logs passbolt-init
   ```
