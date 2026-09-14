# Umami Web Analytics Stack

[Umami](https://umami.is/) is an open-source, privacy-focused, cookie-free web analytics platform designed as an alternative to Google Analytics.

## Hostnames & Access

- Main URL: `https://umami.kamitbrains.fr`
- Alias URL: `https://analytics.kamitbrains.fr`
- Default Login: `admin`

## Architecture & Automated Init

- **Umami Web Application**: `ghcr.io/umami-software/umami:postgresql-latest` running on port 3000.
- **Database**: `postgres:16-alpine` (`umami-db`) storing website traffic events and configuration.
- **Init Container**: `umami-init` (`postgres:16-alpine`), a lightweight init service that automatically seeds configured websites (such as `Personal Portfolio` - `nkaurelien.kamitbrains.fr`) directly into PostgreSQL before the main web application starts.
- **Reverse Proxy**: Traefik with TLS certificate termination and CrowdSec rate-limiting / security protection.

## Deployment with Ansible

```bash
ansible-playbook -i ansible/inventory.yml ansible/site.yml --tags umami
```
