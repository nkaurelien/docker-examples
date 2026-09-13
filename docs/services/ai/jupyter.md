---
tags: ai, jupyter, notebook, jupyterlab, python, datascience
---

# JupyterLab & Notebooks

[JupyterLab](https://jupyter.org/) is the latest web-based interactive development environment for notebooks, code, and data.

---

## 🚀 Quick Reference

| Attribute | Details |
|---|---|
| **Service Name** | JupyterLab |
| **Primary Domain** | `https://jupyter.kamitbrains.fr` |
| **Alias Domain** | `https://notebook.kamitbrains.fr` |
| **Docker Image** | `quay.io/jupyter/datascience-notebook:latest` |
| **Container Name** | `jupyter` |
| **Internal Port** | `8888` |
| **Auth Type** | Token Authentication (`JUPYTER_TOKEN`) |
| **Secrets Location** | `.secrets/jupyter-admin-token` |

---

## 🛠️ Stack Configuration

JupyterLab is preconfigured with the official Data Science notebook stack including Python 3, pandas, numpy, scipy, scikit-learn, matplotlib, seaborn, R, and Julia.

```yaml
services:
  jupyter:
    image: quay.io/jupyter/datascience-notebook:latest
    container_name: jupyter
    restart: unless-stopped
    command: start-notebook.sh --IdentityProvider.token='${JUPYTER_TOKEN}'
    environment:
      - DOCKER_STACKS_JUPYTER_CMD=lab
      - JUPYTER_ENABLE_LAB=yes
    volumes:
      - ./data:/home/jovyan/work
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.jupyter.rule=Host(`jupyter.kamitbrains.fr`) || Host(`notebook.kamitbrains.fr`)"
      - "traefik.http.routers.jupyter.entrypoints=websecure"
      - "traefik.http.routers.jupyter.tls.certresolver=letsencrypt"
      - "traefik.http.routers.jupyter.middlewares=crowdsec-bouncer@file"
      - "traefik.http.services.jupyter.loadbalancer.server.port=8888"
```

---

## 🔒 Security & Access

- Access is secured via HTTPS/TLS (LetsEncrypt certs issued by Traefik) and protected against brute-force attacks via CrowdSec.
- Authentication requires entering the administrative token stored in `.secrets/jupyter-admin-token`.
