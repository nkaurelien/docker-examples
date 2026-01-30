# Gitea

Gitea is a painless, self-hosted, all-in-one software development service.

## Features

- Git repository hosting
- Code review (Pull Requests)
- Issue tracking
- Gitea Actions (CI/CD)
- Package registry
- Wiki
- Organizations and teams
- LDAP/OAuth2 authentication

## Quick Start

```bash
cd 08-code-management/gitea
docker compose up -d
```

Access at: `http://localhost:3000`

## Stack

- Gitea (Git hosting)
- PostgreSQL (database)
- Gitea Runner (CI/CD, optional)

## Resources

- [Official Documentation](https://docs.gitea.com/)
- [GitHub](https://github.com/go-gitea/gitea)
