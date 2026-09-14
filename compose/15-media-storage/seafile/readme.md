# Seafile Enterprise File Sync & Share Stack

[Seafile](https://www.seafile.com/) is an open-source, high-performance file sync and share solution with encryption, library organization, and team collaboration capabilities.

## Hostnames & Access

- Main URL: `https://seafile.kamitbrains.fr`
- Alias URL: `https://drive.kamitbrains.fr`
- Admin Email: `admin@kamitbrains.fr`

## Architecture

- **Seafile Server & Seahub UI**: `seafileltd/seafile-mc:latest`
- **Database**: `mariadb:10.11` (`seafile-db`)
- **Cache**: `memcached:1.6-alpine` (`seafile-memcached`)
- **Reverse Proxy Protection**: Traefik TLS + CrowdSec Bouncer

## Deployment with Ansible

```bash
ansible-playbook -i ansible/inventory.yml ansible/site.yml --tags seafile
```
