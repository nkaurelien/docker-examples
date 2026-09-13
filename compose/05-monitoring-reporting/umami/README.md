# Umami Web Analytics Stack

[Umami](https://umami.is/) is an open-source, privacy-focused, cookie-free web analytics platform designed as an alternative to Google Analytics.

## Hostnames & Access

- Main URL: `https://umami.kamitbrains.fr`
- Alias URL: `https://analytics.kamitbrains.fr`
- Default Login: `admin`
- Default Password: `umami` (Change immediately upon initial login)

## Architecture

- **Umami Web Application**: `ghcr.io/umami-software/umami:postgresql-latest` running on port 3000.
- **Database**: `postgres:16-alpine` storing website traffic events and configuration.
- **Reverse Proxy**: Traefik with TLS certificate termination and CrowdSec rate-limiting / security protection.

## Deployment with Ansible

```bash
ansible-playbook -i ansible/inventory.yml ansible/site.yml --tags umami
```
