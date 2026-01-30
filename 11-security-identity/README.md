# Security and Identity

Authentication, authorization, identity management, and security tools.

## Identity Providers

Authentication, SSO, and identity management.

### Existing Projects

- **identity-providers/auth-managment/** - Authentication solutions (Keycloak, Kratos, SuperTokens, Zitadel)

### Suggested Open Source Services

| Service | Description | GitHub |
|---------|-------------|--------|
| **Keycloak** | Identity and access management | [keycloak/keycloak](https://github.com/keycloak/keycloak) |
| **Authentik** | Identity provider | [goauthentik/authentik](https://github.com/goauthentik/authentik) |
| **Authelia** | Authentication server | [authelia/authelia](https://github.com/authelia/authelia) |
| **Ory Kratos** | Identity management | [ory/kratos](https://github.com/ory/kratos) |
| **Ory Hydra** | OAuth 2.0 server | [ory/hydra](https://github.com/ory/hydra) |
| **Zitadel** | Identity management platform | [zitadel/zitadel](https://github.com/zitadel/zitadel) |
| **SuperTokens** | Auth solution | [supertokens/supertokens-core](https://github.com/supertokens/supertokens-core) |
| **Casdoor** | Identity and SSO platform | [casdoor/casdoor](https://github.com/casdoor/casdoor) |
| **Dex** | OIDC identity provider | [dexidp/dex](https://github.com/dexidp/dex) |

---

## Security Tools

Secrets management, password managers, and security scanning.

### Existing Projects

- **security-tools/security/** - Security configurations

### Suggested Open Source Services

| Service | Description | GitHub |
|---------|-------------|--------|
| **Vault** | Secrets management | [hashicorp/vault](https://github.com/hashicorp/vault) |
| **Infisical** | Secret management | [Infisical/infisical](https://github.com/Infisical/infisical) |
| **Bitwarden/Vaultwarden** | Password manager | [dani-garcia/vaultwarden](https://github.com/dani-garcia/vaultwarden) |
| **Passbolt** | Team password manager | [passbolt/passbolt_api](https://github.com/passbolt/passbolt_api) |
| **CrowdSec** | Collaborative security | [crowdsecurity/crowdsec](https://github.com/crowdsecurity/crowdsec) |
| **Fail2ban** | Intrusion prevention | [fail2ban/fail2ban](https://github.com/fail2ban/fail2ban) |
| **Trivy** | Vulnerability scanner | [aquasecurity/trivy](https://github.com/aquasecurity/trivy) |
| **Clair** | Container vulnerability scanner | [quay/clair](https://github.com/quay/clair) |
| **Falco** | Runtime security | [falcosecurity/falco](https://github.com/falcosecurity/falco) |

---

## Quick Start

```bash
# Keycloak
cd identity-providers/auth-managment/keycloak/
docker compose up -d
```

Access Keycloak at `http://localhost:8080`.
