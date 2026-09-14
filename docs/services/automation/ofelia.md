---
tags: ofelia, scheduler, cron, docker, automation, socket-proxy
---

# Ofelia Job Scheduler

[Ofelia](https://github.com/mcuadros/ofelia) is a modern, Docker-native job scheduler designed as a lightweight, reliable alternative to traditional system `cron` daemons.

## Key Features

- **Docker-Native**: Configured dynamically using container labels (`ofelia.enabled=true`).
- **Socket Proxy Isolation**: Communicates with the Docker API via a dedicated, read-only `ofelia-socket-proxy` container over TCP (`DOCKER_HOST=tcp://ofelia-socket-proxy:2375`).
- **Zero Host Socket Mounts**: No direct `/var/run/docker.sock` volume mount on the `ofelia` scheduler container.
- **Multiple Execution Modes**:
  - `job-exec`: Runs commands inside existing running containers (e.g., executing scripts inside `umami-reporter`).
  - `job-run`: Runs ephemeral containers to execute one-off tasks (e.g., database dumps).
  - `job-local`: Executes commands locally inside the Ofelia container.

## Architecture & Security

```
 ┌─────────────────────────────────────────────────────────────┐
 │                      ofelia-socket-proxy                    │
 │  - Image: ghcr.io/tecnativa/docker-socket-proxy:latest      │
 │  - Restricted APIs: CONTAINERS=1, EVENTS=1, EXEC=1, POST=1   │
 └──────────────────────────────┬──────────────────────────────┘
                                │ TCP :2375
                                ▼
 ┌─────────────────────────────────────────────────────────────┐
 │                           ofelia                            │
 │  - Image: mcuadros/ofelia:latest                            │
 │  - Environment: DOCKER_HOST=tcp://ofelia-socket-proxy:2375  │
 └──────────────────────────────┬──────────────────────────────┘
                                │ (Triggers jobs via labels)
                                ▼
                ┌──────────────────────────────┐
                │       Target Containers      │
                │  (e.g., umami-reporter, DBs) │
                └──────────────────────────────┘
```

## Quick Start

```bash
cd compose/01-infrastructure/ofelia
docker compose up -d
```

## Ansible Deployment

```bash
ansible-playbook -i ansible/inventory.yml ansible/site.yml --tags ofelia
```

## Example Label Configuration

To schedule a command on any target container, add the following labels to its Docker Compose service:

```yaml
services:
  umami-reporter:
    image: node:20-alpine
    container_name: umami-reporter
    labels:
      - "ofelia.enabled=true"
      - "ofelia.job-exec.umami-report-daily.schedule=0 20 * * *"
      - "ofelia.job-exec.umami-report-daily.command=node /app/scripts/umami-ntfy-report.js"
      - "ofelia.job-exec.umami-report-weekly.schedule=0 9 * * 1"
      - "ofelia.job-exec.umami-report-weekly.command=node /app/scripts/umami-ntfy-report.js"
```

## Resources

- [Ofelia GitHub Repository](https://github.com/mcuadros/ofelia)
- [Docker Socket Proxy Security Guide](../../reference/socket-proxy-permissions.md)
